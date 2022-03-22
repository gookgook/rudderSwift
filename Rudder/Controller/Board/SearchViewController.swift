//
//  SearchViewController.swift
//  Rudder
//
//  Created by Brian Bae on 24/11/2021.
//

import UIKit

class SearchViewController: PostsViewController{

    @IBOutlet weak var searchBodyField: UITextField!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        searchBodyField.delegate = self
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

extension SearchViewController {
    override func viewWillAppear(_ animated: Bool) { //이전화면에서 넘겨받은 친구정보 화면에 보여주기도 하고
        banInfinite = false//글 없을때 infinite 여러번하는거방지
        
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        //setBarStyle()
        if posts.isEmpty {
            //self.requestPosts(endPostId: endPostId)
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
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //search button touched
        print("Search Button touched")
        guard let searchBody: String = self.searchBodyField.text,
              searchBody.isEmpty == false else {
            Alert.showAlert(title: "Search Field Empty!", message: nil, viewController: self)
            return false
        }
        guard searchBody.count > 1 else {
            Alert.showAlert(title: "You must enter two or more letters", message: nil, viewController: self)
            return false
        }
        print("Search body not empty")
        /*guard searchBody.count>=3 else {
            Alert.showAlert(title: "Please enter at least three letters", message: nil, viewController: self)
            return false
        }*/
        dismissKeyboard()
        spinner.startAnimating()
        endPostId = -1
        requestPosts(endPostId: endPostId, searchbody: searchBody)
        return true
    }
}





extension SearchViewController{
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard searchBodyField.text?.isEmpty == false else{
            return
        }
        // calculates where the user is in the y-axis
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height + 30 && infiniteScrollNow == false && banInfinite == false{
            
            print("infinite scroll")
            infiniteScrollNow = true
            requestPosts(endPostId: endPostId, searchbody: searchBodyField.text! )
            
            
        }
    }
}

extension SearchViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


