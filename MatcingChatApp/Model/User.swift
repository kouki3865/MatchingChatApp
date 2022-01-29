//
//  User.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/18.
//

import Foundation
import Firebase

class User {
    
    var name:String
    var email:String
    var createdAt:Timestamp
    var age:String
    var residence: String
    var hobby: String
    var introduction:String
    var profileImageURL: String
    var uid: String?
    

    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.name = dic["name"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.age = dic["age"] as? String ?? ""
        self.residence = dic["residence"] as? String ?? ""
        self.hobby = dic["hobby"] as? String ?? ""
        self.introduction = dic["introduction"] as? String ?? ""
        self.profileImageURL = dic["profileImageURL"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""

    }
}
