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

// MARK: - Naver DTO
struct NaverItem: Decodable {
    let title: String
    let roadAddress: String
    let mapX: String
    let mapY: String
    let category: String?
}

extension NaverItem {
    func toPlace() -> Place? {
        guard let x = Double(mapX), let y = Double(mapY) else { return nil }
        return Place(name: title,
                     address: roadAddress.stripHTML(),
                     latitude: y / 1_000_000,
                     longitude: x / 1_000_000,
                     category: category ?? "기타"
        )
    }
}

extension String {
    func stripHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
}

struct NaverResponse: Decodable {
    let items: [NaverItem]
}

// MARK: - Naver Entity
struct Place {
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let category: String
}

final class NaverSearchAPIManager {
    static let shared = NaverSearchAPIManager()
    private init() {}
    
    private let cliendId = ""
    private let clientSecret = ""
    
    func search(keyword: String, completion: @escaping (Place?) -> Void) {
        guard let encoded = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(cliendId, forHTTPHeaderField: "X-Naver-Client-Id")
        request.setValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                print("❌ 네트워크 오류: \(error?.localizedDescription ?? "알 수 없음")")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(NaverResponse.self, from: data)
                guard let item = decoded.items.first,
                      let x = Double(item.mapX),
                      let y = Double(item.mapY) else {
                    completion(nil)
                    return
                }
                
                let place = item.toPlace()
                completion(place)
                
            } catch {
                print("파싱 실패ㅣ \(error)")
                completion(nil)
            }
        }.resume()
    }
}
