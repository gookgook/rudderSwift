//
//  SetProfileViewController.swift
//  Rudder
//
//  Created by Brian Bae on 09/09/2021.
//
import UIKit

class SetProfileViewController: UIViewController {
    
    @IBOutlet weak var nicknameField: UITextField!
    
    @IBOutlet weak var nicknameImage: UIImageView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var universityId: Int!
    var userId: String!
    var userPassword: String!
    var userEmail: String!
    var recommendationCode: String!
    
    static var charId: Int!
    static var chUrl: String!
    
    static var didPick: Bool!
    var didNickname: Bool!
}

extension SetProfileViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        signUpButton.backgroundColor = MyColor.superLightGray
        signUpButton.isEnabled = false
        didNickname = false
        SetProfileViewController.didPick = false
        setBar()
        nicknameImage.image = nil
        nicknameField.addTarget(self, action: #selector(self.nicknameFieldChanged), for: .editingChanged)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setBarStyle()
        if SetProfileViewController.didPick == true {
            setCharacter()
        }
    }

}

extension SetProfileViewController {
    @IBAction func touchUpSignUpButton(_ sender: UIButton){
        spinner.startAnimating()
        
        let signupInfo = SignUpInfo(userId: userId, userPassword: userPassword, email: userEmail, recommendationCode: recommendationCode, schoolId: universityId, profileBody: "dummy profile", userNickname: nicknameField.text!, characterId: SetProfileViewController.charId)
        print(signupInfo)
        
        RequestSignUp.uploadInfo(signupInfo: signupInfo, completion: {
            status in
            DispatchQueue.main.async {self.spinner.stopAnimating()}
            if status == 1 {
                DispatchQueue.main.async {
                    Alert.showAlertWithCB(title: "Welcome!", message: nil, isConditional: false, viewController: self, completionBlock: {_ in
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                    //Alert.showAlert(title: "Welcome!", message: nil, viewController: self)
                    
                }
            }
            if status == -1 {
                DispatchQueue.main.async {
                    Alert.showAlert(title: "Server Error", message: nil, viewController: self)
                    //self.showAlert(message: "Wrong")
                }
            }
        })
    }
}

extension SetProfileViewController {
    @IBAction func touchUpChooseButton(_ sender: UIButton){
        self.performSegue(withIdentifier: "GoPickCharacter", sender: nil)
    }
    
    func setCharacter(){
        guard let stringUrl = SetProfileViewController.chUrl else {return}
        guard let url = URL(string: stringUrl) else {return}
        let cacheKey: String = url.absoluteString
        if let cachedImage = ImageCache.imageCache.object(forKey: cacheKey as NSString) {
            DispatchQueue.main.async {
                self.chooseButton.setBackgroundImage(cachedImage, for: .normal)
                self.chooseButton.setImage(nil, for: .normal)
            }
        }else{
            getData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                // always update the UI from the main thread
                DispatchQueue.main.async{
                    let image = UIImage(data: data)
                    guard image != nil else {return }
                    ImageCache.imageCache.setObject(image!, forKey: cacheKey as NSString)
                    self.chooseButton.setBackgroundImage(image, for: .normal)
                    self.chooseButton.setImage(nil, for: .normal)
                    if self.didFinish() {
                        self.signUpButton.backgroundColor = MyColor.rudderPurple
                        self.signUpButton.isEnabled = true
                    }
                }
            }
        }
        if didFinish() {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = MyColor.rudderPurple
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}

extension SetProfileViewController {
    @IBAction func touchUpCheckDuplicationButton(_ sender: UIButton){
        guard nicknameField.text!.count != 0 else{
            showAlert(message: "Nickname empty")
            return
        }
        
        spinner.startAnimating()
        RequestCheckNickname.checkDuplication(nickname: nicknameField.text!, completion: {
            status in
            
            DispatchQueue.main.async {self.spinner.stopAnimating()}
            if status == 1 {
                DispatchQueue.main.async {
                    self.showAlert(message: "Nickname already exists")
                    self.nicknameImage.image = UIImage(named: "xCheck")
                }
            }
            if status == 2 {
                self.didNickname = true
                self.nicknameImage.image = UIImage(named: "check")
                if self.didFinish() {
                    self.signUpButton.backgroundColor = MyColor.rudderPurple
                    self.signUpButton.isEnabled = true
                }
            }
        })
    }
}

extension SetProfileViewController {
    @objc private func nicknameFieldChanged(_ textField: UITextField) {
        //somethingChanged()
        nicknameImage.image = nil
        didNickname = false
        self.signUpButton.backgroundColor = MyColor.superLightGray
        self.signUpButton.isEnabled = false
        
        if nicknameField.text!.count == 0 {
            checkButton.isEnabled = false
            checkButton.backgroundColor = MyColor.superLightGray
        }else{
            checkButton.isEnabled = true
            checkButton.backgroundColor = MyColor.rudderPurple
        }
    }
    
    func didFinish() -> Bool {
        return (SetProfileViewController.didPick && didNickname)
    }
}






extension SetProfileViewController {
    func setBar(){
        self.navigationItem.hidesBackButton = true
        let label = UILabel()
        label.text = " Profile"
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
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    @objc func goBack(_ sender: UIBarButtonItem){
        print("go Back touched")
        self.navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(message: String){
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
            return
        
    }
}

extension SetProfileViewController {
        func hideKeyboardWhenTappedAround() {
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }

        @objc func dismissKeyboard() {
            view.endEditing(true)
        }
    
}
