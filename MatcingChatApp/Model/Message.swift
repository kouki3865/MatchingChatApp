//
//  Message.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/27.
//

import Foundation
import Firebase

class Message {
    
    let name:String
    let message:String
    let uid:String
    let craetedAt:Timestamp
    
    var partnerUser:ChatUser?
    
    init(dic:[String:Any]) {
        
        self.name = dic["name"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.craetedAt = dic["craetedAt"] as? Timestamp ?? Timestamp()
        
    }
    
}
