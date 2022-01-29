//
//  ChatUser.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/27.
//

import UIKit
import Firebase

class ChatUser {
    
    var email: String
    var username: String
    var createdAt: Timestamp
    var profileImageUrl: String
    
    var uid: String?
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.username = dic["name"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageURL"] as? String ?? ""
    }
    
}
