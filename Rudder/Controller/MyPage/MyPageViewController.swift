//
//  MyPageViewController.swift
//  Rudder
//
//  Created by Brian Bae on 01/09/2021.
//

import UIKit

class MyPageViewController: UIViewController {

    @IBOutlet weak var characterView: UIImageView!
    
    @IBOutlet weak var nickNameButton: ButtonView!
    @IBOutlet weak var contactUsButton: ButtonView!
    @IBOutlet weak var agreementButton: ButtonView!
    @IBOutlet weak var categoryButton: ButtonView!
    @IBOutlet weak var characterButton: ButtonView!
    @IBOutlet weak var myPostCommentButton: ButtonView!
    @IBOutlet weak var logoutButton: ButtonView!
    
    var myPostOrComment: Int!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        setBar()
        addGesturesToButton()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        setBarStyle()
        getCharacter()
    }
}

extension MyPageViewController {
    func addGesturesToButton(){
        nickNameButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchUpNicknameButton(_:))))
        contactUsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchUpContactButton(_:))))
        agreementButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchAgreementButton(_:))))
        categoryButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchUpCategoryButton(_:))))
        characterButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchUpChangeCharacterButton(_:))))
        myPostCommentButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchUpMyPostButton(_:))))
        logoutButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchUpLogoutButton(_:))))
    }
}

extension MyPageViewController{
    @objc func touchAgreementButton(_ sender: UIButton){
        self.performSegue(withIdentifier: "GoAgreement", sender: nil)
    }
    @objc func touchUpContactButton(_ sender: UIButton){
        self.performSegue(withIdentifier: "GoFeedback", sender: nil)
    }
    @objc func touchUpLogoutButton(_ sender: UIButton){
        print("logout touched")
        //UserDefaults.standard.removeObject(forKey: "token")
        Alert.showAlertWithCB(title: "Are you sure you want to logout?", message: nil, isConditional: true, viewController: self, completionBlock: {status in
            if status {
                TmpViewController.doLogout = true
                self.tabBarController?.selectedIndex = 0
            }
        })
        //self.navigationController?.popToRootViewController(animated: true) 
    }
    @objc func touchUpCategoryButton(_ sender: UIButton){
        self.performSegue(withIdentifier: "GoCategory", sender: nil)
    }
    
    @objc func touchUpNicknameButton(_ sender: UIButton){
        self.performSegue(withIdentifier: "GoNickname", sender: nil)
    }
    
    @objc func touchUpChangeCharacterButton(_ sender: UIButton){
        self.performSegue(withIdentifier: "GoCharacterChange", sender: nil)
    }
    
    @objc func touchUpMyPostButton(_ sender: UIButton){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let myPostAction = UIAlertAction(title: "My Post", style: .default, handler: { action in
            print("MyPost called")
            self.myPostOrComment = 0
            self.performSegue(withIdentifier: "GoMyPost", sender: sender)
        })
        
        let myCommentAction = UIAlertAction(title: "My Comment", style: .default, handler: { action in
            print("MyCOmment called")
            self.myPostOrComment = 1
            self.performSegue(withIdentifier: "GoMyPost", sender: sender)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(myPostAction)
        actionSheet.addAction(myCommentAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
        //self.performSegue(withIdentifier: "GoMyPost", sender: nil)
    }
}

extension MyPageViewController {
    func getCharacter(){
        print("getCharacterCalled")
        RequestMyCharacter.uploadInfo(completion: {
            url in
            if url == "server error" {
                print("server error")
                return
            }
            self.downloadImage(from: URL(string: url)!)
            
        })
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL) {
        print("downloadImage called")
        let cacheKey: String = url.absoluteString
        if let cachedImage = ImageCache.imageCache.object(forKey: cacheKey as NSString) {
            print("already in cache")
            DispatchQueue.main.async {  //왜 이걸 붙혀야지만 되는건지는 의문 - 이곳은 안붙혀도 이미 main thread 아닌가?
                self.characterView.image = cachedImage
            }
            return
        }
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async{
                let image = UIImage(data: data)
                guard image != nil else {return }
                ImageCache.imageCache.setObject(image!, forKey: cacheKey as NSString)
                self.characterView.image = image
            }
        }
    }
}

extension MyPageViewController : DoUpdateCharacterDelegate {
    func doUpdateCharacter() {
        getCharacter()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoCharacterChange" {
            guard let changeCharacterViewController: ChangeCharacterViewController =
                segue.destination as? ChangeCharacterViewController else {
                return
            }
            changeCharacterViewController.delegate = self
        }else if segue.identifier == "GoMyPost" {
            guard let myPostCommentViewController: MyPostCommentViewController =
                segue.destination as? MyPostCommentViewController else {
                return
            }
            myPostCommentViewController.myPostOrComment = myPostOrComment //0이 post 1이 comment
        }

    }
}




extension MyPageViewController {
    func setBar(){
        self.navigationItem.hidesBackButton = true
        let label = UILabel()
        label.text = " My Page"
        label.textAlignment = .left
        label.font = UIFont(name: "SF Pro Text Bold", size: 20)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    }
    
    func setBarStyle(){
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.backgroundColor = UIColor.white
        
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .white
       // self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
}



//tmp for tmpView
extension MyPageViewController{
    @objc func tappedconcern1(_ gesture: UITapGestureRecognizer) {
        print("tmp view touched")
    }
}
