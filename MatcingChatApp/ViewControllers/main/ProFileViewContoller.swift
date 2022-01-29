//
//  ProFileViewContoller.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/15.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SDWebImage


class ProFileViewContoller : UIViewController {
    
    var user:User?
    
    private var hasChangedImage = false
    
    @IBOutlet weak var namelabel: UILabel!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var residenceTextField: UITextField!
    @IBOutlet weak var hobbyTextField: UITextField!
    @IBOutlet weak var introductionTextField: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    @IBAction func profileEditImageButton(_ sender: Any) {
        let imegePickerController = UIImagePickerController()
        imegePickerController.delegate = self
        imegePickerController.allowsEditing = true
        
        self.present(imegePickerController, animated: true)
    }
   
    private var name = ""
    private var age = ""
    private var residence = ""
    private var hobby = ""
    private var introduction = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        editButton.layer.cornerRadius = 30
        profileImageView.image = UIImage(named: "noimage")
        nameTextField.delegate = self
        ageTextField.delegate = self
        residenceTextField.delegate = self
        hobbyTextField.delegate = self
        introductionTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 90
        profileImageView.layer.masksToBounds = true

        //既存のユーザーの情報をviewに反映
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.fetchUserFireStore(uid: uid) { user in
            if let user = user {
                self.user = user
                self.namelabel.text = user.name
                self.nameTextField.text = user.name
                self.ageTextField.text = user.age
                self.residenceTextField.text = user.residence
                self.hobbyTextField.text = user.hobby
                self.introductionTextField.text = user.introduction
                if let url = URL(string: user.profileImageURL ?? ""){
                    self.profileImageView.sd_setImage(with: url)
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //保存ボタンの処理
    @IBAction func SaveButton(_ sender: Any) {
        let dic = [
            "name": self.name,
            "age": self.age,
            "residence": self.residence,
            "hobby": self.hobby,
            "introduction": self.introduction,
            "uid":Auth.auth().currentUser?.uid
        ]
        
        if hasChangedImage {
            //画像を保存する処理
            guard let image = profileImageView.image else {return}
            Storage.addProfileImageToStorage(image: image, dic: dic) {
                
            }
        } else {
            Firestore.updateUserInfo(dic: dic) {
                print("更新完了")
            }
            self.dismiss(animated: true)

        }
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            
            let storybord = UIStoryboard(name: "SignUp", bundle: nil)
            let signupViewController = storybord.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
            let nav = UINavigationController(rootViewController: signupViewController)
            nav.modalPresentationStyle = .fullScreen

            self.present(nav, animated: true, completion: nil)

            print("ログアウトに成功しました")
            
        } catch {
            print("ログアウトに失敗しました\(error)")
        }
    }
    
   
}

extension ProFileViewContoller:UITextFieldDelegate{
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        self.name = nameTextField.text ?? ""
        self.age = ageTextField.text ?? ""
        self.residence = residenceTextField.text ?? ""
        self.hobby = hobbyTextField.text ?? ""
        self.introduction = introductionTextField.text ?? ""
    }
}

extension ProFileViewContoller:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            profileImageView.image = image.withRenderingMode(.alwaysOriginal)
        }
       
        hasChangedImage = true
        dismiss(animated: true, completion: nil)
    }
}



    
