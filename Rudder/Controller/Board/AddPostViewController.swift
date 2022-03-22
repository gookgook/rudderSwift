//
//  AddPostViewController.swift
//  Rudder
//
//  Created by Brian Bae on 18/08/2021.
//

import UIKit

class AddPostViewController: UIViewController{ //textview.isEmpty placeholder떄문에 작동안함
    
    var delegate: DoRefreshDelegate?
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var addPostView: UIView!
    
    @IBOutlet weak var showPicker: UITextField!
    @IBOutlet weak var postBodyView: UITextView!
    
    
    let pickerView = UIPickerView()
   
    let imagePicker = UIImagePickerController()
    var goImage: UIImage! = nil
    var photoType: String!
    
    private var categories: [Category] = []
    private var currentCategoryId = -1
}

extension AddPostViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        hideKeyboardWhenTappedAround()
        
        postBodyView.tintColor = MyColor.rudderPurple
        
        placeholderSetting()
        setCategoryPicker()
        setBar()
        setImagePicker()
        //self.categoryScrollView.rightAnchor.constraint(equalTo: self.lastButtonAnchor, constant: 50).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showPicker.isEnabled = false
        requestCategory()
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.isHidden = true
    }
}

//add post
extension AddPostViewController{
    @objc func touchUpPostButton(_ sender: UIButton){
        guard currentCategoryId != -1 else {
            Alert.showAlert(title: "Choose a Category", message: nil, viewController: self)
            return
        }
        
        print("Post Touched")
        guard let postBody: String = self.postBodyView.text,
              postBody != "Your Text Post" else {
            Alert.showAlert(title: "One or more fields is blank", message: nil, viewController: self)
            return
        }
        guard let postBody: String = self.postBodyView.text,
              postBody.isEmpty == false else {
            return
        }
        spinner.startAnimating()
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        RequestAddPost.uploadInfo(boardType: "bulletin", postBody: postBody, categoryId: currentCategoryId, completion: {
            postId in
            
            self.delegate?.doRefreshChange()
            // TmpViewController.doRefresh = true ******protocol로 변환 필요 *********
            guard postId != -1 else {
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                }
                print("addPost error first stage")
                DispatchQueue.main.async {self.spinner.stopAnimating()}
                return
            }
            guard self.goImage != nil else {
                print("no image to add")
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                    self.navigationController?.popViewController(animated: true)
                    
                }
                return
            }
            guard self.photoType != "unsupported" && self.photoType != nil else {
                print("only jpeg and png supported")
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                    self.navigationController?.popViewController(animated: true)
                    
                }
                return
            }
            RequestPhotoUrl.uploadInfo(postId: postId, photoType: self.photoType, completion: {
                urls in
                guard urls != nil else {
                    print("photo url error")
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.navigationController?.navigationBar.isUserInteractionEnabled = true
                        self.navigationController?.popViewController(animated: true)
                    }
                    return
                }
                RequestPhotoUpload.uploadInfo(photoURL: urls![0], photoData: self.goImage.jpegData(compressionQuality: 0)!, completion: {
                    status in
                    print(status)
                    if status == -1 {
                        print("photo upload error")
                    }
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.navigationController?.navigationBar.isUserInteractionEnabled = true
                        self.navigationController?.popViewController(animated: true)
                        
                    }
                })
                
            })
            
        })
    }
}


extension AddPostViewController {
    @objc private func requestCategory() {
        
        RequestSelectedCategory.categories { (categories: [Category]?) in
            
            if let categories = categories {
                self.categories = categories
                self.showPicker.isEnabled = true
            }
            
        }
    }
}


extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func setImagePicker(){
        self.imagePicker.sourceType = .photoLibrary // 앨범에서 가져옴
            self.imagePicker.allowsEditing = true // 수정 가능 여부
            self.imagePicker.delegate = self // picker delegate
    }
}


extension AddPostViewController {
    @objc func goBack(_ sender: UIBarButtonItem){
        print("go Back tourhced")
        self.navigationController?.popViewController(animated: true)
    }
}


extension AddPostViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
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

extension AddPostViewController {
    
    @objc func done(){
        
        showPicker.text = categories[pickerView.selectedRow(inComponent: 0)].categoryName
        currentCategoryId = categories[pickerView.selectedRow(inComponent: 0)].categoryId
        showPicker.endEditing(true)
    }
}

extension AddPostViewController {
    @IBAction func pickImage(_ sender: UIButton){
        self.present(self.imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
        var newImage: UIImage? = nil // update 할 이미지
            
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = possibleImage // 수정된 이미지가 있을 경우
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = possibleImage // 원본 이미지가 있을 경우
        }
            
            //self.profileImageView.image = newImage // 받아온 이미지를 update
        picker.dismiss(animated: true, completion: nil) // picker를 닫아줌
    

        let imageView = UIImageView(image: newImage!)
        imageView.frame = CGRect(x: postBodyView.frame.origin.x, y: postBodyView.frame.origin.y + postBodyView.frame.height + 60, width: 120, height: 120)

        addPostView.addSubview(imageView)
        goImage = newImage
        
        let imageURL: NSURL = info[UIImagePickerController.InfoKey.imageURL] as! NSURL
        let imageString = imageURL.absoluteString
        print(imageString!.suffix(4))
        
        if imageString!.suffix(4) == "jpeg" {
            photoType = "image/jpeg"
        } else if imageString!.suffix(4) == ".png" {
            photoType = "image/png"
        } else {
            photoType = "unsupported"
        }
        
        
        //let mimeType = .mime
    }
    
    
}






extension AddPostViewController: UITextViewDelegate{
    func placeholderSetting() {
            postBodyView.delegate = self // txtvReview가 유저가 선언한 outlet
            postBodyView.text = "Your Text Post"
            postBodyView.textColor = UIColor.lightGray
            
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
                textView.text = "Your Text Post"
                textView.textColor = UIColor.lightGray
            }
           // self.postBodyView.rightAnchor.constraint(equalTo: self.lastButtonAnchor, constant: 50).isActive = true
        }
}

extension AddPostViewController {
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
    
    func setCategoryPicker(){
        showPicker.tintColor = .clear
        showPicker.text = "Select"
        showPicker.borderStyle = .none
        
        pickerView.delegate = self
        showPicker.inputView = pickerView
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let tmpBarButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(self.done))
        tmpBarButton.tintColor = MyColor.rudderPurple
        let button = tmpBarButton
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        showPicker.inputAccessoryView = toolBar
    }
}

extension AddPostViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
