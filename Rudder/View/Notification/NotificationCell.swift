//
//  NotificationCell.swift
//  Rudder
//
//  Created by 박민호 on 2022/02/21.
//

import UIKit

class NotificationCell : UITableViewCell {
    
    @IBOutlet weak var notificationCategory: UILabel!
    @IBOutlet weak var notificationBody: UITextView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension NotificationCell {
    func configure(notification: UserNotification, tableView: UITableView, indexPath: IndexPath) {
        
        //이부분 enum으로 바꾸자
        
        if notification.notificationType == 1 { self.notificationCategory.text = "New Comment" }
        else if notification.notificationType == 2 { self.notificationCategory.text = "New Quick Mail" }
        else if notification.notificationType == 3 { self.notificationCategory.text = "New Reply"}
        
        self.notificationBody.text = notification.itemBody
        self.timeAgoLabel.text = Utils.timeAgo(postDate: notification.itemTime)
    }
}

