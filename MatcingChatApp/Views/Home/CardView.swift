//
//  CardView.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/18.
//

import UIKit


class CardView: UIView {
    
    private let gradientLayer = CAGradientLayer()

    private let infoButton = UIButton(type: .system).createCardInfoButton()
    private let cardImageview = CardImageView(frame: .zero)
    private let goodLabel = CardInfoLabel(labeltext: "GOOD", labelColor: .rgb(red: 137, green: 223, blue: 86))
    private let nopelabel = CardInfoLabel(labeltext: "NOPE", labelColor: .rgb(red: 222, green: 110, blue: 110))
    private let namelabel = CardInfoLabel(Font: .systemFont(ofSize: 40, weight: .bold))
    private let residenceLabel = CardInfoLabel(Font: .systemFont(ofSize: 20, weight: .regular))
    private let hobbyLabel = CardInfoLabel(Font: .systemFont(ofSize: 25, weight: .regular))
    private let introductionLabel = CardInfoLabel(Font: .systemFont(ofSize: 25, weight: .regular))
    
    init(user:User){
        super.init(frame: .zero)
    
        setupLayout(user: user)
        setupgradientLayer()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pancardView))
        self.addGestureRecognizer(panGesture)
    }
    
  
    private func setupgradientLayer(){
        gradientLayer.colors = [UIColor.clear.cgColor,UIColor.black.cgColor]
        gradientLayer.locations = [0.3,1.1]
        cardImageview.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        gradientLayer.frame = self.bounds
    }
    
    @objc private func pancardView(gesture:UIPanGestureRecognizer){
        let translation = gesture.translation(in: self)
        guard let view = gesture.view else {return}
        if gesture.state == .changed{
            
            handlePanChenge(translation: translation)
            
        }else if gesture.state == .ended {
            self.handlePanEnded(view: view,translation: translation)
        }
    }
    
    private func handlePanChenge(translation: CGPoint){
        let degree:CGFloat = translation.x / 20
        let angle = degree * .pi / 100
        
        let rotateTranslation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotateTranslation.translatedBy(x: translation.x, y: translation.y)
        
        let ratio:CGFloat = 1 / 100
        let ratioValue = ratio * translation.x
        
        if translation.x > 0 {
            self.goodLabel.alpha = ratioValue
        }else if translation.x < 0 {
            self.nopelabel.alpha = -ratioValue
        }
        
    }
    
    private func handlePanEnded(view:UIView,translation:CGPoint) {
        
        if translation.x <= -120 {
            view.removeCardViewAnimation(x: -600)

        }else if translation.x >= 120 {
            view.removeCardViewAnimation(x: 600)
        }else{
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: []) {
            self.transform = .identity
            self.layoutIfNeeded()
            self.goodLabel.alpha = 0
            self.nopelabel.alpha = 0
        }
    }
}
    private func setupLayout(user:User){
        
        let infoVerticalStackView = UIStackView(arrangedSubviews: [residenceLabel,hobbyLabel,introductionLabel])
        infoVerticalStackView.axis = .vertical
        
        let baseStackView = UIStackView(arrangedSubviews: [infoVerticalStackView,infoButton])
        baseStackView.axis = .horizontal
        
        addSubview(cardImageview)
        addSubview(namelabel)
        addSubview(baseStackView)
        addSubview(goodLabel)
        addSubview(nopelabel)
        
        infoButton.anchor(width:40)
        cardImageview.anchor(top:topAnchor,bottom: bottomAnchor,left: leftAnchor,right: rightAnchor,leftPadding: 10,rightPadding: 10)
        namelabel.anchor(bottom:baseStackView.topAnchor,left:cardImageview.leftAnchor,bottomPadding: 10,leftPadding: 20)
        baseStackView.anchor(bottom:cardImageview.bottomAnchor,left:cardImageview.leftAnchor,right: cardImageview.rightAnchor,bottomPadding: 20,leftPadding: 20,rightPadding: 20)
        goodLabel.anchor(top: cardImageview.topAnchor,left: cardImageview.leftAnchor,width: 140,height: 55,topPadding: 25,leftPadding: 20)
        nopelabel.anchor(top: cardImageview.topAnchor,right: cardImageview.rightAnchor,width: 140,height: 55,topPadding: 25,rightPadding: 20)
        
        namelabel.text = user.name
        introductionLabel.text = user.introduction
        hobbyLabel.text = user.hobby
        residenceLabel.text = user.residence
        
        if let url = URL(string: user.profileImageURL ?? ""){
            self.cardImageview.sd_setImage(with: url)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


