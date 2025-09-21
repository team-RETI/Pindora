//  SearchViewModel.swift
//  Pindora
//
//  Created by 김동현 on 9/22/25.
//

import UIKit
import Combine

final class SearchDetailViewModel {
    
    struct Input {
        let searchKeyword: AnyPublisher<String, Never>
    }
    
    struct Output {
        let filteredKeywords: AnyPublisher<[String], Never>
    }
    
    private let keywordPublisher: AnyPublisher<[String], Never>
    
    init(keywordPublisher: AnyPublisher<[String], Never>) {
        self.keywordPublisher = keywordPublisher
    }
    
    func transform(input: Input) -> Output {
        let filteredKeywords = input.searchKeyword
            .combineLatest(keywordPublisher)
            .map { query, keywords in
                query.isEmpty
                ? keywords
                : keywords.filter { $0.localizedStandardContains(query) }
            }
            .eraseToAnyPublisher()
        return Output(filteredKeywords: filteredKeywords)
    }
}
