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
        다음은 사용자의 최근 여행지 리스트입니다:
        \(keyword.joined(separator: ", "))

        이 장소들을 참고해서 아래 조건을 모두 만족하는 페르소나를 만들어줘:

        [조건]
        1. 위 장소의 특징을 웹에서 각각 찾아 그 특징을 기반으로 아래 조건을 이어가줘
        2. 이름은 "00적인 00" 형식 (예: 감성적인 나그네, 모험적인 탐험가)
        3. 설명은 위 이름을 반영해서 40자 이내의 짧은 문장
        4. 아래 형식을 반드시 지켜서 출력해줘:

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
