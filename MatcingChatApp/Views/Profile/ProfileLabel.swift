//
//  ProfileLabel.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/18.
//

import UIKit

class ProfileLabel: UILabel {
    
    
    init(title:String) {
        super.init(frame: .zero)
        self.text = title
        self.textColor = .darkGray
        self.font = .systemFont(ofSize: 14)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
