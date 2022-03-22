//
//  NotificationViewController.swift
//  Rudder
//
//  Created by 박민호 on 2022/02/21.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var notificationTableView: UITableView! //noticenter에서 오는거 처리하기위한 임시 - 바꿔야함
    static var notiRefresh: Bool = false
    
    private var userNotifications : [UserNotification] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setBar()
        
        requestNotifications()
        let cellNib: UINib = UINib.init(nibName: "NotificationCell", bundle: nil)
        
        self.notificationTableView.register(cellNib,
                                       forCellReuseIdentifier: "notificationCell")
        
        let refreshControl: UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadNotifications),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = MyColor.rudderPurple
        
        self.notificationTableView.refreshControl = refreshControl
        self.notificationTableView.estimatedRowHeight = 200 //autolatyout 잘 작동하게 대략적인 높이?
        self.notificationTableView.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.isHidden = false
        
        if NotificationViewController.notiRefresh {
            print("static noti var is true")
            requestNotifications()
            NotificationViewController.notiRefresh = false
        }
        
        super.viewWillAppear(animated)
        
    }
}

extension NotificationViewController {
    @objc private func requestNotifications() {
        
        if let isRefreshing: Bool = self.notificationTableView.refreshControl?.isRefreshing,
            isRefreshing == false {
            //self.spinner.startAnimating()
        }
        
        RequestNotification.notifications () {  ( userNotifications: [UserNotification]?) in
            if let userNotifications = userNotifications {
                self.userNotifications = userNotifications
                self.notificationTableView.reloadSections(IndexSet(0...0),
                                              with: UITableView.RowAnimation.automatic)
            }
            
            if let refreshControl: UIRefreshControl = self.notificationTableView.refreshControl, //위에서 아래로 잡아끌면 새로고침하도록 도와주는것
                refreshControl.isRefreshing == true {
                refreshControl.endRefreshing()
            } else {
                //self.spinner.stopAnimating()
            }
        }
    }
    
    @objc private func reloadNotifications(){
        //endPostId = -1
        //banInfinite = false
        requestNotifications()
    }

}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: NotificationCell
        cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell",
                                             for: indexPath) as! NotificationCell
        // cell.delegate = self
        
        guard indexPath.row < userNotifications.count else {
            return cell
        }
        
        let userNotification: UserNotification = userNotifications[indexPath.row]
        
        //endPostId = post.postId
        
        cell.configure(notification: userNotification, tableView: tableView, indexPath: indexPath)
        //cell.tag = messageRoom.postMessageRoomId
     
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if userNotifications[indexPath.row].notificationType == 2 {
            let k_fromNotiToMessageRoom = Notification.Name("fromNotiToMessageRoom")
            let userInfo: [AnyHashable: Any] = ["postMessageRoomId":userNotifications[indexPath.row].itemId]
            NotificationCenter.default.post(name: k_fromNotiToMessageRoom, object: nil, userInfo: userInfo)
            self.tabBarController?.selectedIndex = 1
        } else {
            if let cell: UITableViewCell = tableView.cellForRow(at: indexPath) {
                self.performSegue(withIdentifier: "ShowPost", sender: cell)
            }
        }
        //print("aa ", indexPath.row)
    }
}

extension NotificationViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPost" {
           
           guard let cell: NotificationCell = sender as? NotificationCell else {
               return
           }
           
           guard let index: IndexPath = self.notificationTableView.indexPath(for: cell) else {
               return
           }
           
           guard index.row < userNotifications.count else { return }
           
           guard let notiPostViewController: NotiPostViewController =
               segue.destination as? NotiPostViewController else {
                   return
           }
           
           //communityPostViewController.delegate = self
           
            let userNotification: UserNotification = userNotifications[index.row]
            notiPostViewController.postId = userNotification.itemId
           
       }
    }
}

extension NotificationViewController {
    func setBar(){
        self.navigationItem.hidesBackButton = true
        let label = UILabel()
        label.text = " Notifications"
        label.textAlignment = .left
        label.font = UIFont(name: "SF Pro Text Bold", size: 20)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.backgroundColor = UIColor.white
    }
}
