//
//  MyPostCommentViewController.swift
//  Rudder
//
//  Created by 박민호 on 2022/03/03.
//

import UIKit

class MyPostCommentViewController: PostsViewController{
    
    var offset: Int = 0
    
    var firstDownload: Bool = false //반창고
    
    var myPostOrComment: Int! //내글인지 내 댓글인지를 구별하기 위함. 부모의 postOrComment와는 다름
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentCategoryId = -1
        posts = []
        //TmpViewController.posts = []  //
        let cellNib: UINib = UINib.init(nibName: "CommunityBoardCell", bundle: nil)
        
        self.postTableView.register(cellNib,
                                       forCellReuseIdentifier: "communityBoardCell")
        
        //검색에서는 reload 필요없어서 일단 지움 이부분에있던거
        self.postTableView.estimatedRowHeight = 200 //autolatyout 잘 작동하게 대략적인 높이?
        self.postTableView.rowHeight = UITableView.automaticDimension //UITableView.automaticDimension // 각 row 높이 자동으로 설정하려면 이거 적용시켜줘야한다? rowHeight문서 ㄱㄱ
    }
}

extension MyPostCommentViewController {
    @objc override func requestPosts(endPostId: Int, searchbody: String) { //override대매 파라미터 나둠. 안씀
        firstDownload = true
        if let isRefreshing: Bool = self.postTableView.refreshControl?.isRefreshing,
            isRefreshing == false {
           // self.showSpinner()
        }
        
        RequestMyPost.posts(myPostOrComment: myPostOrComment ,offset: offset) { (posts: [Post]?) in
            
            if let posts = posts {
                if posts.count == 0 {
                    Alert.showAlert(title: "No more posts", message: nil, viewController: self)
                    self.banInfinite = true
                }
                self.firstDownload = false
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
}

extension MyPostCommentViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        // calculates where the user is in the y-axis
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height + 30 && infiniteScrollNow == false && banInfinite == false && firstDownload == false{
            
            print("infinite scroll")
            infiniteScrollNow = true
            offset += 1
            requestPosts(endPostId: endPostId, searchbody: "" )
            
        }
    }
}

extension MyPostCommentViewController {
    override func viewWillAppear(_ animated: Bool) { //이전화면에서 넘겨받은 친구정보 화면에 보여주기도 하고
        banInfinite = false//글 없을때 infinite 여러번하는거방지
        
        super.viewWillAppear(animated)
        setBarStyle()
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        //setBarStyle()
        if posts.isEmpty {
            self.requestPosts(endPostId: endPostId, searchbody: "")
            //doRefresh = false
            //print("해당 카테고리 post 없음")
        } else {
            if doRefresh == true {
                endPostId = -1
                self.requestPosts(endPostId: endPostId, searchbody: "") //일단 Add Post 하고 돌아올때를 대비하여 여기다가 추가하긴 했음
                doRefresh = false
            }
            /*self.postTableView.reloadSections(IndexSet(0...0),
                                          with: UITableView.RowAnimation.none)*/
        }
    }
    
    func setBarStyle() {
        self.tabBarController?.tabBar.isTranslucent = false
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.backgroundColor = UIColor.white
    }
}
