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
struct KaKaoGeoCodeResponse: Decodable {
    let documents: [KakaoGeoCodeDTO]
}

final class KakaoSearchAPIManager {
    static let shared = KakaoSearchAPIManager()
    
    /// 카카오 장소 키워드를 통한 검색
    /// - Parameters:
    ///   - keyword: 검색 키워드
    ///   - lng: x 좌표(경도)
    ///   - lat: y 좌표(위도)
    ///   - radius: 반경 몇m 까지 검색할지
    ///   - page: 결과 페이지
    ///   - size: 한페이지에 보여질 장소 수
    /// - Returns: 장소 리스트
    func searchPlaces(
        keyword: String,
        x lng: Double? = nil,
        y lat: Double? = nil,
        radius: Int = 3000,
        page: Int = 1,
        size: Int = 10
    ) -> AnyPublisher<[Place], InfraError> {
        
        // URL 구성
        var comp = URLComponents(string: "https://dapi.kakao.com/v2/local/search/keyword.json")
        
        var queryItems: [URLQueryItem] = [
            .init(name: "query", value: keyword),
            .init(name: "radius", value: String(radius)),
            .init(name: "page", value: String(page)),
            .init(name: "size", value: String(size))
        ]
        
        // 위경도가 있을 때만 추가
        if let lng = lng, let lat = lat {
            queryItems.append(.init(name: "x", value: String(lng)))
            queryItems.append(.init(name: "y", value: String(lat)))
        }
        
        comp?.queryItems = queryItems
        
        guard let url = comp?.url else {
            return Fail(error: InfraError.invalidURL).eraseToAnyPublisher()
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("KakaoAK \(Constants.KakaoAPI.restApiKey)", forHTTPHeaderField: "Authorization")

        return URLSession.shared.dataTaskPublisher(for: req)
            // 네트워크 레벨 에러 -> Infra.network 로 변환
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
    
    /// 카카오 주소검색 API를 이용해 문자열 주소를 좌표로 변환
    /// - Parameters:
    ///   - query: 사용자가 입력한 주소 문자열 (지번/도로명 모두 OK)
    ///   - page: 결과 페이지
    ///   - size: 한번에 보여질 장소 갯수
    /// - Returns: 지오코딩 결과 리스트(여러 후보)
    func geocodeAddress(
        query: String,
        analyze_type: String = "exact",
        page: Int = 1,
        size: Int = 10
    ) -> AnyPublisher<Place, InfraError> {

        // URL 구성
        var comp = URLComponents(string: "https://dapi.kakao.com/v2/local/search/address.json")
        comp?.queryItems = [
            .init(name: "query", value: query),
            .init(name: "page", value: String(page)),
            .init(name: "size", value: String(size))
        ]

        guard let url = comp?.url else {
            return Fail(error: InfraError.invalidURL).eraseToAnyPublisher()
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("KakaoAK \(Constants.KakaoAPI.restApiKey)", forHTTPHeaderField: "Authorization")
        
        // 요청
        return URLSession.shared.dataTaskPublisher(for: req)
            .mapError { InfraError.network($0) }
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
            .decode(type: KaKaoGeoCodeResponse.self, decoder: JSONDecoder())
            .map { response in
                response.documents.compactMap { $0.toPlace() }.first
            }
            .tryMap { placeOpt -> Place in
                if let place = placeOpt { return place }
                let err = NSError(domain: "Kakao", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "No geocode result"])
                throw err
            }
            .mapError { error -> InfraError in
                if let e = error as? InfraError { return e }
                if error is DecodingError { return .decoding(error) }
                return .network(error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

