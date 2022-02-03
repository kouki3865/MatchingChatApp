//
//  ViewController.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/15.
//

import UIKit
import PKHUD
import Firebase
import FirebaseFirestore


class HomeViewController: UIViewController {
    
    private var user: User?
    private var users = [User]()
    
    private let cardview = UIView()
    
    @IBOutlet weak var MatcingLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var ChatButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = .rgb(red: 227, green: 48, blue: 78)
        ButtonSetUp()
        setuplayout()
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchHomeInfoFromFireStore()
        setuplayout()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser?.uid == nil {
           let storybord = UIStoryboard(name: "SignUp", bundle: nil)
            let signupViewController = storybord.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
            let nav = UINavigationController(rootViewController: signupViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
        
    }
    
    func fetchHomeInfoFromFireStore(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.fetchUserFireStore(uid: uid) { user in
            if let user = user {
                self.user = user
                
            }
        }
        fetchUsers()
    }
    
    
    private func ButtonSetUp(){
        profileButton.layer.cornerRadius = 30
        profileButton.addTarget(self, action: #selector(tappedProfileButton), for: .touchUpInside)
        ChatButton.layer.cornerRadius = 30
        ChatButton.addTarget(self, action: #selector(tappedChatButton), for: .touchUpInside)
        
    }
    
    @objc private func tappedChatButton(){
        let storybord = UIStoryboard(name: "ChatList", bundle: nil)
        let chatlistViewController = storybord.instantiateViewController(withIdentifier: "ChatListViewContoller")
        navigationController?.pushViewController(chatlistViewController, animated: true)
    }
    
    @objc private func tappedProfileButton(){
        let storybord = UIStoryboard(name: "Profile", bundle: nil)
        let profileviewcontroller = storybord.instantiateViewController(withIdentifier: "ProFileViewContoller")
        self.present(profileviewcontroller, animated: true, completion: nil)
        
    }
    private func fetchUsers(){
        Firestore.fetchUsersFromFirestore { users in
            self.users = users
            self.users.forEach { user in
                let card = CardView(user: user)
                self.cardview.addSubview(card)
                card.anchor(top: self.cardview.topAnchor, bottom: self.cardview.bottomAnchor, left: self.cardview.leftAnchor, right: self.cardview.rightAnchor)
                

            }
            print("ユーザー情報の取得に成功")

        }
    }
    
    private func setuplayout(){
        view.addSubview(self.cardview)
        
        self.cardview.anchor(top:MatcingLabel.bottomAnchor,bottom: view.bottomAnchor,left:view.leftAnchor,right: view.rightAnchor,topPadding: 30,bottomPadding: 20,leftPadding: 20,rightPadding: 20)
    
    }
    
        
}
