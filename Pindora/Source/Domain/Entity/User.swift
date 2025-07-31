//
//  UserModel.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import Foundation
import FirebaseAuth

struct User: Hashable {
    var userId: String
    var userImage: String?
    var personaName: String?
    var personaDescription: String = "00개의 장소를 저장해보세요."
    
    var likedPlaces: [Place]?
    var savedPlaces: [Place]?
    var visitedPlaces: [Place]?
    
    // MARK: - Firebase Auth 초기화 생성자
    init(from firebaseUser: FirebaseAuth.User) {
        self.userId = firebaseUser.uid
        self.userImage = firebaseUser.photoURL?.absoluteString
        self.personaName = firebaseUser.displayName
        self.personaDescription = "00개의 장소를 저장해보세요."
        self.likedPlaces = []
        self.savedPlaces = []
        self.visitedPlaces = []
    }
    
    // MARK: - 수동 생성자 (테스트, DTO 변환용)
    init(userId: String, userImage: String? = nil, personaName: String? = nil, personaDescription: String = "00개의 장소를 저장해보세요.", likedPlaces: [Place]? = nil, savedPlaces: [Place]? = nil, visitedPlaces: [Place]? = nil) {
        self.userId = userId
        self.userImage = userImage
        self.personaName = personaName
        self.personaDescription = personaDescription
        self.likedPlaces = likedPlaces
        self.savedPlaces = savedPlaces
        self.visitedPlaces = visitedPlaces
    }
}

extension User {
    func toDTO() -> UserDTO {
            return UserDTO(
                userId: userId,
                userImage: userImage,
                personaName: personaName,
                personaDescription: personaDescription,
                likedPlaces: likedPlaces?.map { $0.toDTO() },
                savedPlaces: savedPlaces?.map { $0.toDTO() },
                visitedPlaces: visitedPlaces?.map { $0.toDTO() }
            )
        }
}
