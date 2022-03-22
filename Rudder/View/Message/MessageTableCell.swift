//
//  MessageTableCell.swift
//  Rudder
//
//  Created by 박민호 on 2022/01/26.
//

import UIKit

class MessageTableCell : UITableViewCell {
    
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var messageBodyView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension MessageTableCell {
    func configure(messageRoom: MessageRoom, tableView: UITableView, indexPath: IndexPath) {
        
        self.userIdLabel.text = messageRoom.userId
        self.timeAgoLabel.text = Utils.timeAgo(postDate: messageRoom.messageSendTime)
        
        self.messageBodyView.text = messageRoom.postMessageBody

    }
}
