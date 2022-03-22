//
//  MessageRoomViewController.swift
//  Rudder
//
//  Created by 박민호 on 2022/01/24.
//

import UIKit

class MessageRoomViewController: UIViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet weak var messageRoomTableView: UITableView!
    
    private var messageRooms: [MessageRoom] = []

    var infiniteScrollNow: Bool = false
    var banInfinite: Bool = true
    
    private var receiveUserInfoId : Int!// Noti에서 온거 용. 이걸 여기다 하는게 맞나
    private var postMessageRoomId: Int! // 위와동일
    
    var indexPathForSelectedRow: NSIndexPath!
    
}

extension MessageRoomViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let k_resetToTopViewForYourTabNotification = Notification.Name("resetToTopViewForYourTabNotification") //이거이름재설정 필요
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetToTopView(notification:)), name: k_resetToTopViewForYourTabNotification, object: nil)
        let k_fromNotiToMessageRoom = Notification.Name("fromNotiToMessageRoom")
        NotificationCenter.default.addObserver(self, selector: #selector(self.fromNotiToMessageRoom(notification:)), name: k_fromNotiToMessageRoom, object: nil)
        
        setBar()
    
        
        requestMessageRooms()
        
        let cellNib: UINib = UINib.init(nibName: "MessageTableCell", bundle: nil)
        
        self.messageRoomTableView.register(cellNib,
                                       forCellReuseIdentifier: "messageTableCell")
        
        let refreshControl: UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadMessageRooms),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = MyColor.rudderPurple
        
        self.messageRoomTableView.refreshControl = refreshControl
        self.messageRoomTableView.estimatedRowHeight = 200 //autolatyout 잘 작동하게 대략적인 높이?
        self.messageRoomTableView.rowHeight = UITableView.automaticDimension
    }
    override func viewWillAppear(_ animated: Bool){
        
        self.tabBarController?.tabBar.isHidden = false
        
        if let selectedRow = indexPathForSelectedRow { //hightlight 지우기
            messageRoomTableView.deselectRow(at: selectedRow as IndexPath, animated: true)
        }
    }
}

extension MessageRoomViewController {
    @objc private func requestMessageRooms() { //endmessageId 처리하기 서버담당자에게 요청
      
        if let isRefreshing: Bool = self.messageRoomTableView.refreshControl?.isRefreshing,
            isRefreshing == false {
           // self.showSpinner()
        }
        
        RequestMessageRooms.messageRooms() { ( messageRooms: [MessageRoom]?) in
            
            if let messageRooms = messageRooms {
                if messageRooms.count == 0 {
                    Alert.showAlert(title: "No message Rooms", message: nil, viewController: self)
                    //self.banInfinite = true
                }
                
                if self.infiniteScrollNow == true { self.messageRooms += messageRooms }
                else{ self.messageRooms = messageRooms }
                
                self.messageRoomTableView.reloadSections(IndexSet(0...0),
                                              with: UITableView.RowAnimation.automatic)
            }
            self.infiniteScrollNow = false
            if let refreshControl: UIRefreshControl = self.messageRoomTableView.refreshControl,
                refreshControl.isRefreshing == true {
                refreshControl.endRefreshing()
            } else {
               // self.hideSpinner()
            }
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true
                self.spinner.stopAnimating()
            }
        }
    }
    @objc private func reloadMessageRooms(){
        //endPostId = -1
        banInfinite = false
        requestMessageRooms()
    }
}

extension MessageRoomViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: MessageTableCell
        cell = tableView.dequeueReusableCell(withIdentifier: "messageTableCell",
                                             for: indexPath) as! MessageTableCell
        // cell.delegate = self
        
        guard indexPath.row < messageRooms.count else {
            return cell
        }
        
        let messageRoom: MessageRoom = messageRooms[indexPath.row]
        
        //endPostId = post.postId
        
        cell.configure(messageRoom: messageRoom, tableView: tableView, indexPath: indexPath)
        cell.tag = messageRoom.postMessageRoomId
     
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell: UITableViewCell = tableView.cellForRow(at: indexPath) {
            indexPathForSelectedRow = indexPath as NSIndexPath
            self.performSegue(withIdentifier: "ShowMessageRoom", sender: cell)
            //indexPathForSelectedRow = indexPath as NSIndexPath
           // cell.selectionStyle = .none
        }
    }
}

extension MessageRoomViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMessageRoom" {
            guard let messageViewController: MessageViewController =
                segue.destination as? MessageViewController else {
                    return
            }
            guard let cell: MessageTableCell = sender as? MessageTableCell else {
                return
            }
            guard let index: IndexPath = self.messageRoomTableView.indexPath(for: cell) else {
                return
            }
            
            /*guard index.row < TmpViewController.posts.count else { return }*/
            
            messageViewController.postMessageRoomId = messageRooms[index.row].postMessageRoomId
            messageViewController.delegate = self
        }
        
        if segue.identifier == "GoSendMessageDirect" {
            guard let sendMessageViewController: SendMessageViewController =
                segue.destination as? SendMessageViewController else {
                    return
            }
            sendMessageViewController.receiveUserInfoId = receiveUserInfoId
            sendMessageViewController.directDelegate = self
        }
        
        if segue.identifier == "ShowMessageRoomFromNoti" {
            guard let messageViewController: MessageViewController =
                segue.destination as? MessageViewController else {
                    return
            }
            messageViewController.postMessageRoomId = postMessageRoomId
            messageViewController.delegate = self
        }
    }
}

extension MessageRoomViewController: DoUpdateMessageRoomDelegate, DoUpdateMessageDirectDelegate{
    func doUpdateMessageRoom() {
        reloadMessageRooms()
    }
    func doUpdateMessageDirect() {
        reloadMessageRooms()
    }
    
    @objc func resetToTopView(notification: NSNotification){
        _ = navigationController?.popToViewController(self, animated: true)
        print("go send message direct hit")
        receiveUserInfoId = notification.userInfo!["receiveUserInfoId"] as? Int//!를 너무많이쓰는중
        self.performSegue(withIdentifier: "GoSendMessageDirect", sender: nil)
        print("go send message direct success")
    }
    @objc func fromNotiToMessageRoom(notification: NSNotification){
        _ = navigationController?.popToViewController(self, animated: true)
        postMessageRoomId = notification.userInfo!["postMessageRoomId"] as? Int // 여기도 !를 너무 많이쓰는중
        self.performSegue(withIdentifier: "ShowMessageRoomFromNoti", sender: nil)
        print("goMesssgeRoomFromNotiSuccess")
    }
    
    func setBar() {
        let label = UILabel()
        label.text = " Quick Mail"
        label.textAlignment = .left
        label.font = UIFont(name: "SF Pro Text Bold", size: 20)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        
        self.navigationController?.navigationBar.tintColor = .black
        
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.backgroundColor = UIColor.white
    }
}
