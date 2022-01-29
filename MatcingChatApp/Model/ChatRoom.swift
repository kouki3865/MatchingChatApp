//
//  ChatRoom.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/27.
//


import Foundation
import Firebase

class ChatRoom {
    
    var latestMessageid:String
    var members:[String]
    var createdAt:Timestamp
    
    var latestmessage:Message?
    var documentId: String?
    var partnerUser:ChatUser?
    
    init(dic:[String:Any]) {
        self.latestMessageid = dic["latestMessageid"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}
