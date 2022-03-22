//
//  CommunityPostViewController.swift
//  Rudder
//
//  Created by Brian Bae on 27/07/2021.
//
// recycle cell에 함부로 강제추출 하지 말것! ?전략으로 ㄲ

import UIKit

class CommunityPostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var comments: [Comment] = [] //상속때매 Private임시로 뺌
    
    var delegate: DoRefreshDelegate?
    var likeDelegate: DoUpdateLikeButtonDelegate?
    var commentDelegate: DoUpdateCommentCountDelegate?
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    @IBOutlet weak var commentTableView: UITableView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var postBodyView: UITextView!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var commentCountLabel2: UILabel!
    
    @IBOutlet weak var addCommentBodyView: UITextView!
    @IBOutlet weak var addCommentSuperView: UIView! // for Keyoard avoidancd
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var addCommentButton: UIButton!
    
    @IBOutlet weak var characterView: UIImageView!
    
    var tmpCR: Int!
    
    private var originalY: CGFloat! //keyboard avoidance 위해
    
    var postId: Int!
    var post: Post! //posts가 싱글톤으로 바껴서 사실 이거는 필요없음... post를 아예 없애는거 생각해봐야함. 이제는 이 post필요함
    
    var imageUrls: [String]!
    var images: [UIImage]!
    
    var parentOrChild: String = "parent" // 현재 target comment가 부모인지 자식인지
    var groupNum: Int = 0
    var currentReplyCellNum: Int = 999

}

extension CommunityPostViewController {
    @IBAction func touchUpLikeButton(_ sender: UIButton){
        print("likebutton touched")
        
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        if post.isLiked == true {
            
            likeDelegate?.doUpdateLikeButton(likeCount: -1)
            
            post.isLiked = false
            likeButton.setImage(UIImage(named: "like"), for: .normal)
            // for .highlighted 에 blur 한거 필요
            let addLikeData = AddLikeData(postId: postId, token: token, plusValue: -1)
            likeCountLabel.text = String( Int(likeCountLabel.text!)! - 1)
            requestAddLike(addLikeData: addLikeData)
    
        }else{
            post.isLiked = true
            
            likeDelegate?.doUpdateLikeButton(likeCount: +1)
            
            likeButton.setImage(UIImage(named: "like_purple"), for: .normal)
            // for .highlighted 에 blur 한거 필요
            let addLikeData = AddLikeData(postId: postId, token: token, plusValue: 1)
            likeCountLabel.text = String( Int(likeCountLabel.text!)! + 1)
            requestAddLike(addLikeData: addLikeData)
            
        }
    }
    
    func requestAddLike(addLikeData: AddLikeData){
        RequestAddLike.uploadInfo(addLikeData: addLikeData, completion: {
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

extension CommunityPostViewController {
    @IBAction func touchUpAddCommentButton(_ sender: UIButton){
        
        print("add comment touched")
        guard let commentBody: String = self.addCommentBodyView.text, commentBody != "Add a Comment" else {
            Alert.showAlert(title: "One or more fields is blank", message: nil, viewController: self)
            return
        }
        guard let commentBody: String = self.addCommentBodyView.text,
              commentBody.isEmpty == false else {
            print("comment empty")
            Alert.showAlert(title: "One or more fields is blank", message: nil, viewController: self)
            return
        }
        
        //self.delegate?.doRefreshChange()
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        spinner.startAnimating()
        self.view.isUserInteractionEnabled = false
        print("current datgeul "+parentOrChild)
        
        let commentToAdd = CommentToAdd(postId: self.postId, commentBody: commentBody, token: token, status: parentOrChild, groupNum: groupNum)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(commentToAdd) else {
          
            return
         }
        RequestAddComment.uploadInfo(EncodedUploadData: EncodedUploadData, completion: {
            status in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
            if status == 1 {
                print("addComment success")
                DispatchQueue.main.async {
                    self.parentOrChild = "parent"
                    self.requestComments()
                    self.placeholderSetting()
                    self.dismissKeyboard()
                    self.commentDelegate?.doUpdateCommentCount(commentCount: 1)
                }
            }
            if status == 2 {
                print("addComment error")
               
            }
        })
    }
}

extension CommunityPostViewController: UITextViewDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tmpCR = 23
        
        setCharacter()
        
        toDoViewDidLoad()
        
        
    }
    
    func toDoViewDidLoad (){
        addCommentBodyView.delegate = self
        addCommentBodyView.textContainerInset = UIEdgeInsets(top: addCommentBodyView.textContainerInset.top, left: 10, bottom: addCommentBodyView.textContainerInset.bottom, right: 30)
        placeholderSetting()
        addCommentButton.tag = 2 // tapgesture 예외 위해
        
        if post.isLiked == true {
            likeButton.setImage(UIImage(named: "like_purple"), for: .normal)
        }
        
        self.addCommentBodyView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        spinner.hidesWhenStopped = true
        
        self.hideKeyboardWhenTappedAround()
        
        let cellNib: UINib = UINib.init(nibName: "CommentCell", bundle: nil) //nib파일 불러와서 셀정보를 테이블뷰에 등록 xib->nib이다
        let childCellNib: UINib = UINib.init(nibName: "ChildCommentCell", bundle: nil)
        let deletedCellNib: UINib = UINib.init(nibName: "DeletedCommentCell", bundle: nil)
        
        self.commentTableView.register(cellNib,
                                forCellReuseIdentifier: "commentCell")
        self.commentTableView.register(childCellNib,
                                forCellReuseIdentifier: "childCommentCell")
        self.commentTableView.register(deletedCellNib,
                                forCellReuseIdentifier: "deletedCommentCell")
        
        let refreshControl: UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.requestComments),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = MyColor.rudderPurple
        
        self.commentTableView.refreshControl = refreshControl
        self.commentTableView.estimatedRowHeight = 200 //autolatyout 잘 작동하게 대략적인 높이?
        self.commentTableView.rowHeight = UITableView.automaticDimension //UITableView.automaticDimension // 각 row 높이 자동으로 설정하려면 이거 적용시켜줘야한다? rowHeight문서 ㄱㄱ
        
        showImage()
    }
}


extension CommunityPostViewController {
    override func viewDidLayoutSubviews() {
        
        originalY = self.addCommentSuperView.frame.origin.y
        
        if let headerView = commentTableView.tableHeaderView {

            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame
                //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                commentTableView.tableHeaderView = headerView
            }
        }
    }
}

extension CommunityPostViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.isHidden = true
        guard let post: Post = self.post else {
            return
        }
        
        self.categoryLabel.text = post.categoryAbbreviation
        self.userNicknameLabel.text = post.userNickname
        self.timeAgoLabel.text = Utils.timeAgo(postDate: post.timeAgo)
        self.postBodyView.text = post.postBody
        self.likeCountLabel.text = String(post.likeCount)
        self.commentCountLabel.text = String(post.commentCount)
        self.commentCountLabel2.text = "Comment ("+String(post.commentCount)+")"
        if post.commentCount == 0 {  commentCountLabel2.textColor = UIColor.white}
        else {commentCountLabel2.textColor = UIColor.lightGray }
        
        self.postId = post.postId
        
        if self.comments.isEmpty {
            self.requestComments()
        } else {
            self.commentTableView.reloadSections(IndexSet(0...0),
                                          with: UITableView.RowAnimation.none)
        }
        
    }
    
    func setCharacter(){
        let url = URL(string: post.userProfileImageUrl)!
        
        let cacheKey: String = url.absoluteString
        if let cachedImage = ImageCache.imageCache.object(forKey: cacheKey as NSString) {
            DispatchQueue.main.async {  //왜 이걸 붙혀야지만 되는건지는 의문 - 이곳은 안붙혀도 이미 main thread 아닌가?
                self.characterView.image = cachedImage
            }
            return
        }
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
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

//comment tableview
extension CommunityPostViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CommentCell
        cell = tableView.dequeueReusableCell(withIdentifier: "commentCell",
                                             for: indexPath) as! CommentCell
        let childCell: ChildCommentCell
        childCell = tableView.dequeueReusableCell(withIdentifier: "childCommentCell",
                                                  for: indexPath) as! ChildCommentCell
        let deletedCell: DeletedCommentCell
        deletedCell = tableView.dequeueReusableCell(withIdentifier: "deletedCommentCell",
                                                    for: indexPath) as! DeletedCommentCell
       // cell.delegate = self
        
        let comment: Comment = self.comments[indexPath.row]
        
        guard comment.commentId != -1 else {return deletedCell}
        
        cell.replyButton.addTarget(self, action: #selector(touchUpReplyButton(_ :)), for: .touchUpInside)
        cell.replyButton.tag = indexPath.row
        cell.moreMenuButton.addTarget(self, action: #selector(touchUpMoreMenuComment(_ :)), for: .touchUpInside)
        cell.moreMenuButton.tag = indexPath.row
        
        childCell.moreMenuButton.addTarget(self, action: #selector(touchUpMoreMenuComment(_ :)), for: .touchUpInside)
        childCell.moreMenuButton.tag = indexPath.row
        
        cell.tag = comment.groupNum
        
        guard indexPath.row < self.comments.count else {
            return cell
        }
        
        
        if comment.status == "parent" {
            if parentOrChild == "child" && cell.backgroundColor == MyColor.lightPurple && indexPath.row != currentReplyCellNum{
                cell.backgroundColor = UIColor.systemBackground
            }
            if parentOrChild == "child" && indexPath.row == currentReplyCellNum {
                cell.backgroundColor = MyColor.lightPurple
            }
            
            cell.configure(comment: comment, tableView: tableView, indexPath: indexPath)
            let url = URL(string: comment.userProfileImageUrl)!
            
            let cacheKey: String = url.absoluteString
            if let cachedImage = ImageCache.imageCache.object(forKey: cacheKey as NSString) {
                DispatchQueue.main.async {  //왜 이걸 붙혀야지만 되는건지는 의문 - 이곳은 안붙혀도 이미 main thread 아닌가?
                    cell.characterView.image = cachedImage
                }
                return cell
            }
            getData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                // always update the UI from the main thread
                DispatchQueue.main.async{
                    let image = UIImage(data: data)
                    guard image != nil else {return }
                    ImageCache.imageCache.setObject(image!, forKey: cacheKey as NSString)
                    cell.characterView.image = image
                }
            }
            return cell
        }else {
            childCell.configure(comment: comment, tableView: tableView, indexPath: indexPath)
            let url = URL(string: comment.userProfileImageUrl)!
            
            let cacheKey: String = url.absoluteString
            if let cachedImage = ImageCache.imageCache.object(forKey: cacheKey as NSString) {
                DispatchQueue.main.async {  //왜 이걸 붙혀야지만 되는건지는 의문 - 이곳은 안붙혀도 이미 main thread 아닌가?
                    childCell.characterView.image = cachedImage
                }
                return childCell
            }
            getData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                // always update the UI from the main thread
                DispatchQueue.main.async{
                    let image = UIImage(data: data)
                    guard image != nil else {return }
                    ImageCache.imageCache.setObject(image!, forKey: cacheKey as NSString)
                    childCell.characterView.image = image
                }
            }
            
            return childCell
        }
    }
    
    //lewandowski
}

extension CommunityPostViewController{ //request하고 테이블뷰 새로고침까지
    
    @objc func requestComments() { //상속때매 private임시로 뺌
        
        if let isRefreshing: Bool = self.commentTableView.refreshControl?.isRefreshing,
            isRefreshing == false {
            self.spinner.startAnimating()
        }
        
        RequestComment.comments(postId: self.postId ) {  ( comments: [Comment]?) in
            if let comments = comments {
                self.comments = comments
                self.deletedComment()
                self.commentTableView.reloadSections(IndexSet(0...0),
                                              with: UITableView.RowAnimation.automatic)
                self.post.commentCount = comments.count
                DispatchQueue.main.async {
                    self.commentCountLabel.text = String(comments.count)
                    self.commentCountLabel2.text = "Comment ("+String(self.post.commentCount)+")"
                    if self.post.commentCount == 0 {  self.commentCountLabel2.textColor = UIColor.white}
                    else {self.commentCountLabel2.textColor = UIColor.lightGray }
                }
            }
            
            if let refreshControl: UIRefreshControl = self.commentTableView.refreshControl, //위에서 아래로 잡아끌면 새로고침하도록 도와주는것
                refreshControl.isRefreshing == true {
                refreshControl.endRefreshing()
            } else {
                self.spinner.stopAnimating()
            }
        }
    }
}

extension CommunityPostViewController{
    @objc func touchUpReplyButton(_ sender: UIButton) {
        addCommentBodyView.becomeFirstResponder()
        if currentReplyCellNum != 999 {
            let cell = self.commentTableView.cellForRow(at: IndexPath(row: currentReplyCellNum, section: 0)) as? CommentCell
            cell?.backgroundColor = UIColor.systemBackground
        }
        let cell = self.commentTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? CommentCell
        cell?.backgroundColor = MyColor.lightPurple
        currentReplyCellNum = sender.tag
        print("pressed "+String(cell!.tag)) //지우고 내라
        parentOrChild = "child"
        //placeholderSetting()
        if cell?.tag == nil { // 혹시모를오류 방지인데 솔직히 필요없을듯
            groupNum = 0
        }else {
            groupNum = cell!.tag
        }
    }
}

extension CommunityPostViewController{
    @IBAction func touchUpMoreMenuButton (_ sender: UIButton!){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default, handler: { action in
            print("edit called")
            DispatchQueue.main.async {self.performSegue(withIdentifier: "GoEditPost", sender: self.post)}
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { action in
            self.spinner.startAnimating()
            self.view.isUserInteractionEnabled = false
            RequestDelete.uploadInfo(postId: self.postId, completion: {
                status in
                if status == 1 {
                    print("delete success")
                    
                    self.delegate?.doRefreshChange()
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.navigationController?.popViewController(animated: true)
                    }
                }else{
                    print("delete error")
                }
            })
        })
        let messageAction = UIAlertAction(title: "Send Message", style: .default, handler: { action in
            let k_resetToTopViewForYourTabNotification = Notification.Name("resetToTopViewForYourTabNotification")
            let userInfo: [AnyHashable: Any] = ["receiveUserInfoId":self.post.userInfoId]
            self.tabBarController?.selectedIndex = 1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
                NotificationCenter.default.post(name: k_resetToTopViewForYourTabNotification, object: nil, userInfo: userInfo)
            }
            
        })
        
        let blockAction = UIAlertAction(title: "Block User", style: .default, handler: { action in
            self.blockUser(userInfoId: self.post.userInfoId, postOrComment: 1)
        })
        
        let reportAction = UIAlertAction(title: "Report", style: .destructive, handler: { action in
            print("report called")
            var senString: [String] = []
            senString.append("post")
            senString.append(String(self.postId))
            self.performSegue(withIdentifier: "GoReport", sender: senString)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
       
        if post.isMine == true {
            actionSheet.addAction(editAction)
            actionSheet.addAction(deleteAction)
            actionSheet.addAction(cancelAction)
            self.present(actionSheet, animated: true, completion: nil)
            
        }else{
            actionSheet.addAction(messageAction)
            actionSheet.addAction(blockAction)
            actionSheet.addAction(reportAction)
            actionSheet.addAction(cancelAction)
            self.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    //comment more menu
    @objc func touchUpMoreMenuComment(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default, handler: { action in
            Alert.showAlert(title: "Please wait for our next update!", message: nil, viewController: self)
            //DispatchQueue.main.async {self.performSegue(withIdentifier: "GoEditPost", sender: TmpViewController.posts[sender.tag])}
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { action in
            self.spinner.startAnimating()
            self.view.isUserInteractionEnabled = false
            RequestDeleteComment.uploadInfo(postId: self.postId, commentId: self.comments[sender.tag].commentId, completion: {
                
                status in
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    self.spinner.stopAnimating()
                }
                if status == 1 {
                    print("delete success")
                
                    DispatchQueue.main.async {
                        self.requestComments()
                        
                        self.commentDelegate?.doUpdateCommentCount(commentCount: -1)
                    }
                }else{
                    print("delete error")
                }
            })
        })
        
        let messageAction = UIAlertAction(title: "Send Message", style: .default, handler: { action in
            let k_resetToTopViewForYourTabNotification = Notification.Name("resetToTopViewForYourTabNotification")
            let userInfo: [AnyHashable: Any] = ["receiveUserInfoId":self.comments[sender.tag].userInfoId]
            self.tabBarController?.selectedIndex = 1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
                NotificationCenter.default.post(name: k_resetToTopViewForYourTabNotification, object: nil, userInfo: userInfo)
            }
            
        })
        
        let blockAction = UIAlertAction(title: "Block User", style: .default, handler: { action in
            self.blockUser(userInfoId: self.comments[sender.tag].userInfoId, postOrComment: 2)
        })
        
        let reportAction = UIAlertAction(title: "Report", style: .destructive, handler: { action in
            print("report called")
            var senString: [String] = []
            senString.append("comment")
            senString.append(String(self.comments[sender.tag].commentId))
            self.performSegue(withIdentifier: "GoReport", sender: senString)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
       
        if comments[sender.tag].isMine == true {
            actionSheet.addAction(editAction)
            actionSheet.addAction(deleteAction)
            actionSheet.addAction(cancelAction)
            self.present(actionSheet, animated: true, completion: nil)
            
        }else{
            actionSheet.addAction(messageAction)
            actionSheet.addAction(blockAction)
            actionSheet.addAction(reportAction)
            actionSheet.addAction(cancelAction)
            self.present(actionSheet, animated: true, completion: nil)
        }
        return
        
    }
}

extension CommunityPostViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GoEditPost" {
            guard let editPostViewController: EditPostViewController =
                segue.destination as? EditPostViewController else {
                    return
            }
            
            editPostViewController.previousPost = post
            editPostViewController.editDelegate = self
        
        }else if segue.identifier == "GoReport" {
            guard let reportViewController: ReportViewController =
                segue.destination as? ReportViewController else {
                return
            }
            
            guard let tmpSender = sender as? [String] else {
                return
            }
            
            reportViewController.postOrComment = tmpSender[0]
            if tmpSender[0] == "post" { reportViewController.postId = Int(tmpSender[1])}
            else {reportViewController.commentId = Int(tmpSender[1])}
        }
    }
}

//imageProcess
extension CommunityPostViewController{
    func showImage(){
        if imageUrls == nil || imageUrls.count == 0 {return}
      
        for i in 0...imageUrls.count - 1 {
            let url = URL(string: imageUrls[imageUrls.count - 1 - i])!
           downloadImage(from: url)
        }
        
        
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL) {
        let cacheKey: String = url.absoluteString
        if let cachedImage = ImageCache.imageCache.object(forKey: cacheKey as NSString) {
            print("already in cache")
            DispatchQueue.main.async {  //왜 이걸 붙혀야지만 되는건지는 의문 - 이곳은 안붙혀도 이미 main thread 아닌가?
                self.attachImage(image: cachedImage)
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
                self.attachImage(image: image)
            }
        }
    }
    func attachImage(image: UIImage!){
        let textAttachment = NSTextAttachment()
        
        guard image != nil else {return } //image 오류 방지
        textAttachment.image = image
        let oldWidth = textAttachment.image!.size.width;
        let scaleFactor = oldWidth / (postBodyView.frame.size.width - 15)
        
        textAttachment.image =  UIImage(cgImage: textAttachment.image!.cgImage!, scale: scaleFactor, orientation: .up)
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        let currentBody = NSMutableAttributedString()
        currentBody.append(NSAttributedString(string:"\n\n"))
        currentBody.append(postBodyView.attributedText)
        //let imsi = NSMutableAttributedString(string: "\n\n"+self.postBodyView.text)
        currentBody.replaceCharacters(in: NSMakeRange(0, 0), with: attrStringWithImage)
        
        postBodyView.attributedText = currentBody
        postBodyView.font = UIFont(name: "SF Pro Text Regular", size: 14)
    }
}
extension CommunityPostViewController {
    func deletedComment(){
        var idx: Int = 0
        let dComment = Comment(commentId: -1, userNickname: "dummy", timeAgo: "dummy", commentBody: "dummy", userInfoId: -1 ,status: "del", groupNum: -1, likeCount: -1, isMine: false, isLiked: false, userProfileImageUrl: "dummy")
        while true {
            if idx > comments.count - 1 {break}
            guard idx != 0 else {
                if comments[idx].status == "child" {
                    comments.insert(dComment, at: idx)
                    idx += 2
                    continue
                }
                idx += 1
                continue
            }
            if comments[idx].status == "child" && comments[idx].groupNum != comments[idx-1].groupNum {
                comments.insert(dComment, at: idx)
                idx += 2
                continue
            }
            idx += 1
        }
    }
}

extension CommunityPostViewController {
    func blockUser(userInfoId: Int, postOrComment: Int){
        Alert.showAlertWithCB(title: "This will permanently block the user", message: nil, isConditional: true, viewController: self, completionBlock: {
            okCancel in
            if okCancel{
            self.spinner.startAnimating()
                RequestBlockUser.uploadInfo(userInfoId: userInfoId, completion: {
                    status in
                    DispatchQueue.main.async {self.spinner.stopAnimating()}
                    if status == 1 {
                        print("Block User Success")
                        if postOrComment == 1 {
                            self.delegate?.doRefreshChange()
                            DispatchQueue.main.async {
                                self.view.isUserInteractionEnabled = true
                                self.navigationController?.popViewController(animated: true)
                            }
                        }else {
                            self.delegate?.doRefreshChange()
                            DispatchQueue.main.async {
                                self.requestComments()
                            }
                        }
                        
                    }
                    if status == -1 {
                        print("Block User Fail")
                    }
                })
            }
        })
    }
}

extension CommunityPostViewController: DoUpdatePostBodyDelegate {
    
    func doUpdatePostBody(postBody: String) {
        DispatchQueue.main.async {
            print("postBody update edit")
            print(postBody)
            self.postBodyView.text = postBody
            self.post.postBody = postBody 
        }
        
        self.delegate?.doRefreshChange()
    }
}










//------------------------------------ 각종 UI관련
//keyboard dismiss + 대댓글일때 밖 화면 누르면 댓으로 전환
extension CommunityPostViewController: UIGestureRecognizerDelegate {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CommunityPostViewController.dismissKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        print("outside touch")
        view.endEditing(true)
        if parentOrChild == "child" {
            parentOrChild = "parent"
            placeholderSetting()
            let cell = self.commentTableView.cellForRow(at: IndexPath(row: currentReplyCellNum, section: 0)) as? CommentCell
            cell?.backgroundColor = UIColor.systemBackground
            currentReplyCellNum = 999
            print("childToParent")
        }
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool { //버튼은 예외를 주기 위해서
        guard (touch.view as? UIButton) != nil else {
            print("this is not button")
            return true
            
        }
        return false
      
    }
}

extension CommunityPostViewController {
    @objc func keyboardWillShow(_ sender: Notification) {
        let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardRect = keyboardFrame.cgRectValue
        //let keyboardHeight = keyboardRect.height
        self.addCommentSuperView.frame.origin.y = keyboardRect.origin.y - self.addCommentSuperView.frame.height
        commentTableView.contentSize.height += keyboardRect.height
    }
    @objc func keyboardWillHide(_ sender: Notification) {
        let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardRect = keyboardFrame.cgRectValue
        self.addCommentSuperView.frame.origin.y = originalY // Move view to original position
        commentTableView.contentSize.height -= keyboardRect.height
    }
}

extension CommunityPostViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*if parentOrChild == "child" && addCommentBodyView.text.isEmpty == true {
            parentOrChild = "parent"
            let cell = self.commentTableView.cellForRow(at: IndexPath(row: currentReplyCellNum, section: 0)) as? CommentCell
            currentReplyCellNum = 999
            cell?.backgroundColor = UIColor.systemBackground
            print("parent to child by scroll")
        }*/
   }
    
}

extension CommunityPostViewController{
    func placeholderSetting() {
        if parentOrChild == "parent" { addCommentBodyView.text = "Add a Comment"}
        else { addCommentBodyView.text = "Add a Reply"}
        addCommentBodyView.textColor = UIColor.lightGray
            
    }
        
        // TextView Place Holder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
            
    }
        // TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if parentOrChild == "parent" { textView.text = "Add a Comment"}
            else { textView.text = "Add a Reply"}
            textView.textColor = UIColor.lightGray
        }
           // self.postBodyView.rightAnchor.constraint(equalTo: self.lastButtonAnchor, constant: 50).isActive = true
    }
}

//lewandowski
