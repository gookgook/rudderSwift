//
//  NotiPostViewController.swift
//  Rudder
//
//  Created by 박민호 on 2022/02/24.
//

import UIKit

class NotiPostViewController: CommunityPostViewController {
    
    //private var postId: Int!
    
    override func viewWillAppear(_ animated: Bool) {
       // super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .black
        
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.isHidden = true
        
    }
    override func viewDidLoad() {
        //super.viewDidLoad()
        requestSinglePost()
        tmpCR = 23
        //toDoViewDidLoad()
    }
}

extension NotiPostViewController {
    func requestSinglePost(){
        RequestSinglePost.singlePost(postId: postId) { (post: Post?) in
            guard post != nil else {
                Alert.showAlert(title: "Deleted Post!", message: nil, viewController: self)
                //멈추는 코드 넣어야함
                self.view.isUserInteractionEnabled = false
                return
            }
            /*guard let post: Post = self.post else {
                return
            }*/
            if let post = post {
                self.post = post
                DispatchQueue.main.async {
                    self.categoryLabel.text = post.categoryName
                    self.userNicknameLabel.text = post.userNickname
                    self.timeAgoLabel.text = Utils.timeAgo(postDate: post.timeAgo)
                    self.postBodyView.text = post.postBody
                    self.likeCountLabel.text = String(post.likeCount)
                    self.commentCountLabel.text = String(post.commentCount)
                    self.commentCountLabel2.text = "Comment ("+String(post.commentCount)+")"
                    if post.commentCount == 0 {  self.commentCountLabel2.textColor = UIColor.white}
                    else {self.commentCountLabel2.textColor = UIColor.lightGray }
                    
                    self.postId = post.postId
                    self.imageUrls = post.imageUrls
                    self.tmpCR = 10 //지워야함
                    print("hit here")
                    self.setCharacter()
                    self.toDoViewDidLoad()
                }
                
                if self.comments.isEmpty {
                    self.requestComments()
                } else {
                    self.commentTableView.reloadSections(IndexSet(0...0),
                                                  with: UITableView.RowAnimation.none)
                }
            }
        }
    }
}

