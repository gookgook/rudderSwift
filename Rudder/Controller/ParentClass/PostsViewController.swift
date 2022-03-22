//
//  PostsViewController.swift
//  Rudder
//
//  Created by 박민호 on 2022/01/13.
//

//Post 목록 class
//CommunityPosts, SearchedPosts, MyPosts(예정) 등에서 상속받을 class

import UIKit

class PostsViewController: UIViewController {
    
    @IBOutlet weak var postTableView: UITableView!
    
    @IBOutlet var spinner: UIActivityIndicatorView!

    var currentCategoryId: Int! //inheritance 위해 private 풀음
    
    var doRefresh: Bool = false //inheritance 위해 private 풀음
    
    var posts: [Post] = []
    
    var endPostId: Int = -1
    
    var banInfinite: Bool = true
    var infiniteScrollNow: Bool = false
    
    var indexPathForSelectedRow: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension PostsViewController{
    @objc func requestPosts(endPostId: Int, searchbody: String) { //inheritance 위해 private 풀음, searchbody 추가함 범용성 위해
      
        if let isRefreshing: Bool = self.postTableView.refreshControl?.isRefreshing,
            isRefreshing == false {
           // self.showSpinner()
        }
        
        Request.posts(categoryId: currentCategoryId,endPostId: endPostId, searchbody: searchbody) { (posts: [Post]?) in
            
            if let posts = posts {
                if posts.count == 0 {
                    Alert.showAlert(title: "No more posts", message: nil, viewController: self)
                    self.banInfinite = true
                }
                if self.infiniteScrollNow == true {
                    self.posts += posts
                }else{
                    self.posts = posts
                }
                self.postTableView.reloadSections(IndexSet(0...0),
                                              with: UITableView.RowAnimation.automatic)
                
                
            }
            self.infiniteScrollNow = false
            if let refreshControl: UIRefreshControl = self.postTableView.refreshControl, //위에서 아래로 잡아끌면 새로고침하도록 도와주는것
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
    @objc func reloadPosts(){ //상속 위해 private 뺌
        endPostId = -1
        banInfinite = false
        requestPosts(endPostId: endPostId, searchbody: "")
    }
}


extension PostsViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CommunityBoardCell
        cell = tableView.dequeueReusableCell(withIdentifier: "communityBoardCell",
                                             for: indexPath) as! CommunityBoardCell
        // cell.delegate = self
        
        guard indexPath.row < posts.count else {
            return cell
        }
        
        let post: Post = posts[indexPath.row]
        
        endPostId = post.postId
        
        
        cell.moreMenuButton.addTarget(self, action: #selector(touchUpMoreMenuButton(_ :)), for: .touchUpInside)
        cell.moreMenuButton.tag = indexPath.row
        
        cell.likeButton.addTarget(self, action: #selector(touchUpLikeButton(_ :)), for: .touchUpInside)
        cell.likeButton.tag = indexPath.row
        cell.configure(post: post, tableView: tableView, indexPath: indexPath)
        cell.tag  = post.postId
        
     
        //cache처리이따가
        let url = URL(string: post.userProfileImageUrl)!
        
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
        
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}

extension PostsViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell: UITableViewCell = tableView.cellForRow(at: indexPath) {
            self.performSegue(withIdentifier: "ShowPost", sender: cell)
            indexPathForSelectedRow = indexPath as NSIndexPath
            if let selectedRow = indexPathForSelectedRow { //hightlight 지우기
                postTableView.deselectRow(at: selectedRow as IndexPath, animated: true)
            }

           // cell.selectionStyle = .none
        }
    }
}

extension PostsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { //이거도 상속 시키고싶은데 override 해야할듯
        
        if segue.identifier == "GoEditPost" {
            guard let editPostViewController: EditPostViewController =
                segue.destination as? EditPostViewController else {
                    return
            }
            guard let previousPost = sender as? Post else {
                return
            }
            editPostViewController.previousPost = previousPost
            editPostViewController.delegate = self
            
        }else if segue.identifier == "ShowPost" {
            
            guard let cell: CommunityBoardCell = sender as? CommunityBoardCell else {
                return
            }
            
            guard let index: IndexPath = self.postTableView.indexPath(for: cell) else {
                return
            }
            
            guard index.row < posts.count else { return }
            
            guard let communityPostViewController: CommunityPostViewController =
                segue.destination as? CommunityPostViewController else {
                    return
            }
            
            let post: Post = posts[index.row]
            communityPostViewController.post = post
            communityPostViewController.imageUrls = post.imageUrls
            communityPostViewController.delegate = self
            communityPostViewController.commentDelegate = self
            communityPostViewController.likeDelegate = self
            
        }else if segue.identifier == "GoReport" {
            guard let reportViewController: ReportViewController =
                segue.destination as? ReportViewController else {
                return
            }
            
            guard let postId = sender as? Int else {
                return
            }
            
            reportViewController.postOrComment = "post"
            reportViewController.postId = postId
        }
    }
}

extension PostsViewController {
    @objc func touchUpLikeButton(_ sender: UIButton) {
        print("like button pressed "+String(sender.tag))
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        if posts[sender.tag].isLiked == true {
            posts[sender.tag].isLiked = false
            sender.setImage(UIImage(named: "like"), for: .normal)
            let cell = self.postTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! CommunityBoardCell
            // for .highlighted 에 blur 한거 필요
            posts[sender.tag].likeCount += 1
            let addLikeData = AddLikeData(postId: cell.tag, token: token, plusValue: -1) //여기도 강제추출 때문에 위험
            requestAddLike(cell: cell,cellTag:sender.tag, addLikeData: addLikeData)
    
        }else{
            posts[sender.tag].isLiked = true
            sender.setImage(UIImage(named: "like_purple"), for: .normal)
            let cell = self.postTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! CommunityBoardCell
            // for .highlighted 에 blur 한거 필요
            posts[sender.tag].likeCount -= 1
            let addLikeData = AddLikeData(postId: cell.tag, token: token, plusValue: 1) //여기도 강제추출 때문에 위험
            requestAddLike(cell: cell, cellTag:sender.tag ,addLikeData: addLikeData)
            
        }
    }
    func requestAddLike(cell: CommunityBoardCell,cellTag: Int, addLikeData: AddLikeData){
        RequestAddLike.uploadInfo(addLikeData: addLikeData, completion: {
            likeCount in
            if likeCount == -1 {
                print("addLike error")
            }
            else if likeCount >= 0 {
                print("addLike success")
                DispatchQueue.main.async {
                    cell.likeCountLabel.text = String(likeCount)
                }
                self.posts[cellTag].likeCount = likeCount
            }
        })
    }
}

extension PostsViewController {
    @objc func touchUpMoreMenuButton(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default, handler: { action in
            print("edit called")
            DispatchQueue.main.async {self.performSegue(withIdentifier: "GoEditPost", sender: self.posts[sender.tag])}
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { action in
            
            self.spinner.startAnimating()
            self.view.isUserInteractionEnabled = false
            if sender.tag >= self.posts.count {return}
            RequestDelete.uploadInfo(postId: self.posts[sender.tag].postId, completion: {
                status in
                
                if status == 1 {
                    print("delete success")
                
                    DispatchQueue.main.async {
                        self.endPostId = -1
                        self.requestPosts(endPostId: self.endPostId, searchbody: "")
                    }
                }else{
                    DispatchQueue.main.async {
                        //self.spinner.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                    }
                    print("delete error")
                }
            })
        })
        
        let messageAction = UIAlertAction(title: "Send Message", style: .default, handler: { action in
            let k_resetToTopViewForYourTabNotification = Notification.Name("resetToTopViewForYourTabNotification")
            let userInfo: [AnyHashable: Any] = ["receiveUserInfoId":TmpViewController.posts[sender.tag].userInfoId]
            self.tabBarController?.selectedIndex = 1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
                NotificationCenter.default.post(name: k_resetToTopViewForYourTabNotification, object: nil, userInfo: userInfo)
            }
           
        })
        
        let blockAction = UIAlertAction(title: "Block User", style: .default, handler: { action in
            self.blockUser(userInfoId: self.posts[sender.tag].userInfoId)
        })
        
        let reportAction = UIAlertAction(title: "Report", style: .destructive, handler: { action in
            print("report called")
            self.performSegue(withIdentifier: "GoReport", sender: self.posts[sender.tag].postId)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
       
        if self.posts[sender.tag].isMine == true {
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

extension PostsViewController {
    func blockUser(userInfoId: Int){
        Alert.showAlertWithCB(title: "This will permanently block the user", message: nil, isConditional: true, viewController: self, completionBlock: {
            okCancel in
            if okCancel {
                RequestBlockUser.uploadInfo(userInfoId: userInfoId, completion: {
                    status in
                    DispatchQueue.main.async {self.spinner.stopAnimating()}
                    if status == 1 {
                        print("Block User Success")
                        DispatchQueue.main.async { self.reloadPosts() }
                    }
                    if status == -1 {
                        print("Block User Fail")
                    }
                })
            }
        })
    }
}


extension PostsViewController {
    func showNotice(){
        if Utils.noticeShowed == false && Utils.firstScreen == 1{
            
            Alert.serverAlert(viewController: self)
            Utils.noticeShowed = true
        }
    }
}

extension PostsViewController: DoRefreshDelegate, DoUpdateLikeButtonDelegate, DoUpdateCommentCountDelegate {
    
    func doRefreshChange() {
        self.doRefresh = true
    }
    
    func doUpdateLikeButton(likeCount: Int) {
        let cell = self.postTableView.cellForRow(at: IndexPath(row: indexPathForSelectedRow.row, section: 0)) as! CommunityBoardCell
        if likeCount == 1 {
            print("hit like delegate")
            cell.likeButton.setImage(UIImage(named: "like_purple"), for: .normal)
            cell.likeCountLabel.text = String(Int(cell.likeCountLabel.text!)!+1)
            posts[indexPathForSelectedRow.row].likeCount += 1
            posts[indexPathForSelectedRow.row].isLiked = true
            
        } else  {
            cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
            cell.likeCountLabel.text = String(Int(cell.likeCountLabel.text!)!-1)
            posts[indexPathForSelectedRow.row].likeCount -= 1
            posts[indexPathForSelectedRow.row].isLiked = false
            
        }
           // cell.selectionStyle = .none
        
    }
    func doUpdateCommentCount(commentCount: Int) {
        let cell = self.postTableView.cellForRow(at: IndexPath(row: indexPathForSelectedRow.row, section: 0)) as! CommunityBoardCell
        if commentCount == 1 {
            cell.commentCountLabel.text = String(Int(cell.commentCountLabel.text!)!+1)
        } else  {
            cell.commentCountLabel.text = String(Int(cell.commentCountLabel.text!)!-1)
        }
    }
}

extension PostsViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // calculates where the user is in the y-axis
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height + 30 && infiniteScrollNow == false && banInfinite == false{
            
            print("infinite scroll")
            infiniteScrollNow = true
            requestPosts(endPostId: endPostId, searchbody: "" )
            
            
        }
    }
}

