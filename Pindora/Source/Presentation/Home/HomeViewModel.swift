//  HomeViewModel.swift
//  Pindora
//
//  Created by 김동현 on 7/16/25.
//

import UIKit
import Combine

final class HomeViewModel {
    @Published var places: [Place] = []
    
    // 파이어베이스에 저장된 키웓,
    @Published private var keywords: [String] = [] {
        didSet {
            print("파이어베이스 키워드: \(keywords)")
        }
    }
    
    // 필터링된 결과
    @Published private var filteredKeywords: [String] = [] {
        didSet {
            print("필터링된 키워드: \(filteredKeywords)")
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let placeUseCase: PlaceUseCase
    
    init(placeUseCase: PlaceUseCase) {
        self.placeUseCase = placeUseCase
    }
    
    func fetchPlaces() {
        placeUseCase.fetchPlaces()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("장소 로딩 실패: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] placeList in
                self?.places = placeList
            }.store(in: &cancellables)
    }
    
    func fetchKeywords() {
        placeUseCase.fetchKeywords()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    print("키워드 로딩 실패: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] keywordList in
                self?.keywords = keywordList
            }.store(in: &cancellables)
    }
    
    func filterKeywords(query: String) {
        if query.isEmpty {
            filteredKeywords = []
        } else {
            filteredKeywords = keywords.filter {
                /// localizedCaseInsensitiveContains: 대소문자 무시, 로케일 고려, 부분문자열 검색 가능
                $0.localizedStandardContains(query)
            }
        }
    }
    
    func resetFilter() {
        filteredKeywords = []
    }
}
