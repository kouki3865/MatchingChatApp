//
//  LoginViewController.swift
//  MatcingChatApp
//
//  Created by koki on 2022/01/17.
//

import UIKit
import Firebase
import FirebaseFirestore
import PKHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var dontHaveAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.addTarget(self, action: #selector(TappedLoginButton), for: .touchUpInside)
        loginButton.layer.cornerRadius = 10
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func TappedLoginButton(){
        loginwithFireAuth()
    }
    
    @IBAction func TapeddontHaveAccountButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func loginwithFireAuth(){
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        HUD.show(.progress)
        
        Auth.loginwithFireAuth(email: email, password: password) { success in
            if success {
                HUD.hide { _ in
                    HUD.flash(.success, onView: self.view, delay: 1) { _ in
                        self.dismiss(animated: true)
                    }
                }
            }else{
                
            }
        }
    }
}
