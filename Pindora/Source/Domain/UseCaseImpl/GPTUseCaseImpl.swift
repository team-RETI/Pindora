//
//  GPTUseCaseImpl.swift
//  Pindora
//
//  Created by 장주진 on 9/2/25.
//

import Foundation
import Combine


final class GPTUseCaseImpl: GPTUseCaseProtocol {
    private let gptRepository: GPTRepositoryProtocol
    
    init(gptRepository: GPTRepositoryProtocol) {
        self.gptRepository = gptRepository
    }
    
    func createPersonaNameAndDescription(from keyword: [String]) -> AnyPublisher<(name: String, description: String), Error> {
        let prompt = """
        사용자의 최근 여행지는 '\(keyword)'야. 이 장소를 참고해서 아래 조건에 맞는 페르소나를 만들어줘.
        
        
        
        !!중요!! 이 아래는 절대 바꾸지 말아주세요 ! 아래 형식으로 나와야 정상적으로 동작합니다.
        
        결과 형식은 꼭 아래처럼 맞춰줘:
        
        이름: [여기에 이름]
        설명: [여기에 설명]
        """
        
        return gptRepository.generateDescription(for: prompt)
            .tryMap { response in
                let lines = response.components(separatedBy: "\n")
                let name = lines.first(where: { $0.hasPrefix("이름:") })?
                    .replacingOccurrences(of: "이름:", with: "").trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let desc = lines.first(where: { $0.hasPrefix("설명:") })?
                    .replacingOccurrences(of: "설명:", with: "").trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return (name: name, description: desc)
            }
            .eraseToAnyPublisher()
    }
}
