//
//  GPTAPIManager.swift
//  Pindora
//
//  Created by 장주진 on 9/2/25.
//

import Foundation
import Combine

final class GPTAPIManager {
    private let apiKey: String
    
    init() {
        guard let key = Bundle.main.infoDictionary?["GPT_API_KEY"] as? String else {
            fatalError("GPT Key없음 -> info.plist확인")
        }
        self.apiKey = key
    }
    
    func sendPrompt(_ prompt: String) -> AnyPublisher<String, Error> {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: GPTResponse.self, decoder: JSONDecoder())
            .map { $0.choices.first?.message.content ?? "No Response" }
            .eraseToAnyPublisher()
    }
}

// MARK: - GPT 응답 모델
struct GPTResponse: Decodable {
    struct Choice: Decodable {
        let message: Message
    }
    struct Message: Decodable {
        let role: String
        let content: String
    }
    let choices: [Choice]
}
