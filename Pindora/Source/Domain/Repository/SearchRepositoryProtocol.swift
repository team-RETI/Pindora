//
//  SearchRepositoryProtocol.swift
//  Pindora
//
//  Created by eunchanKim on 9/4/25.
//

import Foundation
import CoreLocation
import Combine

protocol SearchRepositoryProtocol {
    
    /// 키워드를 이용하여 장소를 겁색합니다
    /// - Parameter keyword: 사용자 입력 키워드
    /// - Returns: 장소리스트 AnyPublisher<[Place], UseCaseError>
    func search(keyword: String) -> AnyPublisher<[Place], InfraError>
    
    /// 위치정보와 키워드를 이용하여 장소를 검색합니다
    /// - Parameters:
    ///   - keyword: 사용자 입력 키워드
    ///   - center: 위치 정보(좌표)
    /// - Returns: 장소리스트 AnyPublisher<[Place], UseCaseError>
    func search(keyword: String, center: CLLocationCoordinate2D) -> AnyPublisher<[Place], InfraError>
    
    /// 이미지 검색
    /// - Parameters:
    ///   - query: 사용자 입력 + 카테고리 키워드
    ///   - display: 10..100 한번에 표시할 이미지 수
    ///   - start: 1...1000 검색 시작 위치
    ///   - sort: 검색 결과 정렬 방법( sim: 정확도, date: 날짜순)
    ///   - filter: 크기별 검색 결과 필더 (all: 모든이미지, large: 큰이미지, medium: 중간, small: 작은)
    /// - Returns: 이미지를 포함한 결과 AnyPublisher<[NaverImage]>
    func searchImage(
        query: String,
        display: Int,
        start: Int,
        sort: String,
        filter: String
    ) -> AnyPublisher<[NaverImageResponse.Item], InfraError>
    
    /// 주소검색 API를 이용해 문자열 주소를 좌표로 변환
    /// - Parameters:
    ///   - query: 사용자가 입력한 주소 문자열 (지번/도로명 모두 OK)
    ///   - page: 결과 페이지
    ///   - size: 한번에 보여질 장소 갯수
    /// - Returns: 지오코딩 장소 결과 AnyPublisher<Place, InfraError>
    func searchGeocode(
        query: String,
        page: Int,
        size: Int
    ) -> AnyPublisher<Place, InfraError>
}
