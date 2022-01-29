//
//  SignUpViewController.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/15.
//

import UIKit
import Firebase
import FirebaseFirestore
import PKHUD

class SignUpViewController:UIViewController{
    
    @IBOutlet weak var RegisterButton: UIButton!
    @IBOutlet weak var nametextField: UITextField!
    @IBOutlet weak var emailTextFild: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RegisterButton.layer.cornerRadius = 10
        nametextField.delegate = self
        emailTextFild.delegate = self
        PasswordTextField.delegate = self
        RegisterButton.isEnabled = false
        RegisterButton.isEnabled = false
        RegisterButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func TapdRegisterButton(_ sender: Any) {
        createUser()
    }
    
    @IBAction func createAboutAccountButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewcontroller = storyboard.instantiateViewController(identifier: "LoginViewController")
        self.navigationController?.pushViewController(loginViewcontroller, animated: true)
    }
    
    
    private func createUser(){
        let email = emailTextFild.text
        let password = PasswordTextField.text
        let name = nametextField.text
        HUD.show(.progress)
        Auth.createUsertToFireAuth(email: email, password: password, name: name) { success in
            if success {
                print("処理が完了")
                HUD.hide { _ in
                    HUD.flash(.success, onView: self.view, delay: 1) { _ in
                        self.dismiss(animated: true)
                    }
                    
                }
            }else {
                print("")
            }
        }
    }
}


extension SignUpViewController:UITextFieldDelegate{
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEnpty = nametextField.text?.isEmpty ?? true
        let passwordIsEnpty = emailTextFild.text?.isEmpty ?? true
        let usernameIsEnpty = PasswordTextField.text?.isEmpty ?? true
        
        if emailIsEnpty || passwordIsEnpty || usernameIsEnpty {
            RegisterButton.isEnabled = false
            RegisterButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        }else{
            RegisterButton.isEnabled = true
            RegisterButton.backgroundColor = .rgb(red: 255, green: 141, blue: 0)
        }
        
    }
    
}


