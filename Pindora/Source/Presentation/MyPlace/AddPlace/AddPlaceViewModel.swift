//
//  AddPlaceViewModel.swift
//  Pindora
//
//  Created by eunchanKim on 7/28/25.
//

import UIKit
import Combine
import CoreLocation

final class AddPlaceViewModel {
    // MARK: - Dependancy
    // API/Framework
    private let searchUseCase: SearchUseCaseProtocol
    // DB
    private let placeUseCase: PlaceUseCase
    private let imageUseCase: ImageUsecaseProtocol
    // Combine
    private var cancellable: Set<AnyCancellable> = []
    
    init(
        searchUseCase: SearchUseCaseProtocol,
        placeUseCase: PlaceUseCase,
        imageUseCase: ImageUsecaseProtocol
    ) {
        self.searchUseCase = searchUseCase
        self.placeUseCase = placeUseCase
        self.imageUseCase = imageUseCase
    }
    
    struct Input {
        let keyword: AnyPublisher<String, Never>
        let categorySelected: AnyPublisher<String, Never>
        let confirmButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let selectedCategory: AnyPublisher<String, Never>
        let place: AnyPublisher<Place, Never>
    }
    
    func transform(input: Input) -> Output {
        
        // 1) 키워드 정리
        let keywordNormalized = input.keyword
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .handleEvents(receiveOutput: { kw in
                print("⌨️ keywordNormalized:", kw)
            })
            .eraseToAnyPublisher()
        
        // 2) 선택 카테고리 스트림 (필요 시 share 가능)
        let selectedCategory = input.categorySelected
            .removeDuplicates()
            .handleEvents(receiveOutput: { cat in
                print("🏷️ selectedCategory:", cat)
            })
            .share()
            .eraseToAnyPublisher()
        
        // 3) 검색 스트림: 최신 검색만 유지 + 실패 시 빈값
        let place: AnyPublisher<Place, Never> = keywordNormalized
            .map { [weak self] query -> AnyPublisher<Place, Never> in
                guard let self = self else {
                    return Empty<Place, Never>().eraseToAnyPublisher()
                }
                return self.searchUseCase
                    .searchGeocode(query: query, page: 1, size: 1) // -> AnyPublisher<Place, Error>
                    .handleEvents(receiveOutput: { place in
                        print("📍 place:", place)
                    })
                    .catch { _ in Empty<Place, Never>() } // 에러 시 무시
                    .eraseToAnyPublisher()
            }
            .switchToLatest()                  // 이전 요청 자동 취소
            .receive(on: DispatchQueue.main)   // UI 업데이트
            .eraseToAnyPublisher()
        
        // 4) 최신 Place를 저장해 두기 (withLatestFrom 대용)
        let latestPlace = CurrentValueSubject<Place?, Never>(nil)
            place
            .sink { latestPlace.send($0) }
            .store(in: &cancellable)
        
        // 4-1) 최신 Category도 저장해 두기
        let latestCategory = CurrentValueSubject<String?, Never>(nil)
        selectedCategory
            .sink { latestCategory.send($0) }
            .store(in: &cancellable)
        
        // 5) 확인 버튼 탭 → 최신 Place 저장
        input.confirmButtonTapped
            .compactMap { [weak latestPlace, weak latestCategory] _ -> (Place, String)? in
                guard
                    let place = latestPlace?.value,
                    let category = latestCategory?.value,
                    !category.isEmpty
                else {
                    print("⚠️ 저장 스킵: place/category 없음")
                    return nil
                }
                return (place, category)
            }
            .flatMap { [weak self] (place, category) -> AnyPublisher<Void, Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                let placeToSave = place.withCategory(category)
                return self.placeUseCase
                    .savePlace(place: placeToSave)
                    .handleEvents(
                        receiveSubscription: { _ in print("💾 saving place:", placeToSave) },
                        receiveCompletion: { print("✅ save completion:", $0) }
                    )
                    .map { _ in () }
                    .catch { err -> AnyPublisher<Void, Never> in
                        print("💥 save failed:", err)
                        return Empty().eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { /* 저장 후 토스트/닫기 등 */ }
            .store(in: &cancellable)
        
        return Output(
            selectedCategory: selectedCategory,
            place: place
        )
    }
}
