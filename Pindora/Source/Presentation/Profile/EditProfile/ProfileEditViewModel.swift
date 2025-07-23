//
//  ProfileEditViewModel.swift
//  Pindora
//
//  Created by eunchanKim on 7/22/25.
//

import UIKit

final class ProfileEditViewModel {
    enum ImageType: String, CaseIterable {
        case memoji = "Memoji"
        case custom = "커스텀"
        case color = "컬러"
    }
    
    var selectedImageType: ImageType = .memoji
    var personaTitle: String = "즉흥적인 도시 탐험가"
    var personaDescription: String = "조용한 카페를 선호하고 갑작스럽게 화장실을 자주가며 고즈넉한 장소를 자주 방문하여 쉬어가는 라이프 스타일을 가지고 있어요"
}

