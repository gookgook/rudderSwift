//
//  CategoryViewController.swift
//  Rudder
//
//  Created by Brian Bae on 23/09/2021.
//

import UIKit

class CategoryViewController: UIViewController {
    
    @IBOutlet var categoryScrollView: ScrollViewWithButton!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    private var categories: [Category] = []
    private var departmentCategories: [Category] = []
    private var clubCategories: [ClubCategory] = []
    private var selectedCategoriesBool: [Bool] = []
    private var selectedCategories: [Int] = []
    private var selectedDepartmentCategories: [Int] = [-1,-1]
    
    let pickerView = UIPickerView()
    var showPicker = UITextField()
    
    let pickerView2 = UIPickerView()
    var showPicker2 = UITextField()
    
    
    var lastButtonAnchor: NSLayoutYAxisAnchor!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.isUserInteractionEnabled = false
        spinner.startAnimating()
        requestCategory()
    }
    
}

extension CategoryViewController {
    
    
    func makeCategoryButton(){
        
        var tmp: NSLayoutYAxisAnchor = categoryScrollView.topAnchor
        
        let chooseCategoryLabel = UILabel ()
        chooseCategoryLabel.text = "Choose Category"
        chooseCategoryLabel.textAlignment = .left
        chooseCategoryLabel.font = UIFont(name: "SF Pro Text Bold", size: 18)
        chooseCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryScrollView.addSubview(chooseCategoryLabel)
        chooseCategoryLabel.frame.size.width = self.view.frame.size.width - 30
        chooseCategoryLabel.centerXAnchor.constraint(equalTo: categoryScrollView.centerXAnchor, constant: 0).isActive = true
        chooseCategoryLabel.topAnchor.constraint(equalTo: categoryScrollView.topAnchor, constant: 20).isActive = true
        tmp = chooseCategoryLabel.bottomAnchor
    
        var didDepartmentStarted: Bool = false
        
        if categories.count != 0 {
            for i in 0...categories.count - 1 {
                if didDepartmentStarted == false && categories[i].categoryType == "department"{
                    
                    break
                }
                
                
                selectedCategoriesBool.append(categories[i].isSelect)
                
                let button = UIButton(type: .system)
                button.setTitleColor(.white, for: .normal)
                button.titleLabel!.font = UIFont(name: "SF Pro Text Bold", size: 18)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.layer.cornerRadius = 6
                
                categoryScrollView.addSubview(button)
                if categories[i].isSelect == false {
                    button.backgroundColor = MyColor.superLightGray
                }else{
                    button.backgroundColor = MyColor.rudderPurple
                }
                button.frame.size.width = self.view.frame.size.width - 30
                button.centerXAnchor.constraint(equalTo: categoryScrollView.centerXAnchor, constant: 0).isActive = true
                  
                button.topAnchor.constraint(equalTo: tmp, constant: 20).isActive = true
                button.rightAnchor.constraint(equalTo: categoryScrollView.rightAnchor, constant: 20).isActive = true
                button.leftAnchor.constraint(equalTo: categoryScrollView.leftAnchor, constant: 20).isActive = true
                    
                button.setTitle(categories[i].categoryName, for: .normal)
                
                button.addTarget(self, action: #selector(pressed(_ :)), for: .touchUpInside)
                button.tag = i
                    //button.addTarget(self, action: #selector(pressed(_ :)), for: .touchUpInside)
                   
                lastButtonAnchor = button.bottomAnchor
                tmp = button.bottomAnchor
            
            }
            let departmentLabel = UILabel ()
            departmentLabel.text = "Department"
            departmentLabel.textAlignment = .left
            departmentLabel.font = UIFont(name: "SF Pro Text Bold", size: 18)
            departmentLabel.translatesAutoresizingMaskIntoConstraints = false
            categoryScrollView.addSubview(departmentLabel)
            departmentLabel.frame.size.width = self.view.frame.size.width - 30
            departmentLabel.centerXAnchor.constraint(equalTo: categoryScrollView.centerXAnchor, constant: 0).isActive = true
            departmentLabel.topAnchor.constraint(equalTo: tmp, constant: 20).isActive = true
            tmp = departmentLabel.bottomAnchor
            didDepartmentStarted = true
            
            tmp = makePickerView(tmpAnchor: tmp)
        }
        
        let societyLabel = UILabel ()
        societyLabel.text = "Society"
        societyLabel.textAlignment = .left
        societyLabel.font = UIFont(name: "SF Pro Text Bold", size: 18)
        societyLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryScrollView.addSubview(societyLabel)
        societyLabel.frame.size.width = self.view.frame.size.width - 30
        societyLabel.centerXAnchor.constraint(equalTo: categoryScrollView.centerXAnchor, constant: 0).isActive = true
        societyLabel.topAnchor.constraint(equalTo: tmp, constant: 20).isActive = true
        tmp = societyLabel.bottomAnchor
        
        if clubCategories.count != 0 { //upperbound error 때문에
            for i in 0...clubCategories.count - 1 {
                let button = UIButton(type: .system)
                button.setTitleColor(.white, for: .normal)
                button.titleLabel!.font = UIFont(name: "SF Pro Text Bold", size: 18)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.layer.cornerRadius = 6
                
                categoryScrollView.addSubview(button)
                    
                if clubCategories[i].isMember == "t" {
                    button.backgroundColor = MyColor.rudderPurple
                }else {
                    button.backgroundColor = MyColor.superLightGray
                }
                button.centerXAnchor.constraint(equalTo: categoryScrollView.centerXAnchor, constant: 0).isActive = true
                  
                button.topAnchor.constraint(equalTo: tmp, constant: 20).isActive = true
                button.leftAnchor.constraint(equalTo: categoryScrollView.leftAnchor, constant: 20).isActive = true
                button.rightAnchor.constraint(equalTo: categoryScrollView.rightAnchor, constant: 20).isActive = true
                
                    
                button.setTitle(clubCategories[i].categoryName, for: .normal)
                button.tag = i
                
                button.addTarget(self, action: #selector(pressedClub(_ :)), for: .touchUpInside)
                   
                lastButtonAnchor = button.bottomAnchor
                tmp = button.bottomAnchor
            }
        }
        
        //category추가 요청 버튼
        let requestLabel = UILabel ()
        requestLabel.text = "Request Category"
        requestLabel.textAlignment = .left
        requestLabel.font = UIFont(name: "SF Pro Text Bold", size: 18)
        requestLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryScrollView.addSubview(requestLabel)
        requestLabel.frame.size.width = self.view.frame.size.width - 30
        requestLabel.centerXAnchor.constraint(equalTo: categoryScrollView.centerXAnchor, constant: 0).isActive = true
        requestLabel.topAnchor.constraint(equalTo: tmp, constant: 20).isActive = true
        tmp = requestLabel.bottomAnchor
        
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel!.font = UIFont(name: "SF Pro Text Bold", size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 6
        categoryScrollView.addSubview(button)
        button.backgroundColor = MyColor.rudderPurple
        button.centerXAnchor.constraint(equalTo: categoryScrollView.centerXAnchor, constant: 0).isActive = true
        button.topAnchor.constraint(equalTo: tmp, constant: 20).isActive = true
        button.leftAnchor.constraint(equalTo: categoryScrollView.leftAnchor, constant: 20).isActive = true
        button.rightAnchor.constraint(equalTo: categoryScrollView.rightAnchor, constant: 20).isActive = true
        button.setTitle("Request", for: .normal)
        button.addTarget(self, action: #selector(pressMakeCategory(_ :)), for: .touchUpInside)
        lastButtonAnchor = button.bottomAnchor
        
        
        DispatchQueue.main.async {
            guard self.lastButtonAnchor != nil else {return}
            
            self.categoryScrollView.bottomAnchor.constraint(equalTo: self.lastButtonAnchor, constant: 100).isActive = true
        }
    }
    
    func makePickerView (tmpAnchor: NSLayoutYAxisAnchor) -> NSLayoutYAxisAnchor{
        var tmp: NSLayoutYAxisAnchor = tmpAnchor
        //number 1
        showPicker.placeholder = "Select your department                      "
        showPicker.translatesAutoresizingMaskIntoConstraints = false
        categoryScrollView.addSubview(showPicker)
        showPicker.frame.size.width = self.view.frame.size.width - 20
        showPicker.centerXAnchor.constraint(equalTo: categoryScrollView.centerXAnchor, constant: 0).isActive = true
        showPicker.topAnchor.constraint(equalTo: tmp, constant: 20).isActive = true
        
        
        showPicker.tintColor = .clear
        showPicker.text = "Select your department"
        showPicker.textColor = MyColor.rudderPurple
        showPicker.borderStyle = .roundedRect
        
        pickerView.delegate = self
        showPicker.inputView = pickerView
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let tmpBarButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(self.done))
        tmpBarButton.tintColor = MyColor.rudderPurple
        let button = tmpBarButton
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        showPicker.inputAccessoryView = toolBar
        tmp = showPicker.bottomAnchor
        
        
        //number2
        showPicker2.placeholder = "Select your department                      "
        showPicker2.translatesAutoresizingMaskIntoConstraints = false
        categoryScrollView.addSubview(showPicker2)
        showPicker2.frame.size.width = self.view.frame.size.width - 20
        showPicker2.centerXAnchor.constraint(equalTo: categoryScrollView.centerXAnchor, constant: 0).isActive = true
        showPicker2.topAnchor.constraint(equalTo: tmp, constant: 20).isActive = true
        
        
        showPicker2.tintColor = .clear
        showPicker2.text = "Select your department"
        showPicker2.textColor = MyColor.rudderPurple
        showPicker2.borderStyle = .roundedRect
        
        pickerView2.delegate = self
        showPicker2.inputView = pickerView2
        let toolBar2 = UIToolbar()
        toolBar2.sizeToFit()
        let tmpBarButton2 = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(self.done2))
        tmpBarButton2.tintColor = MyColor.rudderPurple
        let button2 = tmpBarButton2
        toolBar2.setItems([button2], animated: true)
        toolBar2.isUserInteractionEnabled = true
        showPicker2.inputAccessoryView = toolBar2
        tmp = showPicker2.bottomAnchor
        
        return tmp
    }
}

extension CategoryViewController {
    @objc func done(){
        guard departmentCategories.count != 0 else {
            showPicker.endEditing(true)
            return
        }
        showPicker.text = departmentCategories[pickerView.selectedRow(inComponent: 0)].categoryName
        showPicker.endEditing(true)
        selectedDepartmentCategories[0] = departmentCategories[pickerView.selectedRow(inComponent: 0)].categoryId
        //currentCategoryId = categories[pickerView.selectedRow(inComponent: 0)].categoryId
        
    }
    @objc func done2(){
        guard departmentCategories.count != 0 else {
            showPicker2.endEditing(true)
            return
        }
        showPicker2.text = departmentCategories[pickerView2.selectedRow(inComponent: 0)].categoryName
        showPicker2.endEditing(true)
        selectedDepartmentCategories[1] = departmentCategories[pickerView2.selectedRow(inComponent: 0)].categoryId
        //currentCategoryId = categories[pickerView.selectedRow(inComponent: 0)].categoryId
        
    }
}

extension CategoryViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return departmentCategories.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return departmentCategories[row].categoryName
    }
}

//lewandowski
extension CategoryViewController {
    
    @objc private func requestCategory() {
        
        RequestCategory.categories { (categories: [Category]?) in
            if let categories = categories {
                for i in 0...categories.count - 1 {
                    if categories[i].categoryType == "common" { self.categories.append(categories[i]) }
                    else if categories[i].categoryType == "department" { self.departmentCategories.append(categories[i]) }
                }
            }
            RequestClubCategory.categories { (categories: [ClubCategory]?) in
                
                self.view.isUserInteractionEnabled = true
                self.spinner.stopAnimating()
                
                if let categories = categories {
                    self.clubCategories = categories
                    self.makeCategoryButton()
                   // self.showPicker.isEnabled = true
                }
            }
        }
    }
    
    @objc func pressMakeCategory (_ sender: UIButton) {
        self.performSegue(withIdentifier: "GoAddCategory", sender: nil)
    }
}

extension CategoryViewController {
    @objc func touchUpApplyButton(_ sender: UIButton) {
        spinner.startAnimating()
        TmpViewController.doRefreshCategory = true
        
        print("apply button touched")
        for i in 0 ... categories.count - 1 {
            if selectedCategoriesBool[i] == true {
                selectedCategories.append(categories[i].categoryId)
            }
        }
        if selectedDepartmentCategories[0] != -1 { selectedCategories.append(selectedDepartmentCategories[0]) }
        if selectedDepartmentCategories[1] != -1 { selectedCategories.append(selectedDepartmentCategories[1]) }
        
        print(selectedCategories)
        RequestUpdateCategory.uploadInfo(categoryIdList: selectedCategories, completion: {
            status in
            DispatchQueue.main.async {self.spinner.stopAnimating()}
            if status == 1 {
                print("selected category update success")
                DispatchQueue.main.async {
                   self.navigationController?.popViewController(animated: true)
                }
            }
            if status == -1 {
                print("selected category update error")
            }
        })
        
    }
}

extension CategoryViewController {
    
    @objc func pressed(_ sender: UIButton) {
        if selectedCategoriesBool[sender.tag] == true{
            sender.backgroundColor = MyColor.superLightGray
            selectedCategoriesBool[sender.tag] = false
        }else{
            sender.backgroundColor = MyColor.rudderPurple
            selectedCategoriesBool[sender.tag] = true
        }
        print("pressed")
    }
    
    @objc func pressedClub(_ sender: UIButton) {
       
        Alert.showAlertWithCB(title: "This board is exclusively for the society members. Would you send request?", message: nil, isConditional: true, viewController: self, completionBlock: {
            status in
            if status {
                DispatchQueue.main.async {self.spinner.startAnimating()}
                print( self.clubCategories[sender.tag].categoryId)
                RequestJoinClub.uploadInfo(categoryId: self.clubCategories[sender.tag].categoryId, completion: {
                    status in
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                    }
                    if status == 1 {
                        DispatchQueue.main.async { Alert.showAlert(title: "Cool. Please wait for the board managers to accept the request!", message: nil, viewController: self) }
                    }
                })
            }
        })
    }
    
}

extension CategoryViewController {
    
    /*class UIButtonScrollView: UIScrollView {

        override func touchesShouldCancel(in view: UIView) -> Bool {
            if view.isKind(of: UIButton.self) {
              return true
            }

            return super.touchesShouldCancel(in: view)
        }
    }*/

    func setBar(){
        let postButton = UIButton(type: .system)
        postButton.setTitle("Apply  ", for: .normal) // right margin 때문에 억지로 이렇게함. 수정 필요
        postButton.setTitleColor(MyColor.rudderPurple, for: .normal)
        postButton.addTarget(self, action: #selector(touchUpApplyButton(_:)), for: .touchUpInside)
        
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: postButton)
    }
}
