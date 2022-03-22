//
//  LoginViewController.swift
//  Rudder
//
//  Created by Brian Bae on 13/07/2021.

// 현재 token 저장은 RequestBasic에 있음

import UIKit
import Security

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var spinner: UIActivityIndicatorView!

    @IBOutlet weak var userIdField: UITextField!
    @IBOutlet weak var userPasswordField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
}

extension LoginViewController{
        
    @IBAction func touchUpLoginButton(_ sender: UIButton){
        spinner.startAnimating()
        guard let userId: String = self.userIdField.text,
              userId.isEmpty == false else {
            Alert.showAlert(title: "Id field empty", message: nil, viewController: self)
            spinner.stopAnimating()
            return
        }
        
        guard let userPassword: String = self.userPasswordField.text,
              userPassword.isEmpty == false else {
            Alert.showAlert(title: "Password field empty", message: nil, viewController: self)
            spinner.stopAnimating()
                return
        }
        
        guard let ApnToken: String = UserDefaults.standard.string(forKey: "ApnToken"),
              ApnToken.isEmpty == false else {
            print("no ApnToken")
            sendLoginRequest(userId: userId, userPassword: userPassword, token: "ApnTokenFail") //이부분 박성훈과 논의
            return
        }
        sendLoginRequest(userId: userId, userPassword: userPassword, token: ApnToken)
        
    }
    
    @IBAction func touchUpForgotButton(_ sender: UIButton){
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let forgotIdAction = UIAlertAction(title: "Forgot ID", style: .default, handler: { action in
            print("forgotId called")
            self.performSegue(withIdentifier: "GoForgotID", sender: sender)
        })
        
        let forgotPasswordAction = UIAlertAction(title: "Forgot Password", style: .default, handler: { action in
            print("forgotPassword called")
            self.performSegue(withIdentifier: "GoForgotPW", sender: sender)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(forgotIdAction)
        actionSheet.addAction(forgotPasswordAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
}

extension LoginViewController {
    
    @IBAction func touchUpSignUpButton(_ sender: UIButton){
        print("GoSignUp Touched")
        DispatchQueue.main.async {self.performSegue(withIdentifier: "GoAgreement", sender: sender)}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showNotice()
        spinner.hidesWhenStopped = true
        self.hideKeyboardWhenTappedAround()
        
        signUpButton.layer.borderWidth = 0.5
        signUpButton.layer.borderColor = UIColor.lightGray.cgColor
        signInButton.layer.borderWidth = 0.5
        signInButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.isHidden = true
        
        userIdField.text = nil
        userPasswordField.text = nil
    }
}


extension LoginViewController{
    func sendLoginRequest(userId:String, userPassword:String, token:String){
        let loginInfo = LoginInfo(userId: userId, userPassword: userPassword, os: "ios", token: token)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(loginInfo) else {
             return
         }
        
        RequestBasic.uploadInfo(EncodedUploadData: EncodedUploadData, completion: {
            status in
            DispatchQueue.main.async {self.spinner.stopAnimating()}
            if status == 1 {
                DispatchQueue.main.async {self.performSegue(withIdentifier: "GoCommunity", sender: nil)}
            }
            if status == 2 {
                DispatchQueue.main.async {
                    Alert.showAlert(title: "Wrong", message: nil, viewController: self)
                    //self.showAlert(message: "Wrong")
                }
            }
        })
    }
}


//keyboard dismiss
extension LoginViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension LoginViewController {
    func showNotice(){
        if Utils.noticeShowed == false && Utils.firstScreen == 0{
            Alert.serverAlert(viewController: self)
            Utils.noticeShowed = true
        }
    }
}
