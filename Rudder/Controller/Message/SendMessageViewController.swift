//
//  SendMessageViewController.swift
//  Rudder
//
//  Created by 박민호 on 2022/02/08.
//

import UIKit

class SendMessageViewController: UIViewController {
    
    @IBOutlet weak var messageBodyView: UITextView!

    var delegate: DoUpdateMessageDelegate?
    var directDelegate: DoUpdateMessageDirectDelegate?
    var receiveUserInfoId: Int!
    
    @IBAction func touchUpBackButton(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
}
extension SendMessageViewController {
    
    @IBAction func touchSendButton(_ sender: UIButton){
        guard let messageBody: String = self.messageBodyView.text,
              (messageBody.isEmpty == false && messageBody != "Send a mail") else {
            Alert.showAlert(title: "Empty!", message: nil, viewController: self)
            return
        }
        spinner.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        RequestSendMessage.uploadInfo(receiveUserInfoId: receiveUserInfoId, messageBody: messageBody, completion: {
            status in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
            guard status else {
                DispatchQueue.main.async {Alert.showAlert(title: "Server Error", message: nil, viewController: self)}
                return
            }
            self.delegate?.doUpdateMessage()
            self.directDelegate?.doUpdateMessageDirect()
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        placeholderSetting()
    }
}

extension SendMessageViewController: UITextViewDelegate{
    func placeholderSetting() {
            messageBodyView.delegate = self // txtvReview가 유저가 선언한 outlet
            messageBodyView.text = "Send a mail"
            messageBodyView.textColor = UIColor.lightGray
            
        }
        
        // TextView Place Holder
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.black
            }
            
        }
        // TextView Place Holder
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = "Send a mail"
                textView.textColor = UIColor.lightGray
            }
           // self.postBodyView.rightAnchor.constraint(equalTo: self.lastButtonAnchor, constant: 50).isActive = true
        }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}
