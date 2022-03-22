//
//  TmpPostViewController.swift
//  Rudder
//
//  Created by Brian Bae on 27/07/2021.
//

import UIKit

class TmpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var categoryScrollView: UIScrollView!
    
    private var comments: [Comment] = []  //이게 왜있는지에 대한 근본적인 의문
    
    private var lastButtonAnchor: NSLayoutXAxisAnchor! //임시
   
    private var categories: [Category] = []
    static var posts: [Post] = [] //
    
    private var currentButton: UIButton!
    private var currentCategoryId: Int! //refreshcontrol에 selector가 objc여서 파라미터 못넘김 -> 전역변수로 뺌
    
    var doRefresh: Bool = false //addPost 하고 돌아왔을때만 refresh하기 위해서
    static var doRefreshCategory: Bool = false
    
    static var doLogout: Bool = false
    
    var endPostId: Int = -1
    var infiniteScrollNow: Bool = false
    var banInfinite: Bool = true
    
    var indexPathForSelectedRow: NSIndexPath!
    
    var tmpCR: Int!
    
    
    @IBAction func touchAddPostButton(_ sender: UIButton){
        print("GoAddPost Touched")
        DispatchQueue.main.async {self.performSegue(withIdentifier: "GoAddPost", sender: sender)}
    }
    
    @IBAction func touchUpSearchButton(_ sender: UIButton){
        print("Search touched")
        DispatchQueue.main.async {self.performSegue(withIdentifier: "GoSearch", sender: sender)}
        //Alert.showAlert(title: "Please wait for our next update!", message: nil, viewController: self)
    }
}

extension TmpViewController {
    func makeCategoryButton(){
        for v in categoryScrollView.subviews{
            v.removeFromSuperview()
        }
        let AllCategory = Category(categoryId: -1, categoryName: "All", isSelect: true,  categoryType: "common", categoryAbbreviation: "All")
        categories.insert(AllCategory, at: 0)
        var tmp: NSLayoutXAxisAnchor = categoryScrollView.leftAnchor
        for i in 0...categories.count - 1 {
            let button = UIButton()
            button.setTitleColor(.systemGray, for: .normal)
            button.titleLabel!.font = UIFont(name: "SF Pro Text Bold", size: 18)
            
            categoryScrollView.addSubview(button)
            button.centerYAnchor.constraint(equalTo: categoryScrollView.centerYAnchor, constant: 0).isActive = true
            button.translatesAutoresizingMaskIntoConstraints = false
            button.leftAnchor.constraint(equalTo: tmp, constant: 20).isActive = true
    
            
            button.setTitle(categories[i].categoryAbbreviation, for: .normal)
            button.tag = categories[i].categoryId
            button.addTarget(self, action: #selector(pressed(_ :)), for: .touchUpInside)
            
            if i == 0 {
                button.setTitleColor(.black, for: .normal)
                currentButton = button
            }
            
            tmp = button.rightAnchor
            lastButtonAnchor = button.rightAnchor
        }
        DispatchQueue.main.async {
            self.categoryScrollView.rightAnchor.constraint(equalTo: self.lastButtonAnchor, constant: 50).isActive = true
        }
    }
}

extension TmpViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tmpCR = 10 //test용으로 만들었던거, 지워도됨
        requestCategory()
        currentCategoryId = -1
        TmpViewController.doLogout = false
        TmpViewController.posts = []
        showNotice()
        setBar()
        let cellNib: UINib = UINib.init(nibName: "CommunityBoardCell", bundle: nil)
        
        self.postTableView.register(cellNib,
                                       forCellReuseIdentifier: "communityBoardCell")
        
        let refreshControl: UIRefreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadPosts),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = MyColor.rudderPurple
        
        self.postTableView.refreshControl = refreshControl
        self.postTableView.estimatedRowHeight = 200 //autolatyout 잘 작동하게 대략적인 높이?
        self.postTableView.rowHeight = UITableView.automaticDimension //UITableView.automaticDimension // 각 row 높이 자동으로 설정하려면 이거 적용시켜줘야한다? rowHeight문서 ㄱㄱ

        // Do any additional setup after loading the view. lewandowski
    }
}

extension TmpViewController {
    override func viewWillAppear(_ animated: Bool) { //이전화면에서 넘겨받은 친구정보 화면에 보여주기도 하고
        
        print("tmpCR ",tmpCR!)
        
        if TmpViewController.doRefreshCategory {
            requestCategory()
            TmpViewController.doRefreshCategory = false
            currentCategoryId = -1
        }
        
        if let selectedRow = indexPathForSelectedRow { //hightlight 지우기
            postTableView.deselectRow(at: selectedRow as IndexPath, animated: true)
        }
        
        banInfinite = false//글 없을때 infinite 여러번하는거방지
        
        if TmpViewController.doLogout == true { //tab bar 에서 온 logout 처리
            UserDefaults.standard.removeObject(forKey: "token")
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        setBarStyle()
        
        
        if TmpViewController.posts.isEmpty {
            self.requestPosts(endPostId: endPostId)
            doRefresh = false
            //print("해당 카테고리 post 없음")
        } else {
            if doRefresh == true {
                endPostId = -1
                self.requestPosts(endPostId: endPostId) //일단 Add Post 하고 돌아올때를 대비하여 여기다가 추가하긴 했음
                doRefresh = false
            }
            /*self.postTableView.reloadSections(IndexSet(0...0),
                                          with: UITableView.RowAnimation.none)*/
        }
        
        //lewandowski
    }
}



extension TmpViewController {
    @objc private func requestPosts(endPostId: Int) {
      
        if let isRefreshing: Bool = self.postTableView.refreshControl?.isRefreshing,
            isRefreshing == false {
           // self.showSpinner()
        }
        
        Request.posts(categoryId: currentCategoryId,endPostId: endPostId, searchbody: "") { (posts: [Post]?) in
            
            if let posts = posts {
                if posts.count == 0 {
                    Alert.showAlert(title: "No more posts", message: nil, viewController: self)
                    self.banInfinite = true
                }
                if self.infiniteScrollNow == true {
                    TmpViewController.posts += posts
                }else{
                    TmpViewController.posts = posts
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
    @objc private func reloadPosts(){
        endPostId = -1
        banInfinite = false
        requestPosts(endPostId: endPostId)
    }
}

//post tableview
extension TmpViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TmpViewController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CommunityBoardCell
        cell = tableView.dequeueReusableCell(withIdentifier: "communityBoardCell",
                                             for: indexPath) as! CommunityBoardCell
        // cell.delegate = self
        
        guard indexPath.row < TmpViewController.posts.count else {
            return cell
        }
        
        let post: Post = TmpViewController.posts[indexPath.row]
        
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
    //lewandowski
}

extension TmpViewController {
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
            
            guard index.row < TmpViewController.posts.count else { return }
            
            guard let communityPostViewController: CommunityPostViewController =
                segue.destination as? CommunityPostViewController else {
                    return
            }
            
            communityPostViewController.delegate = self
            communityPostViewController.likeDelegate = self
            communityPostViewController.commentDelegate = self
            
            let post: Post = TmpViewController.posts[index.row]
            communityPostViewController.post = post
            communityPostViewController.imageUrls = post.imageUrls
            communityPostViewController.tmpCR = tmpCR
            
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
        }else if segue.identifier == "GoAddPost" {
            guard let addPostViewController: AddPostViewController =
                segue.destination as? AddPostViewController else {
                return
            }
           
            addPostViewController.delegate = self // doRefresh위해
        }
    }
}

extension TmpViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell: UITableViewCell = tableView.cellForRow(at: indexPath) {
            self.performSegue(withIdentifier: "ShowPost", sender: cell)
            indexPathForSelectedRow = indexPath as NSIndexPath
           // cell.selectionStyle = .none
        }
    }
}

extension TmpViewController {
    @objc private func requestCategory() {
        
        RequestSelectedCategory.categories { (categories: [Category]?) in
           if let categories = categories {
                self.categories = categories
                
            }
            self.makeCategoryButton()
        }
    }
}

//category change
extension TmpViewController {
    @objc func pressed(_ sender: UIButton) {
        spinner.startAnimating()
        banInfinite = false
        print("pressed "+String(sender.tag)+" current"+String(currentButton.tag))
        currentButton.setTitleColor(.systemGray, for: .normal)
        sender.setTitleColor(.black, for: .normal)
        currentCategoryId = sender.tag
        endPostId = -1
        requestPosts(endPostId: endPostId)
        currentButton = sender
    }
}

//
extension TmpViewController{
    @objc func touchUpLikeButton(_ sender: UIButton) {
        print("like button pressed "+String(sender.tag))
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        if TmpViewController.posts[sender.tag].isLiked == true {
            TmpViewController.posts[sender.tag].isLiked = false
            sender.setImage(UIImage(named: "like"), for: .normal)
            let cell = self.postTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! CommunityBoardCell
            // for .highlighted 에 blur 한거 필요
            TmpViewController.posts[sender.tag].likeCount += 1
            let addLikeData = AddLikeData(postId: cell.tag, token: token, plusValue: -1) //여기도 강제추출 때문에 위험
            requestAddLike(cell: cell,cellTag:sender.tag, addLikeData: addLikeData)
    
        }else{
            TmpViewController.posts[sender.tag].isLiked = true
            sender.setImage(UIImage(named: "like_purple"), for: .normal)
            let cell = self.postTableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! CommunityBoardCell
            // for .highlighted 에 blur 한거 필요
            TmpViewController.posts[sender.tag].likeCount -= 1
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
                TmpViewController.posts[cellTag].likeCount = likeCount
            }
        })
    }
}


//delete, edit, report
extension TmpViewController{
    @objc func touchUpMoreMenuButton(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "Edit", style: .default, handler: { action in
            print("edit called")
            DispatchQueue.main.async {self.performSegue(withIdentifier: "GoEditPost", sender: TmpViewController.posts[sender.tag])}
        })
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { action in
            
            self.spinner.startAnimating()
            self.view.isUserInteractionEnabled = false
            if sender.tag >= TmpViewController.posts.count {return}
            RequestDelete.uploadInfo(postId: TmpViewController.posts[sender.tag].postId, completion: {
                status in
                
                if status == 1 {
                    print("delete success")
                
                    DispatchQueue.main.async {
                        self.endPostId = -1
                        self.requestPosts(endPostId: self.endPostId)
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
            self.blockUser(userInfoId: TmpViewController.posts[sender.tag].userInfoId)
        })
        
        let reportAction = UIAlertAction(title: "Report", style: .destructive, handler: { action in
            print("report called")
            self.performSegue(withIdentifier: "GoReport", sender: TmpViewController.posts[sender.tag].postId)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
       
        if TmpViewController.posts[sender.tag].isMine == true {
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

extension TmpViewController {
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

extension TmpViewController{
    func showNotice(){
        if Utils.noticeShowed == false && Utils.firstScreen == 1{
            
            Alert.serverAlert(viewController: self)
            Utils.noticeShowed = true
        }
    }
}

extension TmpViewController: DoRefreshDelegate, DoUpdateLikeButtonDelegate, DoUpdateCommentCountDelegate{
   
    
    func doRefreshChange() {
        doRefresh = true
    }
    
    func doUpdateLikeButton(likeCount: Int) {
        let cell = self.postTableView.cellForRow(at: IndexPath(row: indexPathForSelectedRow.row, section: 0)) as! CommunityBoardCell
        if likeCount == 1 {
            print("hit like delegate")
            cell.likeButton.setImage(UIImage(named: "like_purple"), for: .normal)
            cell.likeCountLabel.text = String(Int(cell.likeCountLabel.text!)!+1)
            TmpViewController.posts[indexPathForSelectedRow.row].likeCount += 1
            TmpViewController.posts[indexPathForSelectedRow.row].isLiked = true
            
        } else  {
            cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
            cell.likeCountLabel.text = String(Int(cell.likeCountLabel.text!)!-1)
            TmpViewController.posts[indexPathForSelectedRow.row].likeCount -= 1
            TmpViewController.posts[indexPathForSelectedRow.row].isLiked = false
            
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










extension TmpViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // calculates where the user is in the y-axis
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height + 30 && infiniteScrollNow == false && banInfinite == false{
            
            print("infinite scroll")
            infiniteScrollNow = true
            requestPosts(endPostId: endPostId)
            
            
        }
    }
}

extension TmpViewController {
    func setBar(){
        self.navigationItem.hidesBackButton = true
        let label = UILabel()
        label.text = " Community"
        label.textAlignment = .left
        label.font = UIFont(name: "SF Pro Text Bold", size: 20)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    }
    
    func setBarStyle(){
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.backgroundColor = UIColor.white
        
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .white
       // self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
}
