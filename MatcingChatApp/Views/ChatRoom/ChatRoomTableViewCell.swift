//
//  ChatRoomTableViewCell.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/24.
//

import UIKit
import Firebase
import Nuke

class ChatRoomTableViewCell: UITableViewCell {
    
    var message:Message? {
        didSet{
           
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var partnermessageTextView: UITextView!
    @IBOutlet weak var mymessageTextView: UITextView!
    @IBOutlet weak var partnerDatelabel: UILabel!
    @IBOutlet weak var myDateLabel: UILabel!
    
    @IBOutlet weak var partnermessageTextViewwithConstraint: NSLayoutConstraint!
    @IBOutlet weak var mymessageTextViewWithConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 30
        partnermessageTextView.layer.cornerRadius = 15
        mymessageTextView.layer.cornerRadius = 15
        backgroundColor = .clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkWhichUserMessage()
    }
    
    private func checkWhichUserMessage(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        if uid == message?.uid {
            partnermessageTextView.isHidden = true
            partnerDatelabel.isHidden = true
            userImageView.isHidden = true
            
            mymessageTextView.isHidden = false
            myDateLabel.isHidden = false
            if  let message = message {
                mymessageTextView.text = message.message
                let witdh = estimateFrameEorTextView(text: message.message).width + 20
                mymessageTextViewWithConstraint.constant = witdh
                myDateLabel.text = dateFormatterForDateLabel(date: message.craetedAt.dateValue())
                
            }
        }else {
            partnermessageTextView.isHidden = false
            partnerDatelabel.isHidden = false
            userImageView.isHidden = false
            
            mymessageTextView.isHidden = true
            myDateLabel.isHidden = true
            
            if let urlString = message?.partnerUser?.profileImageUrl, let url = URL(string: urlString) {
                Nuke.loadImage(with: url, into: userImageView)
            }
            
            if  let message = message {
                partnermessageTextView.text = message.message
                let witdh = estimateFrameEorTextView(text: message.message).width + 20
                partnermessageTextViewwithConstraint.constant = witdh
                partnerDatelabel.text = dateFormatterForDateLabel(date: message.craetedAt.dateValue())
                
            }
        }
    }
    
    private func estimateFrameEorTextView(text:String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 16)], context: nil)
    }
    private func dateFormatterForDateLabel(date:Date) ->String{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
