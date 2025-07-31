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
    private var completion: ((Result<AuthDataResult, Error>) -> Void)?

    func startSignInWithAppleFlow() -> Future<AuthDataResult, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }

            let nonce = self.randomNonceString()
            self.currentNonce = nonce

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = self.sha256(nonce)

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self

            self.completion = { result in
                promise(result)
            }

            controller.performRequests()
        }
    }
}

// MARK: - Apple Delegate
extension FirebaseAuthManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else {
            completion?(.failure(NSError(domain: "auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Apple ID 토큰 생성 실패"])))
            return
        }

        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)

        Auth.auth().signIn(with: credential) { result, error in
            if let result = result {
                self.completion?(.success(result))
            } else {
                self.completion?(.failure(error ?? NSError(domain: "auth", code: -2, userInfo: nil)))
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(.failure(error))
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
