//
//  NaverImageAPIManager.swift
//  Pindora
//
//  Created by eunchanKim on 9/7/25.
//

import Foundation
import Combine

struct NaverImageResponse: Decodable {
    struct Item: Decodable {
        let link: String
        let thumbnail: String?
        let sizeHeight: String?
        let sizeWidth: String?
    }
    let items: [Item]
}

final class NaverImageAPIManager {
    static let shared = NaverImageAPIManager()
    
    /// 네이버 이미지 검색
    /// - Parameters:
    ///   - query: 검색어
    ///   - display: 10..100 한번에 표시할 이미지 수
    ///   - start: 1...1000 검색 시작 위치
    ///   - sort: 검색 결과 정렬 방법( sim: 정확도, date: 날짜순)
    ///   - filter: 크기별 검색 결과 필더 (all: 모든이미지, large: 큰이미지, medium: 중간, small: 작은)
    /// - Returns: 이미지를 포함한 결과
    func searchImage(
        query: String,
        display: Int = 10,
        start: Int = 1,
        sort: String = "sim",
        filter: String = "all"
    ) -> AnyPublisher<[NaverImageResponse.Item], InfraError> {
        
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return Fail(error: .invalidQuery).eraseToAnyPublisher()
        }

        var comp = URLComponents(string: "https://openapi.naver.com/v1/search/image")
        comp?.queryItems = [
            .init(name: "query", value: trimmed),
            .init(name: "display", value: String(min(max(display, 1), 100))),
            .init(name: "start", value: String(min(max(start, 1), 1000))),
            .init(name: "sort", value: sort)
        ]

        guard let url = comp?.url else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }

        var req = URLRequest(url: url)
        req.setValue(Constants.NaverAPI.APIClientId, forHTTPHeaderField: "X-Naver-Client-Id")
        req.setValue(Constants.NaverAPI.APISecretId, forHTTPHeaderField: "X-Naver-Client-Secret")
        return URLSession.shared.dataTaskPublisher(for: req)
            // 네트워크 레벨 에러 -> Infra.network 로 변환
            .mapError { InfraError.network($0) }
            // HTTP 상태코드 검사
            .tryMap { output -> Data in
                if let http = output.response as? HTTPURLResponse,
                   !(200...299).contains(http.statusCode) {
                    let err = NSError(
                        domain: "Naver",
                        code: http.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"]
                    )
                    throw InfraError.network(err)
                }
                return output.data
            }
            // 디코딩
            .decode(type: NaverImageResponse.self, decoder: JSONDecoder())
            .map { $0.items }
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
