//
//  UserlistViewController.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/26.
//

import UIKit
import Firebase
import FirebaseFirestore
import Nuke

class UserlistViewController:UIViewController{
    
    private let cellId = "cellId"
    private var users = [ChatUser]()
    private var serectedUser:ChatUser?
    
    @IBOutlet weak var startChatButton: UIButton!
    @IBOutlet weak var userlistTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *){
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.rgb(red: 227, green: 48, blue: 78)
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        userlistTableView.tableFooterView = UIView()
        
        userlistTableView.delegate = self
        userlistTableView.dataSource = self
        
        startChatButton.isEnabled = false
        startChatButton.layer.cornerRadius = 10
        startChatButton.addTarget(self, action: #selector(tappedStartButton), for: .touchUpInside)
        
        fetchUserInfoFromFireStore()

    }
    
    
    @objc private func tappedStartButton(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let partneruid = self.serectedUser?.uid else {return}
        let members = [uid,partneruid]
        
        let docData = [
            "members":members,
            "latestMessageid ": "",
            "createdAt":Timestamp()
        ] as [String : Any]
        
        Firestore.firestore().collection("chatRooms").addDocument(data: docData) { err in
            if let err = err {
                print("chatRoomsの情報の保存に失敗しました\(err)")
                return
            }
            self.dismiss(animated: true, completion: nil)
            print("chatRoomsの情報の保存に成功しました")
        }
    }
    
    private func fetchUserInfoFromFireStore(){
       
        Firestore.firestore().collection("users").getDocuments { (snapshots, err) in
                    if let err = err {
                        print("user情報の取得に失敗しました。\(err)")
                        return
                    }
                    
                    snapshots?.documents.forEach({ (snapshot) in
                        let dic = snapshot.data()
                        let user = ChatUser(dic: dic)
                        user.uid = snapshot.documentID
                        
                        guard let uid = Auth.auth().currentUser?.uid else { return }
                        
                        if uid == snapshot.documentID {
                            return
                        }
                        
                        self.users.append(user)
                        self.userlistTableView.reloadData()
                    })
                }
            }
     }


extension UserlistViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userlistTableView.dequeueReusableCell(withIdentifier: cellId,for:indexPath) as! UserlistTableViewCell
        cell.user = users[indexPath.row]
     return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startChatButton.isEnabled = true
        let user = users[indexPath.row]
        self.serectedUser = user
        
    }
    
}

class UserlistTableViewCell: UITableViewCell{
    
    var user:ChatUser? {
        didSet{
            usernameLabel.text = user?.username
            
            if let url = URL(string: user?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: userImageView)
            }
        }
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 32.5
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
