//
//  CardInfoLabel.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/15.
//

import UIKit

class CardInfoLabel: UILabel {
    
    // GOODとNOPEのラベル
    init(labeltext: String, labelColor: UIColor) {
        super.init(frame: .zero)
        font = .boldSystemFont(ofSize: 45)
        text = labeltext
        textColor = labelColor
        
        layer.borderWidth = 3
        layer.borderColor = labelColor.cgColor
        layer.cornerRadius = 10
        
        textAlignment = .center
        alpha = 0
    }
    
    //その他のlabel
    init(Font:UIFont){
        super.init(frame: .zero)
        font = Font
        textColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
