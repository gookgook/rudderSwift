//
//  SignUpViewController.swift
//  Rudder
//
//  Created by Brian Bae on 30/07/2021.
//

import UIKit

class SignUpViewController: UIViewController{
    
    @IBOutlet weak var scollView: UIScrollView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var userIdField: UITextField!
    @IBOutlet weak var userPasswordField: UITextField!
    @IBOutlet weak var userPasswordCheckField: UITextField!
    @IBOutlet weak var recommendationCodeField: UITextField!
    
    @IBOutlet weak var emailHeadField: UITextField!
    @IBOutlet weak var emailTailField: UITextField!
    @IBOutlet weak var verificationCodeField: UITextField!
    
    @IBOutlet weak var passwordImage: UIImageView!
    @IBOutlet weak var passwordCheckImage: UIImageView!
    @IBOutlet weak var IdImage: UIImageView!
    @IBOutlet weak var recommendationImage: UIImageView!
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    private var fCurTextfieldBottom: CGFloat = 0.0
    private var originalY: CGFloat!
    private var originalOffset: CGFloat!
    
    
    var universityId: Int!
    var submitActive: Bool = false
    var isFinished = IsFinished(id: false, password: false, passwordcheck: false, emailHead: false, emailTail: false)
    
    
   
}

extension SignUpViewController {
    
    @IBAction func touchUpCheckDuplicationButton(_ sender: UIButton){
        guard userIdField.text!.count != 0 else{
            showAlert(message: "ID field empty")
            return
        }
        
        let idInfo = IdInfo(userId: userIdField.text!)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(idInfo) else {
             return
         }
        
        spinner.startAnimating()
        
        RequestBasic.checkIdDuplication(EncodedUploadData: EncodedUploadData, completion: {
            status in
            DispatchQueue.main.async {self.spinner.stopAnimating()}
           // DispatchQueue.main.async {self.spinner.stopAnimating()}
            if status == 1 {
                DispatchQueue.main.async {
                    self.showAlert(message: "ID already exists")
                    self.IdImage.image = UIImage(named: "xCheck")
                }
            }
            if status == 2 {
                self.IdImage.image = UIImage(named: "check")
                self.isFinished.id = true
            }
            self.verifyButtonChange()
        })
    }
    
    @IBAction func touchUpVerifyButton(_ sender: UIButton){
        print("verify button touched")
        spinner.startAnimating()
        let email = emailHeadField.text! + "@" + emailTailField.text!
        RequestEmailVerify.uploadInfo(email: email, schoolId: universityId, completion: {
            status in
            DispatchQueue.main.async {self.spinner.stopAnimating()}
            if status == 1 {
                DispatchQueue.main.async {
                    Alert.showAlert(title: "This app is specifically restricted for the members of the university. We have sent the verification code to your university email so that you can enter our comunity", message: nil, viewController: self)
                    self.verificationCodeField.layer.borderWidth = 1.0
                    self.verificationCodeField.layer.borderColor = MyColor.rudderPurple.cgColor
                    self.submitActive = true
                }
            }else if status == 0 {
                DispatchQueue.main.async {Alert.showAlert(title: "Please enter your valid university email", message: nil, viewController: self)}
                print("Wrong Email")
            }else if status == -1 {
                print("server error")
            }
        })
    }
    
    @IBAction func touchUpSubmitButton(_ sender: UIButton){
        spinner.startAnimating()
        let email = emailHeadField.text! + "@" + emailTailField.text!
        RequestCheckCode.uploadInfo(email: email, verifyCode: verificationCodeField.text!, completion: {
            status in
            DispatchQueue.main.async {self.spinner.stopAnimating()}
            if status == 1{
                DispatchQueue.main.async {
                    Alert.showAlert(title: "Success!", message: nil, viewController: self)
                    self.signUpButton.backgroundColor = MyColor.rudderPurple
                    self.signUpButton.isEnabled = true
                }
            }else if status == 0{
                DispatchQueue.main.async {Alert.showAlert(title: "Wrong code", message: nil, viewController: self)}
                print("Wrong Code")
            }else if status == -1 {
                print("Server error")
            }
        })
    }
    
    @IBAction func touchUpNextButton(_ sender: UIButton){
        print("nextButton touched")
        self.performSegue(withIdentifier: "GoSignUp3", sender: nil)
    }
    
    
}

extension SignUpViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalY = self.scollView.frame.origin.y
        originalOffset = self.scollView.contentOffset.y
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        checkButton.isEnabled = false
        checkButton.backgroundColor = MyColor.superLightGray
        
        verifyButton.isEnabled = false
        verifyButton.backgroundColor = MyColor.superLightGray
        
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = MyColor.superLightGray
        
        setBar()
        
        print("universityId: "+String(universityId))
        IdImage.image = nil
        passwordImage.image = nil
        passwordCheckImage.image = nil
        recommendationImage.image = UIImage(named: "check")
        
        submitButton.layer.borderWidth = 1.0
        submitButton.layer.borderColor = MyColor.superLightGray.cgColor
        
        userIdField.delegate = self
        userPasswordField.delegate = self
        userPasswordCheckField.delegate = self
        emailHeadField.delegate = self
        emailTailField.delegate = self
        verificationCodeField.delegate = self
        
        userIdField.addTarget(self, action: #selector(self.userIdFieldChanged), for: .editingChanged)
        userPasswordField.addTarget(self, action: #selector(self.userPasswordFieldChanged), for: .editingChanged)
        userPasswordCheckField.addTarget(self, action: #selector(self.userPasswordCheckFieldChanged), for: .editingChanged)
        emailHeadField.addTarget(self, action: #selector(self.emailHeadFieldChanged), for: .editingChanged)
        emailTailField.addTarget(self, action: #selector(self.emailTailFieldChanged), for: .editingChanged)
        verificationCodeField.addTarget(self, action: #selector(self.verificationCodeFieldChanged), for: .editingChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBarStyle()
    }
}


//textfield 변화 때 할 행동들
extension SignUpViewController {
    @objc private func userIdFieldChanged(_ textField: UITextField) {
        somethingChanged()
        
        if textField.text!.count == 0 {
            checkButton.isEnabled = false
            checkButton.backgroundColor = MyColor.superLightGray
        }else{
            checkButton.isEnabled = true
            checkButton.backgroundColor = MyColor.rudderPurple
        }
        isFinished.id = false
        IdImage.image = nil
        verifyButtonChange()
    }
    @objc private func userPasswordFieldChanged(_ textField: UITextField) {
        
        somethingChanged()
        
        isFinished.password = false
        if (textField.text!.count == 0){
            passwordImage.image = nil
        }else if (textField.text!.count<8){
            passwordImage.image = UIImage(named: "xCheck")
            self.showToast(message: "Your Password must be at least 8 character long", font: .systemFont(ofSize: 12.0))
        }else{
            isFinished.password = true
            self.showToast(message: "success", font: .systemFont(ofSize: 12.0))
            passwordImage.image = UIImage(named: "check")
        }
        verifyButtonChange()
    }
    
    @objc private func userPasswordCheckFieldChanged(_ textField: UITextField) {
        
        somethingChanged()
        
        isFinished.passwordcheck = false
        if (textField.text!.count == 0){
            passwordCheckImage.image = nil
        }else if (textField.text! != userPasswordField.text!){
            passwordCheckImage.image = UIImage(named: "xCheck")
            self.showToast(message: "Password doesn't match", font: .systemFont(ofSize: 12.0))
        }else{
            isFinished.passwordcheck = true
            self.showToast(message: "sucess", font: .systemFont(ofSize: 12.0))
            passwordCheckImage.image = UIImage(named: "check")
        }
        verifyButtonChange()
    }
    @objc private func emailHeadFieldChanged(_ textField: UITextField) {
        
        somethingChanged()
        
        if textField.text!.count == 0 {
            isFinished.emailHead = false
        }else{
            isFinished.emailHead = true
        }
        verifyButtonChange()
    }
    @objc private func emailTailFieldChanged(_ textField: UITextField) {
        
        somethingChanged()
        
        if textField.text!.count == 0 {
            isFinished.emailTail = false
        }else{
            isFinished.emailTail = true
        }
        verifyButtonChange()
    }
}

extension SignUpViewController {
    private func verifyActive() -> Bool{
        if isFinished.id == true && isFinished.password == true && isFinished.emailHead == true && isFinished.emailTail == true {
            return true
        }else{
            return false
        }
    }
    private func verifyButtonChange(){
        verifyButton.isEnabled = verifyActive()
        if verifyActive() { verifyButton.backgroundColor = MyColor.rudderPurple }
        else { verifyButton.backgroundColor = MyColor.superLightGray }
    }
    
    @objc private func verificationCodeFieldChanged(_ textField: UITextField) {  //이것을 verify가 다 되었을때만1!!
        if textField.text!.count != 0 && submitActive == true{
            submitButton.isEnabled = true
            submitButton.tintColor = MyColor.rudderPurple
            submitButton.layer.borderColor = MyColor.rudderPurple.cgColor
        }else{
            submitButton.isEnabled = false
            submitButton.tintColor = UIColor.lightGray
            submitButton.layer.borderColor = MyColor.superLightGray.cgColor
        }
    }
    
    private func somethingChanged(){
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = MyColor.superLightGray
        submitButton.isEnabled = false
        submitButton.backgroundColor = UIColor.white
        submitButton.layer.borderColor = MyColor.superLightGray.cgColor
        verificationCodeField.layer.borderColor = MyColor.superLightGray.cgColor
    }
}

extension SignUpViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let setProfileViewController: SetProfileViewController =
            segue.destination as? SetProfileViewController else {
            return
        }
        setProfileViewController.userEmail = emailHeadField.text! + "@" + emailTailField.text!
        setProfileViewController.universityId = universityId
        setProfileViewController.userId = userIdField.text!
        setProfileViewController.userPassword = userPasswordField.text!
        guard recommendationCodeField.text!.count != 0 else {
            setProfileViewController.recommendationCode = "dummy code"
            return
        }
        setProfileViewController.recommendationCode = recommendationCodeField.text!
    }
}


extension SignUpViewController {

    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 140, y: self.view.frame.origin.x+120/*self.view.frame.size.height-100*/, width: 280, height: 35))
        toastLabel.backgroundColor = MyColor.rudderPurple
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }

extension SignUpViewController {
    struct IdInfo: Codable {
        let userId: String //변수이름바꾸기!!!!!!!!!!!!!!!!!!!!!!!
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
        }
        
    }
    struct IsFinished {
        var id: Bool
        var password: Bool
        var passwordcheck: Bool
        var emailHead: Bool
        var emailTail: Bool
    }
}

extension SignUpViewController{
    private func showAlert(message: String){
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
            return
        
    }
}
















//bar
extension SignUpViewController{
    func setBar(){
        self.navigationItem.hidesBackButton = true
        let label = UILabel()
        label.text = " Sign Up"
        label.textAlignment = .left
        label.font = UIFont(name: "SF Pro Text Bold", size: 20)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        
        let backButtonView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(origin: .zero, size: CGSize(width: 40, height: 40))
        backButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        backButton.addTarget(self, action: #selector(goBack(_:)), for: .touchUpInside)
        backButtonView.addSubview(backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backButtonView)
        
    }
    
    func setBarStyle(){
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .white
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    @objc func goBack(_ sender: UIBarButtonItem){
        print("go Back touched")
        self.navigationController?.popViewController(animated: true)
    }
}

extension SignUpViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}



//keyboard aware
extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("didbegin")
           fCurTextfieldBottom = textField.frame.origin.y + textField.frame.height
       }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        print("keyboardwillshow")
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if fCurTextfieldBottom <= self.scollView.frame.height - keyboardSize.height {
                return
            }
            let cp = CGPoint(x: 0, y: keyboardSize.height + originalOffset)
            if self.scollView.contentOffset.y == originalOffset {
                scollView.setContentOffset(cp, animated: true)
            }
        }
        
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        print("willresign")
        if scollView.contentOffset.y != originalOffset{
            scollView.contentOffset.y = originalOffset
        }
    }
}
