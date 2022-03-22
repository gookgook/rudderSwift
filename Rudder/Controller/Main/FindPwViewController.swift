//
//  FindPwViewController.swift
//  Rudder
//
//  Created by 박민호 on 2022/02/16.
//

import UIKit

class FindPwViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    
    @IBAction func touchUpSendButton(_ sender: UIButton){
        print("Send Button touched")
        guard let email: String = self.emailField.text,
              email.isEmpty == false else {
            Alert.showAlert(title: "Email Field Empty!", message: nil, viewController: self)
            return
        }
        RequestSendPwVc.uploadInfo(email: email, completion: {
            status in
            if status {
                Alert.showAlertWithCB(title: "We have sent your Verification Code to your school email", message: nil, isConditional: false, viewController: self, completionBlock: {_ in
                    let alert = UIAlertController(title: "Verification Code", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Verify", comment: "verify"), style: .cancel, handler: {_ in
                        guard let verificationCode: String = alert.textFields?[0].text,
                              verificationCode.isEmpty == false else {
                            Alert.showAlert(title: "Verifictation Code Field Empty!", message: nil, viewController: self)
                            return
                        }
                        self.checkCode(email: email, verificationCode: verificationCode)
                    }))
                    alert.addTextField(configurationHandler: nil)
                    self.present(alert, animated: true, completion: nil)
                    //self.navigationController?.popToRootViewController(animated: true)
                })
            }else{
                Alert.showAlert(title: "Please enter your valid school email", message: nil, viewController: self)
            }
        })
    }
    private func checkCode(email: String, verificationCode: String){
        RequestForgotCheckCode.uploadInfo(email: email, verificationCode: verificationCode, completion: {status in
            if status {
                DispatchQueue.main.async {
                    Alert.showAlertWithCB(title: "We have sent a new password to your university email", message: nil, isConditional: false ,viewController: self, completionBlock: {_ in
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                }
            }else{
                DispatchQueue.main.async { Alert.showAlert(title: "Wrong Code!", message: nil, viewController: self) }
            }
        })
    }
}
extension FindPwViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        setBar()
    }

    func setBar(){
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
}
