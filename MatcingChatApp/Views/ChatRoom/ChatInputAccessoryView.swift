//
//  ChatInputAccessoryView.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/24.
//

import UIKit

protocol ChatInputAccessoryViewDeregate: class {
    func tappedSendButton(text: String)
}

class ChatInputAccessoryView: UIView {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatTextView: UITextView!
    @IBAction func tappedSendButton(_ sender: Any) {
        guard let text = chatTextView.text else {return}
        delegate?.tappedSendButton(text: text)
    }
    
    weak var delegate:ChatInputAccessoryViewDeregate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nibInit()
        setupViews()
        autoresizingMask = .flexibleHeight
    }
    
    private func setupViews(){
        chatTextView.layer.cornerRadius = 15
        chatTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        chatTextView.layer.borderWidth = 1
        
        sendButton.layer.cornerRadius = 15
        sendButton.imageView?.contentMode = .scaleAspectFill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.isEnabled = false
        
        chatTextView.text = ""
        chatTextView.delegate = self
    }
    
    func removeText(){
        chatTextView.text = ""
        sendButton.isEnabled = false
    }
    
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    private func nibInit(){
        let nib = UINib(nibName: "ChatinputAccessorryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {return}
        
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        self.addSubview(view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ChatInputAccessoryView:UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            sendButton.isEnabled = false
        }else{
            sendButton.isEnabled = true
        }
    }
    
}
