//
//  UserModel.swift
//  Pindora
//
//  Created by 장주진 on 7/26/25.
//

import Foundation
import FirebaseAuth

struct User: Codable {
    var uid: String
    var name: String?
    var email: String?
    
    init(from firebaseUser: FirebaseAuth.User) {
        self.uid = firebaseUser.uid
        self.name = firebaseUser.displayName
        self.email = firebaseUser.email
        
    }
}
