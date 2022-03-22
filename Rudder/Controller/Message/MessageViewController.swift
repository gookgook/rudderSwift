//
//  MessageViewController.swift
//  Rudder
//
//  Created by 박민호 on 2022/01/26.
//

import UIKit

class MessageViewController: UIViewController {

    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet weak var messageTableView: UITableView!
    
    var delegate: DoUpdateMessageRoomDelegate!
    
    
    @objc func touchSendMail(_ sender: UIBarButtonItem){
        print("send Mail touched")
       self.performSegue(withIdentifier: "GoSendMessage", sender: sender)
    }
    
    private var messages: [Message] = []
    
    var infiniteScrollNow: Bool = false
    var banInfinite: Bool = true
    
    var postMessageRoomId: Int!
}

extension MessageViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setBar()
        
        requestMessages()
        
        let cellNib: UINib = UINib.init(nibName: "MyMessageCell", bundle: nil)
        let yourCellNib: UINib = UINib.init(nibName: "YourMessageCell", bundle: nil)
        
        self.messageTableView.register(cellNib,
                                       forCellReuseIdentifier: "myMessageCell")
        self.messageTableView.register(yourCellNib,
                                       forCellReuseIdentifier: "yourMessageCell")
        
        let refreshControl: UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadMessages),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = MyColor.rudderPurple
        
        self.messageTableView.refreshControl = refreshControl
        self.messageTableView.estimatedRowHeight = 200 //autolatyout 잘 작동하게 대략적인 높이?
        self.messageTableView.rowHeight = UITableView.automaticDimension
    }
}

extension MessageViewController {
    @objc private func requestMessages() {
        if let isRefreshing: Bool = self.messageTableView.refreshControl?.isRefreshing,
            isRefreshing == false {
           // self.showSpinner()
        }
        
        RequestMessages.messages(postMessageRoomId: postMessageRoomId) { (messages: [Message]?) in
            
            if let messages = messages {
                if messages.count == 0 {
                    Alert.showAlert(title: "No message Rooms", message: nil, viewController: self)
                    //self.banInfinite = true
                }
                if self.infiniteScrollNow == true { self.messages += messages }
                else{ self.messages = messages }
                
                print("count ",messages.count)
                
                self.messageTableView.reloadSections(IndexSet(0...0),
                                              with: UITableView.RowAnimation.automatic)
            }
            self.infiniteScrollNow = false
            if let refreshControl: UIRefreshControl = self.messageTableView.refreshControl,
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
    @objc private func reloadMessages(){
        //endPostId = -1
        banInfinite = false
        requestMessages()
        delegate?.doUpdateMessageRoom() //확인필요
    }
}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell: MyMessageCell
        cell = tableView.dequeueReusableCell(withIdentifier: "myMessageCell",
                                             for: indexPath) as! MyMessageCell
        
        let yourCell: YourMessageCell
        yourCell = tableView.dequeueReusableCell(withIdentifier: "yourMessageCell",
                                             for: indexPath) as! YourMessageCell
        // cell.delegate = self
        
        guard indexPath.row < messages.count else {
            return cell
        }
        
        let message: Message = messages[indexPath.row]
        
        if message.isSender {
            cell.configure(message: message, tableView: tableView, indexPath: indexPath)
            return cell
        } else {
            yourCell.configure(message: message, tableView: tableView, indexPath: indexPath)
            return yourCell

        }
    }
    //각 메시지 클릭했을떄
}

extension MessageViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //이거도 상속 시키고싶은데 override 해야할듯
        if segue.identifier == "GoSendMessage" {
            guard let sendMessageViewController: SendMessageViewController =
                segue.destination as? SendMessageViewController else {
                    return
            }
            sendMessageViewController.delegate = self
            if messages[0].isSender == true { sendMessageViewController.receiveUserInfoId = messages[0].receiveUserInfoId }
            else { sendMessageViewController.receiveUserInfoId = messages[0].sendUserInfoId }
        }
    }
}

extension MessageViewController: DoUpdateMessageDelegate {
    func doUpdateMessage() {
        reloadMessages()
        delegate?.doUpdateMessageRoom()
    }
    
    func setBar(){
        let sendButtonView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 25, height: 40)))
        let sendButton = UIButton(type: .system)
        sendButton.frame = CGRect(origin: .zero, size: CGSize(width: 25, height: 40))
        sendButton.setImage(UIImage(systemName: "plus"), for: .normal)
       // sendButton.setTitle("Send Mail", for: .normal)
        sendButton.addTarget(self, action: #selector(touchSendMail(_:)), for: .touchUpInside)
        sendButtonView.addSubview(sendButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendButtonView)
    }
}
