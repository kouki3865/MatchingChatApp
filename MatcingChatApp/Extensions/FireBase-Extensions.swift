//
//  FireBase-Extensions.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/17.
//

import Firebase
import FirebaseFirestore
import PKHUD

extension Auth {
    static func  createUsertToFireAuth(email: String?, password:String?, name:String?, completion: @escaping (Bool) -> Void){
        
        guard let email = email else {return}
        guard let password = password else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { auth, err in
            if let err = err {
                print("firebaseの認証情報に失敗しました\(err)")
                HUD.hide { _ in
                    HUD.flash(.error, delay: 1)
                }
                return
            }
            guard let uid = auth?.user.uid else {return}
            Firestore.setuserDataToFireStore(uid: uid,email: email, name: name) { sucess in
                completion(sucess)
            }
        }
    }
    
    static func loginwithFireAuth(email:String, password:String,completion: @escaping (Bool) -> Void){
        
        Auth.auth().signIn(withEmail: email, password: password) { res, err in
            if let err = err {
                print("signupに失敗しました\(err)")
                HUD.hide { _ in
                    HUD.flash(.error, delay: 1)
                }
                return
            }
            completion(true)
            print("ログインに成功")
        }
    }
}

extension Firestore{
    
    static func setuserDataToFireStore(uid:String,email:String,name:String?,completion: @escaping (Bool) -> ()){
        guard let name = name else {return}

        let docdata = [
            "name": name,
            "email": email,
            "createdAt": Timestamp(),
            "uid":uid
        ] as [String : Any]
        
        Firestore.firestore().collection("users").document(uid).setData(docdata) { err in
            if let err = err {
                print("ユーザー情報の保存に失敗しました\(err)")
                HUD.hide { _ in
                    HUD.flash(.error, delay: 1)
                }
                return
            }
            completion(true)
            print("ユーザー情報の保存に成功しました")
            
        }
    }
    
    static func fetchUserFireStore(uid: String,completion:@escaping (User?) -> Void){
        Firestore.firestore().collection("users").document(uid).addSnapshotListener { snapshot, err in
            if let err = err {
                print("ユーザー情報の取得に失敗しました\(err)")
                completion(nil)
                return
            }
            guard let dic = snapshot?.data() else {return}
            let user = User.init(dic: dic)
            completion(user)
        }
        
    }
    //firestoreから自分以外のユーザー情報を取得
    static func fetchUsersFromFirestore(completion: @escaping ([User]) ->Void){
        Firestore.firestore().collection("users").getDocuments { snapshots, err in
            if let err = err {
                print("全てのユーザー情報の取得に失敗\(err)")
                return
            }
            var users = [User]()
            snapshots?.documents.forEach({ snapshot in
                let dic = snapshot.data()
                let user = User.init(dic: dic)
                users.append(user)
            })
            let filterdUsers = users.filter { user in
                return user.uid != Auth.auth().currentUser?.uid
            }
            
            completion(filterdUsers)
        }
        
    }
    //ユーザー情報の更新
    static func updateUserInfo(dic:[String:Any],compeltion:  @escaping () -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).updateData(dic) { err in
            if let err = err {
                print("ユーザー情報の更新に失敗\(err)")
                return
            }
            compeltion()
            print("ユーザー情報の更新に成功")
        }
    }
}

extension Storage {
    
    //ユーザーの情報をfirestoreに保存
    static func addProfileImageToStorage(image: UIImage, dic:[String:Any],comcompeltion:  @escaping () -> Void) {
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else {return}
        
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profileImage").child(filename)
        
        storageRef.putData(uploadImage, metadata: nil) { metadata, err in
            if let err = err {
                print("画像の保存に失敗しました\(err)")
                return
            }
            
            storageRef.downloadURL { url, err in
                if let err = err {
                    print("画像の取得に失敗\(err)")
                    return
                }
                guard let urlstring = url?.absoluteString else {return}
                var dicwithImage = dic
                dicwithImage["profileImageURL"] = urlstring
                
                Firestore.updateUserInfo(dic: dicwithImage) {
                    comcompeltion()
                }
            }
        }
        
    }
}
