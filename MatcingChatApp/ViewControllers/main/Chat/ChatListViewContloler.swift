//
//  ChatViewContller.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/15.
//

import UIKit
import Firebase
import Nuke
import FirebaseFirestore

class ChatListViewContoller: UIViewController {
    
    private let cellId = "cellId"
    private var chatuser:ChatUser?
    private var users = [ChatUser]()
    
    private var chatrooms = [ChatRoom]()
  
    @IBOutlet weak var ChatlistTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ナビゲーションバーの透明を治す
        if #available(iOS 15.0, *){
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.rgb(red: 227, green: 48, blue: 78)
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        setupView()
        
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        fetchLoginUserInfo()
        fatchChatroomsInfoFromFireStore()
    }
    
   
    private func setupView(){
        
        ChatlistTableView.delegate = self
        ChatlistTableView.dataSource = self

        navigationItem.title = "トーク"
       
        let  rightBarButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedNavRightBarButton))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    
    private func fatchChatroomsInfoFromFireStore(){
        Firestore.firestore().collection("chatRooms")
            .addSnapshotListener { snapshots, err in
                if let err = err {
                    print("chatrooms情報の取得に失敗しました\(err)")
                    return
                }
                snapshots?.documentChanges.forEach({ documentChange in
                    switch documentChange.type {
                    case .added:
                        self.handleAddedDocumentChange(documentChange: documentChange)
                    case .modified,.removed:
                        print("noting to do")
                    }
                })
                
                
              
        }
    }
    
    private func handleAddedDocumentChange(documentChange:DocumentChange){
        let dic = documentChange.document.data()
        let chatroom = ChatRoom(dic: dic)
        chatroom.documentId = documentChange.document.documentID
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let isContain = chatroom.members.contains(uid)
        
        if !isContain {return}
        
            chatroom.members.forEach{ memberuid in
            if memberuid != uid {
                Firestore.firestore().collection("users").document(memberuid).getDocument { snapshot, err in
                    if let err = err {
                        print("ユーザー情報の取得に失敗しました")
                        return
                    }
                    
                    guard let dic = snapshot?.data() else {return}
                    let user = ChatUser(dic: dic)
                    user.uid = documentChange.document.documentID
                    chatroom.partnerUser = user

                    guard let chatroomId = chatroom.documentId else {return}
                    let latestmessageId = chatroom.latestMessageid
                    
                    if latestmessageId == "" {
                        self.chatrooms.append(chatroom)
                        self.ChatlistTableView.reloadData()
                        return
                    }
                    
                    Firestore.firestore().collection("chatRooms").document(chatroomId).collection("messages").document(latestmessageId).getDocument { snapshot, err in
                        if let err = err {
                            print("最新情報の取得に失敗しました\(err)")
                        }
                        guard  let dic = snapshot?.data() else {return}
                        let message = Message(dic: dic)
                        chatroom.latestmessage = message
                        
                        self.chatrooms.append(chatroom)
                        self.ChatlistTableView.reloadData()
                        
                    }
                    
                }
            }
        }

    }
    
    private func fetchLoginUserInfo() {
           guard let uid = Auth.auth().currentUser?.uid else { return }
           
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                return
            }
            
            guard let snapshot = snapshot, let dic = snapshot.data() else { return }
            
            let user = ChatUser(dic: dic)
            self.chatuser = user
        }
    }
    
    @objc private func tappedNavRightBarButton(){
        let storyboard = UIStoryboard(name: "UserList", bundle: nil)
        let userlistViewController = storyboard.instantiateViewController(withIdentifier: "UserlistViewController")
        let nav = UINavigationController(rootViewController: userlistViewController)

        self.present(nav, animated: true, completion: nil)
    }
  
    
}

extension ChatListViewContoller:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ChatlistTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
        cell.chatroom = chatrooms[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storybord = UIStoryboard(name: "ChatRoom", bundle: nil)
        let chatroomviewcontroller = storybord.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
        chatroomviewcontroller.user = chatuser
        chatroomviewcontroller.chatroom = chatrooms[indexPath.row]
        navigationController?.pushViewController(chatroomviewcontroller, animated: true)
        
    }
    
    
}


class ChatListTableViewCell:UITableViewCell{

    var chatroom:ChatRoom? {
        didSet{
            if let chatroom = chatroom {
                partnerLabel.text = chatroom.partnerUser?.username
                
                guard let url = URL(string: chatroom.partnerUser?.profileImageUrl ?? "") else {return}
                Nuke.loadImage(with: url, into: userimageView)
                
                dateLabel.text = dateFormatterForDateLabel(date: chatroom.latestmessage?.craetedAt.dateValue() ?? Date())
                latestMessageLabel.text = chatroom.latestmessage?.message
            }
           
        }
    }
    
    @IBOutlet weak var userimageView: UIImageView!
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userimageView.layer.cornerRadius = 30
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    private func dateFormatterForDateLabel(date:Date) ->String{
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
}

