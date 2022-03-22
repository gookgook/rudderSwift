//
//  ChildCommentCell.swift
//  Rudder
//
//  Created by Brian Bae on 15/08/2021.
//

import UIKit

class ChildCommentCell: UITableViewCell {
    
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    @IBOutlet weak var commentBodyView: UITextView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    @IBOutlet weak var moreMenuButton: UIButton!
    
    @IBOutlet weak var characterView: UIImageView!
    
    var commentId: Int!
    
    var isLiked: Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

extension ChildCommentCell{
    
    func configure(comment: Comment, tableView: UITableView, indexPath: IndexPath) {
        
        self.userNicknameLabel.text = comment.userNickname
        self.timeAgoLabel.text = Utils.timeAgo(postDate: comment.timeAgo)
        
        self.commentBodyView.text = comment.commentBody
        
        self.likeCountLabel.text = String(comment.likeCount)
        
        self.commentId = comment.commentId
        self.isLiked = comment.isLiked
      
        
    }
}

extension ChildCommentCell {
    @IBAction func touchUpLikeButton(_ sender: UIButton){
        print("CommentLikeButtonTouch "+String(commentId))
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        if self.isLiked == false {
            let addLikeData = AddLikeDataComment(commentId: self.commentId, token: token, plusValue: 1)
            self.likeCountLabel.text = String(Int(self.likeCountLabel.text!)! + 1)
            self.isLiked = true
            requestAddLike(addLikeData: addLikeData)
        } else {
            let addLikeData = AddLikeDataComment(commentId: self.commentId, token: token, plusValue: -1)
            self.likeCountLabel.text = String(Int(self.likeCountLabel.text!)! - 1)
            self.isLiked = false
            requestAddLike(addLikeData: addLikeData)
        }
        
    }
    func requestAddLike(addLikeData: AddLikeDataComment){
        RequestAddLikeComment.uploadInfo(addLikeData: addLikeData, completion: {
            likeCount in
            if likeCount == -1 {
                print("addLike error")
            }
            else if likeCount >= 0 {
                print("addLike success")
                DispatchQueue.main.async {
                    self.likeCountLabel.text = String(likeCount)
                }
            }
        })
    }
}
