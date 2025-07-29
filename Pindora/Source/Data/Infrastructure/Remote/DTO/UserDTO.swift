//
//  UserDTO.swift
//  Pindora
//
//  Created by 장주진 on 7/29/25.
//

import Foundation

struct UserDTO: Codable {
    var userId: String
    var userImage: String?
    var personaName: String?
    var personaDescription: String
    
    var likedPlaces: [PlaceDTO]?
    var savedPlaces: [PlaceDTO]?
    var visitedPlaces: [PlaceDTO]?
}

extension UserDTO {
    func toEntity() -> User {
        return User(
            userId: userId,
            userImage: userImage,
            personaName: personaName,
            personaDescription: personaDescription,
            likedPlaces: likedPlaces?.map { $0.toEntity() },
            savedPlaces: savedPlaces?.map { $0.toEntity() },
            visitedPlaces: visitedPlaces?.map { $0.toEntity() }
        )
    }
}
