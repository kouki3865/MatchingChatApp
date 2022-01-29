//
//  CardImageView.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/18.
//

import UIKit

class CardImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
            layer.cornerRadius = 15
            backgroundColor = .gray
            contentMode = .scaleToFill
            isUserInteractionEnabled = true
            image = UIImage(named: "noimage2")
            clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
