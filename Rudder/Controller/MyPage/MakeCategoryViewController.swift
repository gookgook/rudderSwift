//
//  MakeCategoryViewController.swift
//  Rudder
//
//  Created by 박민호 on 2022/03/08.
//

import UIKit

class MakeCategoryViewController: UIViewController {
    
    @IBOutlet weak var categoryBodyView: UITextView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBAction func touchUpSubmitButton(_ sender: UIButton){
        guard let categoryBody: String = self.categoryBodyView.text,
              categoryBody.isEmpty == false else {
            Alert.showAlert(title: "One or more field is Empty!", message: nil, viewController: self)
            return
        }
        print("Search body not empty")
        /*guard searchBody.count>=3 else {
            Alert.showAlert(title: "Please enter at least three letters", message: nil, viewController: self)
            return false
        }*/
        dismissKeyboard()
        spinner.startAnimating()
        requestAddCategory(categoryBody: categoryBody)
    }
    
    override func viewDidLoad() {
        hideKeyboardWhenTappedAround()
        super.viewDidLoad()
    }
    
    func requestAddCategory(categoryBody: String){
        RequestAddCategory.uploadInfo(categoryName: categoryBody, completion: {
            status in
            DispatchQueue.main.async {self.spinner.stopAnimating()}
            if status == 1 {
                print("send Add category success")
                DispatchQueue.main.async {
                    Alert.showAlertWithCB(title: "Thank you! Your request will now be considered by the uni experts", message: nil, isConditional: false, viewController: self, completionBlock: {_ in
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
            if status == -1 {
                print("send feedback error")
            }
        })
    }
    
    @IBAction func goBack(_ sender: UIButton){
        print("go Back touched")
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}

extension MakeCategoryViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
