//
//  ChatRoomViewController.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/24.
//

import UIKit
import Firebase


class ChatRoomViewController: UIViewController {
    
    var user:ChatUser?
    var chatroom:ChatRoom?
    
    private let cellId = "cellId"
    private var messages = [Message]()
    private let accessoryHeight:CGFloat = 100
    private let tableViewContentInset:UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private let tableViewIndicaterInset:UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private var safeAreaBottom:CGFloat {
        self.view.safeAreaInsets.bottom
    }
    
    private lazy var chatInputAccessoryView:ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.delegate = self
        view.frame = .init(x: 0 , y: 0 , width: view.frame.width, height: 100)
        return view
    }()
    
    @IBOutlet weak var ChatRoomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotification()
        setupChatRoomTableView()
        fetchMessages()
        
    }
    
    private func setupChatRoomTableView(){
        
        ChatRoomTableView.delegate = self
        ChatRoomTableView.dataSource = self
        ChatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        ChatRoomTableView.backgroundColor = .rgb(red: 247, green: 222, blue: 239)
        ChatRoomTableView.contentInset = tableViewContentInset
        ChatRoomTableView.scrollIndicatorInsets = tableViewIndicaterInset
        ChatRoomTableView.keyboardDismissMode = .interactive
        ChatRoomTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification:NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        
        if  let keybordFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            if keybordFrame.height <= accessoryHeight {return}
            
            let top = keybordFrame.height - safeAreaBottom
            var moveY = -(top - ChatRoomTableView.contentOffset.y)
            
            if ChatRoomTableView.contentOffset.y != -60 { moveY += 60}
            let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            
            ChatRoomTableView.contentInset = contentInset
            ChatRoomTableView.scrollIndicatorInsets = contentInset
            ChatRoomTableView.contentOffset = CGPoint(x: 0, y: moveY)
        }
        
    }
    
    @objc private func keybordWillHide(){
        ChatRoomTableView.contentInset = tableViewContentInset
        ChatRoomTableView.scrollIndicatorInsets = tableViewIndicaterInset
    }
    
    override var inputAccessoryView: UIView?{
        get{
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func fetchMessages(){
        guard let chatroomDocId = chatroom?.documentId else {return}
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").addSnapshotListener { snapshots, err in
            if let err = err {
                print("メッセージ情報の取得に失敗しました\(err)")
                return
            }
            snapshots?.documentChanges.forEach({ documentChange in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let message = Message(dic: dic)
                    message.partnerUser = self.chatroom?.partnerUser
                    self.messages.append(message)
                    self.messages.sort { m1, m2 in
                        let m1date = m1.craetedAt.dateValue()
                        let m2date = m2.craetedAt.dateValue()
                        return m1date > m2date
                    }
                    self.ChatRoomTableView.reloadData()
//                    self.ChatRoomTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
                case .modified,.removed:
                    print("nothing to do")
                    
                }
            })
        }
    }
    
}

extension ChatRoomViewController:ChatInputAccessoryViewDeregate{
    
    func tappedSendButton(text: String) {

       addMessageToFirestore(text: text)
        
    }
    
    private func addMessageToFirestore(text:String){
        guard let chatroomDocId = chatroom?.documentId else {return}
        guard let name = user?.username else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        chatInputAccessoryView.removeText()
        let  messageId = randomString(length: 20)
        
        let docData = [
            "name": name ,
            "craetedAt": Timestamp(),
            "uid":uid ,
            "message": text
        
        ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId)
            .collection("messages").document(messageId).setData(docData) { err in
                if let err = err {
                    print("メッセージ情報の保存に失敗しました\(err)")
                    return
                }
                
                let latestMessageData = [
                    "latestMessageid": messageId
                ]
                
                Firestore.firestore().collection("chatRooms").document(chatroomDocId)
                    .updateData(latestMessageData) { err in
                        if let err = err {
                            print("最新メッセージの保存に失敗しました\(err)")
                            return
                        }
                        print("メッセージの保存に成功しました")

                    }
            }
    }
    
    func randomString(length: Int) -> String {
            let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let len = UInt32(letters.length)

            var randomString = ""
        for _ in 0 ..< length {
                let rand = arc4random_uniform(len)
                var nextChar = letters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
            return randomString
    }
    
   
}

extension ChatRoomViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        ChatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ChatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        cell.message = messages[indexPath.row]
        return cell
    }
    
}
