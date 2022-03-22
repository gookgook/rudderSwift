//
//  EditPostViewController.swift
//  Rudder
//
//  Created by Brian Bae on 05/09/2021.
//

import UIKit

class EditPostViewController: UIViewController{ //textview.isEmpty placeholder떄문에 작동안함
    
    var delegate: DoRefreshDelegate?
    var editDelegate: DoUpdatePostBodyDelegate?
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var postBodyView: UITextView!
    
    //let categories = ["Sports", "food", "dating", "sdf","DSfsdf","sdff","sdfsdf","sdfsdfa"]
    private var categories: [Category] = []
    
    private var currentCategoryId = 1
    
    var previousPost: Post!
}

extension EditPostViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        postBodyView.tintColor = MyColor.rudderPurple
        postBodyView.delegate = self
        
        setBar()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.isHidden = true
        
        guard let post: Post = self.previousPost else {
            return
        }
        postBodyView.text = post.postBody
    }
}

extension EditPostViewController{
    @objc func touchUpPostButton(_ sender: UIButton){
        print("Post Touched")
        
        guard let postBody: String = self.postBodyView.text,
              postBody.isEmpty == false else {
          //  showAlert(message: "아이디없음")
           // spinner.stopAnimating()
            return
        }
        spinner.startAnimating()
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        
        RequestEditPost.uploadInfo(postId: previousPost.postId, postBody: postBody, completion: {
            status in
            DispatchQueue.main.async {
                self.spinner.startAnimating()
                self.navigationController?.navigationBar.isUserInteractionEnabled = true
            }
            if status == 1 {
                print("editpost success")
                self.delegate?.doRefreshChange()
                
               
                //TmpViewController.doRefresh = true /*******protocol로 변환 필요!*******
                DispatchQueue.main.async {
                    self.editDelegate?.doUpdatePostBody(postBody: postBody)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            if status == 2 {
                print("editpost error")
            }
        })
        
        
        //RequestBasic.uploadInfo(EncodedUploadData: EncodedUploadData)
    }
}



extension EditPostViewController {
    @objc func goBack(_ sender: UIBarButtonItem){
        print("go Back tourhced")
        self.navigationController?.popViewController(animated: true)
    }
}

extension EditPostViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].categoryName
    }
}


extension EditPostViewController: UITextViewDelegate{
    
        
        
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
                textView.text = "Your Text Post"
                textView.textColor = UIColor.lightGray
            }
        }
}

extension EditPostViewController {
    func setBar(){
        let backButtonView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(origin: .zero, size: CGSize(width: 50, height: 50))
        backButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        backButton.addTarget(self, action: #selector(goBack(_:)), for: .touchUpInside)
        backButtonView.addSubview(backButton)
        
        
        let postButton = UIButton(type: .system)
        postButton.setTitle("Post  ", for: .normal) // right margin 때문에 억지로 이렇게함. 수정 필요
        postButton.setTitleColor(MyColor.rudderPurple, for: .normal)
        postButton.addTarget(self, action: #selector(touchUpPostButton(_:)), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: postButton)
    }
    
}

