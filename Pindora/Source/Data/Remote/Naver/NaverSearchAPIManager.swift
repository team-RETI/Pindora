//
//  NaverSearchAPIManager.swift
//  Pindora
//
//  Created by 김동현 on 7/26/25.
//

/*
 [요청 예시]
 curl "https://openapi.naver.com/v1/search/local.xml?query=%EC%A3%BC%EC%8B%9D&display=10&start=1&sort=random" \
     -H "X-Naver-Client-Id: {애플리케이션 등록 시 발급받은 클라이언트 아이디 값}" \
     -H "X-Naver-Client-Secret: {애플리케이션 등록 시 발급받은 클라이언트 시크릿 값}" -v
 */

import Foundation
import Combine

// MARK: - Error
enum NaverSearchAPIError: Error {
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

// MARK: - Naver DTO
struct NaverPlaceDTO: Decodable {
    let placeName: String
    let placeAddress: String
    let mapX: String
    let mapY: String
    let category: String?
    
    enum CodingKeys: String, CodingKey {
        case placeName = "title"
        case placeAddress = "roadAddress"
        case mapX = "mapx"
        case mapY = "mapy"
        case category
    }
}

extension NaverPlaceDTO {
    func toPlace() -> Place? {
        guard let x = Double(mapX), let y = Double(mapY) else { return nil }
        
        let latitude = y / 1_000_000
        let longitude = x / 1_000_000
        let name = placeName.stripHTML()
        
        return Place(placeId: Place.generateId(name: name, latitude: latitude, longitude: longitude),
                     placeName: name,
                     placeAddress: placeAddress,
                     latitude: latitude,
                     longitude: longitude,
                     category: category ?? "기타",
                     addedDate: .now
        )
    }
}

extension String {
    func stripHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}

struct NaverSearchResponse: Decodable {
    let items: [NaverPlaceDTO]
}

final class NaverSearchAPIManager {
    static let shared = NaverSearchAPIManager()
    private init() {}
    
    func searchEscaping(keyword: String, completion: @escaping (Place?) -> Void) {
        guard let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(Constants.NaverAPI.searchURL)?query=\(encoded)&display=1&start=1&sort=random") else {
            completion(nil)
            return
        }
        
        
        var request = URLRequest(url: url)
        request.setValue(Constants.NaverAPI.clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        request.setValue(Constants.NaverAPI.clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                print("❌ 네트워크 오류: \(error?.localizedDescription ?? "알 수 없음")")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(NaverSearchResponse.self, from: data)
                
                /*
                guard let item = decoded.items.first,
                      let x = Double(item.mapX),
                      let y = Double(item.mapY) else {
                    completion(nil)
                    return
                }
                 */
                
                guard let item = decoded.items.first else {
                    completion(nil)
                    return
                }
                
                let place = item.toPlace()
                completion(place)
                
            } catch {
                print("파싱 실패: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func search(keyword: String) -> AnyPublisher<Place?, Error> {
        guard let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(Constants.NaverAPI.searchURL)?query=\(encoded)&display=1&start=1&sort=random") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue(Constants.NaverAPI.clientID, forHTTPHeaderField: "X-Naver-Client-Id")
        request.setValue(Constants.NaverAPI.clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                let response = try JSONDecoder().decode(NaverSearchResponse.self, from: result.data)
                return response.items.first?.toPlace()
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()

    }
}
