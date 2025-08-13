//
//  KakaoSearchAPIManager.swift
//  Pindora
//
//  Created by eunchanKim on 8/12/25.
//
/*
 [요청 예시]
 (키워드)
 curl -v -G GET "https://dapi.kakao.com/v2/local/search/keyword.json?y=37.514322572335935&x=127.06283102249932&radius=20000" \
   -H "Authorization: KakaoAK ${REST_API_KEY}" \
   --data-urlencode "query=카카오프렌즈"
 */

import Foundation
import Combine

// MARK: - Error
enum KakaoSearchAPIError: Error {
    case invalidURL
    case network(Error)
    case decoding(Error)
    
    var message: String {
        switch self {
        case .invalidURL:
            return "⚠️ 유효하지 않은 검색어입니다. 다시 시도해주세요."
        case .network(let error):
            return "⚠️ 네트워크 오류가 발생했습니다: \(error.localizedDescription)"
        case .decoding(let error):
            return "⚠️ 데이터 파싱에 실패했습니다: \(error.localizedDescription)"
        }
    }
}

struct KakaoSearchResponse: Decodable {
    let documents: [KakaoPlaceDTO]
}

final class KakaoSearchAPIManager {
    static let shared = KakaoSearchAPIManager()
    private init() {}
    
    func searchPlaces (
        keyword: String,
        x lng: Double,
        y lat: Double,
        radius: Int = 1500,
        page: Int = 1,
        size: Int = 15,
        completion: @escaping (Result<[KakaoPlaceDTO], KakaoSearchAPIError>) -> Void
    ) {
        var comp = URLComponents(string: "https://dapi.kakao.com/v2/local/search/keyword.json")
        comp?.queryItems = [
            .init(name: "query", value: keyword),
            .init(name: "x", value: String(lng)),
            .init(name: "y", value: String(lat)),
            .init(name: "radius", value: String(radius)),
            .init(name: "page", value: String(page)),
            .init(name: "size", value: String(size))
        ]
        
        // URL 생성 실패
        guard let url = comp?.url else {
            DispatchQueue.main.async {
                completion(.failure(.invalidURL))
            }
            return
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("KakaoAK d3898164064c5679ec1876f47421c32a", forHTTPHeaderField: "Authorization")
        // req.setValue("KakaoAK \(Constants.KakaoAPI.KAKAO_REST_API_KEY)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: req) { data, _, error in
            // 네트워크 에러 처리
            if let error = error {
                return DispatchQueue.main.async {
                    completion(.failure(.network(error)))
                }
            }
            
            guard let data = data else {
                return DispatchQueue.main.async {
                    completion(.failure(.network(NSError(domain: "Kakao", code: -1, userInfo: [NSLocalizedDescriptionKey: "No Data"])) ))
                }
            }
            
            // JSON 디코딩
            do {
                let res = try JSONDecoder().decode(KakaoSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(res.documents))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decoding(error)))
                }
            }
        }.resume()
    }
    
    // 컴바인 오버로딩
    func searchPlaces(
        keyword: String,
        x lng: Double,
        y lat: Double,
        radius: Int = 3000,
        page: Int = 1,
        size: Int = 15
    ) -> AnyPublisher<[KakaoPlaceDTO], KakaoSearchAPIError> {
        
        // URL 구성
        var comp = URLComponents(string: "https://dapi.kakao.com/v2/local/search/keyword.json")
        comp?.queryItems = [
            .init(name: "query", value: keyword),
            .init(name: "x", value: String(lng)),
            .init(name: "y", value: String(lat)),
            .init(name: "radius", value: String(radius)),
            .init(name: "page", value: String(page)),
            .init(name: "size", value: String(size))
        ]
        
        guard let url = comp?.url else {
            return Fail(error: KakaoSearchAPIError.invalidURL).eraseToAnyPublisher()
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        // TODO: 실제 키로 교체 (예: Constants.KakaoAPI.KAKAO_REST_API_KEY)
        req.setValue("KakaoAK \(Constants.KakaoAPI.restApiKey)", forHTTPHeaderField: "Authorization")
        
        // Combine 파이프라인
        return URLSession.shared.dataTaskPublisher(for: req)
            // 네트워크 레벨 에러 -> KakaoSearchAPIError.network 로 변환
            .mapError { KakaoSearchAPIError.network($0) }
            // HTTP 상태코드 검사
            .tryMap { output -> Data in
                if let http = output.response as? HTTPURLResponse,
                   !(200...299).contains(http.statusCode) {
                    let err = NSError(
                        domain: "Kakao",
                        code: http.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"]
                    )
                    throw KakaoSearchAPIError.network(err)
                }
                return output.data
            }
            // 디코딩
            .decode(type: KakaoSearchResponse.self, decoder: JSONDecoder())
            .map { $0.documents }
            // 에러 매핑 정리
            .mapError { error -> KakaoSearchAPIError in
                if let e = error as? KakaoSearchAPIError { return e }
                if error is DecodingError { return .decoding(error) }
                return .network(error)
            }
            // UI 업데이트 스레드
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

