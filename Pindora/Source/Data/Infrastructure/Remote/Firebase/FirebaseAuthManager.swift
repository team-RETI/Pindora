//
//  FirebaseAuthManager.swift
//  Pindora
//
//  Created by 장주진 on 7/29/25.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import Combine
import UIKit

final class FirebaseAuthManager: NSObject {
    private var currentNonce: String?
    private var appleLoginCompletion: ((Result<(idToken: String, rawNonce: String), InfraError>) -> Void)?
    
    // MARK: - 애플 로그인 요청(회원가입 또는 인증 시작 시 사용)
    /// 애플 로그인 요청 - 클로저 기반
    /// 사용자가 애플 로그인 버튼을 눌렀을 때 로그인 UI를 띄우고, 결과로 idToken과 nonce를 전달한다.
    /// 이 단계는 실제 Firebase 인증 전 단계이며, 회원가입 또는 인증 시도 전에 필요한 Apple 인증 요청 단계이다.
    private func requestAppleAuthorization(completion: @escaping (Result<(idToken: String, rawNonce: String), InfraError>) -> Void) {
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let hashedNonce = sha256(nonce)
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = hashedNonce
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        
        appleLoginCompletion = completion
        controller.performRequests()
    }
    
    // MARK: - Firebase인증(애플 로그인 성공 후 idToken으로 인증 처리
    /// Firebase 애플 로그인 인증 - 클로저 기반
    /// Apple 로그인으로 얻은 idToken과 rawNonce를 바탕으로 Firebase 인증을 수행한다.
    private func authenticateWithApple(idToken: String, rawNonce: String, completion: @escaping (Result<Void, InfraError>) -> Void) {
        let credential =
        OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: rawNonce,
            fullName: nil
        )
        
        Auth.auth().signIn(with: credential) { _, error in
            if let error = error {
                completion(.failure(InfraError.firebaseError(error)))
            } else {
                completion(.success(()))
            }
        }
    }
}

// MARK: - Combine Wrapper
extension FirebaseAuthManager {
    /// 애플 로그인 요청 - Combine 기반
    /// 위의 클로저 기반 함수(requestAppleAuthorization)를 Future로 감싸 Combine 형태로 제공.
    /// ViewModel 등에서 Combine 체이닝으로 사용하기 편하게 만들어진 래퍼 함수이다.
    func requestAppleAuthorization() -> AnyPublisher<(idToken: String, rawNonce: String), InfraError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            self.requestAppleAuthorization { result in //
                promise(result) // Result<(idToken: String, rawNonce: String), LoginError>
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Firebase 애플 로그인 인증 - Combine 기반
    /// 위의 클로저 기반 인증 함수를 Future로 감싸 Combine 형태로 제공.
    func authenticateWithApple(idToken: String, rawNonce: String) -> AnyPublisher<Void, InfraError> {
        Future { [weak self] promise in
            guard let self = self else { return }
            self.authenticateWithApple(idToken: idToken, rawNonce: rawNonce) { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Apple Delegate
extension FirebaseAuthManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    // 로그인 창을 띄우고 로그인 성공 시 idToken과 rawNonce를 반환
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }

    // 애플 로그인 성공시 호출됨
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        defer { appleLoginCompletion = nil } // ✅ 항상 마지막에 nil 처리

        guard let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            appleLoginCompletion?(.failure(InfraError.appleInvalidCredential))
            return
        }
        
        guard let nonce = currentNonce else {
            appleLoginCompletion?(.failure(InfraError.appleNonceMissing))
            return
        }
        
        guard let appleIdToken = appleIdCredential.identityToken, let idTokenString = String(data: appleIdToken, encoding: .utf8) else {
            appleLoginCompletion?(.failure(InfraError.appleIDTokenParsingFailed))
            return
        }
        
        // ✅ idToken + rawNonce만 전달 (Firebase 로그인은 여기서 안 함)
        appleLoginCompletion?(.success((idToken: idTokenString, rawNonce: nonce)))
    }

    // 애플 로그인 실패시 호출됨
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        defer { appleLoginCompletion = nil }
        let customError: InfraError
        
        if let appleError = error as? ASAuthorizationError, appleError.code == .canceled {
            customError = .appleCanceled
        } else {
            customError = .appleError(error)
        }

        appleLoginCompletion?(.failure(customError))
    }
}

// MARK: - Helpers
private extension FirebaseAuthManager {
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }

    func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in UInt8.random(in: 0...255) }
            for random in randoms {
                if remainingLength == 0 { break }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
}


