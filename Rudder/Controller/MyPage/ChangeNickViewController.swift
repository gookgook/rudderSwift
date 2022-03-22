//
//  ChangeNickViewController.swift
//  Rudder
//
//  Created by 박민호 on 2022/01/20.
//

import UIKit

class ChangeNickViewController: UIViewController {
    
    @IBOutlet weak var nicknameField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeWhenTappedAround()
    }
}

extension ChangeNickViewController {
    @IBAction func touchSubmitButton(_ sender: UIButton){
        guard let nickname: String = self.nicknameField.text, nickname.isEmpty == false else {
            Alert.showAlert(title: "Nickname Field Empty!", message: nil, viewController: self)
            return
        }
        RequestNickChange.uploadInfo(nickname: nickname, completion: {
            status in
            DispatchQueue.main.async {self.spinner.stopAnimating()}
            if status == 1{
                DispatchQueue.main.async {
                    Alert.showAlertWithCB(title: "Success!", message: nil, isConditional: false, viewController: self, completionBlock: {_ in
                        self.goBack()
                    })
                    
                }
            }else if status == 2{
                DispatchQueue.main.async {Alert.showAlert(title: "Nickname already exists", message: nil, viewController: self)}
            }else if status == -1 {
                print("Server error")
            }
        })
    }
}

extension ChangeNickViewController: UIGestureRecognizerDelegate {
    func closeWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goBack))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
}
