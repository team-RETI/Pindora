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

struct KakaoSearchResponse: Decodable {
    let documents: [KakaoPlaceDTO]
}

final class KakaoSearchAPIManager {
    static let shared = KakaoSearchAPIManager()
//    private init() {}
    
    func searchPlaces (
        keyword: String,
        x lng: Double,
        y lat: Double,
        radius: Int = 1500,
        page: Int = 1,
        size: Int = 15,
        completion: @escaping (Result<[KakaoPlaceDTO], InfraError>) -> Void
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
        req.setValue("KakaoAK \(Constants.KakaoAPI.restApiKey)", forHTTPHeaderField: "Authorization")
        
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
        radius: Int = 500,
        page: Int = 1,
        size: Int = 15
    ) -> AnyPublisher<[Place], InfraError> {
        
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
            return Fail(error: InfraError.invalidURL).eraseToAnyPublisher()
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("KakaoAK \(Constants.KakaoAPI.restApiKey)", forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: req)
            // 네트워크 레벨 에러 -> KakaoSearchAPIError.network 로 변환
            .mapError { InfraError.network($0) }
            // HTTP 상태코드 검사
            .tryMap { output -> Data in
                if let http = output.response as? HTTPURLResponse,
                   !(200...299).contains(http.statusCode) {
                    let err = NSError(
                        domain: "Kakao",
                        code: http.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"]
                    )
                    throw InfraError.network(err)
                }
                return output.data
            }
            // 디코딩
            .decode(type: KakaoSearchResponse.self, decoder: JSONDecoder())
            .map { response in
                response.documents.compactMap{ $0.toPlace() }
            }
            // 에러 매핑 정리
            .mapError { error -> InfraError in
                if let e = error as? InfraError { return e }
                if error is DecodingError { return .decoding(error) }
                return .network(error)
            }
            // UI 업데이트 스레드
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

