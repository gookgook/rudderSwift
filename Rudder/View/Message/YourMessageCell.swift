//
//  YourMessage.swift
//  Rudder
//
//  Created by 박민호 on 2022/02/03.
//

import UIKit

class YourMessageCell : UITableViewCell {
    
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var messageBodyView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension YourMessageCell {
    func configure(message: Message, tableView: UITableView, indexPath: IndexPath) {
        
        self.timeAgoLabel.text = Utils.timeAgo(postDate: message.messageSendTime)
        
        self.messageBodyView.text = message.postMessageBody

    }
}
