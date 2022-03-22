//
//  CommunityBoardCell.swift
//  Rudder
//
//  Created by Brian Bae on 14/07/2021.
//

import UIKit

protocol CommunityBoardCellDelegate { //이거 필요 없을지도
    func CommunityBoardCellStateChanged(_ sender: CommunityBoardCell)
}

class CommunityBoardCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    @IBOutlet weak var postBodyView: UITextView!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var moreMenuButton: UIButton!
    
    @IBOutlet weak var characterView: UIImageView!
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var photoCountLabel: UILabel!
    
    private var isMine: Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
 
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension CommunityBoardCell{
    
    func configure(post: Post, tableView: UITableView, indexPath: IndexPath) {
        
        self.categoryLabel.text = post.categoryAbbreviation
        self.userNicknameLabel.text = post.userNickname
        
        if post.isLiked == true {
            likeButton.setImage(UIImage(named: "like_purple"), for: .normal)
        } else {
            likeButton.setImage(UIImage(named: "like"), for: .normal)
        }
        
        self.timeAgoLabel.text = Utils.timeAgo(postDate: post.timeAgo)
        
        self.postBodyView.text = post.postBody
        
        self.likeCountLabel.text = String(post.likeCount)
        self.commentCountLabel.text = String(post.commentCount)
        
        if post.imageUrls.count == 0 {
            self.photoView.image = nil
            self.photoCountLabel.text = nil
        } else {
            self.photoView.image = UIImage(systemName: "photo")
            self.photoCountLabel.text = String(post.imageUrls.count)
        }
        
        self.isMine = post.isMine
        
        
    }
}
