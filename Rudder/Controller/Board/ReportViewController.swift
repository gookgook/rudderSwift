//
//  ReportViewController.swift
//  Rudder
//
//  Created by Brian Bae on 06/09/2021.
//

import UIKit

class ReportViewController: UIViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet var reportBodyView: UITextView!
    
    var postOrComment: String!
    var postId: Int!
    var commentId: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        reportBodyView.tintColor = MyColor.rudderPurple
        placeholderSetting()
    }

}

extension ReportViewController {
    @IBAction func touchUpSubmitButton(_ sender: UIButton){
        spinner.startAnimating()
        print("Report Submit Touched")
        guard let reportBody: String = self.reportBodyView.text,
            reportBody.isEmpty == false else {
            print("report empty")
            return
        }
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        let report: Report
        if postOrComment == "post" {report = Report(token: token, postId: postId, reportBody: reportBody, postType: "post")}
        else {report = Report(token: token, postId: commentId, reportBody: reportBody, postType: "comment")}
       
        
        guard let EncodedUploadData = try? JSONEncoder().encode(report) else {
          
            return
         }
        RequestReport.uploadInfo(EncodedUploadData: EncodedUploadData, completion: {
            status in
            DispatchQueue.main.async {self.spinner.stopAnimating()}
            if status == 1 {
                print("sendReport success")
                DispatchQueue.main.async {
                    Alert.showAlertWithCB(title: "Thanks for the Report. We will take it from here", message: nil, isConditional: false, viewController: self, completionBlock: {_ in
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
            if status == 2 {
                print("sendReport error")
            }
        })
        
    }
}

extension ReportViewController {
    @IBAction func goBack(_ sender: UIButton){
        print("go Back touched")
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}

extension ReportViewController: UITextViewDelegate {
    func placeholderSetting() {
        reportBodyView.delegate = self // txtvReview가 유저가 선언한 outlet
        reportBodyView.text = "Please help us understand what's going on (Offensive content, Privacy concerns, Sexual content, etc.."
        reportBodyView.textColor = UIColor.lightGray
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if reportBodyView.textColor == UIColor.lightGray {
            reportBodyView.text = nil
            reportBodyView.textColor = UIColor.black
        }
        
    }
    // TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        if reportBodyView.text.isEmpty {
            reportBodyView.text = "Please help us understand what's going on (Offensive content, Privacy concerns, Sexual content, etc.."
            reportBodyView.textColor = UIColor.lightGray
        }
    }
}


extension ReportViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
