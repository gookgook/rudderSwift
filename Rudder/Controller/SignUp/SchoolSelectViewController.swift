//
//  SchoolSelectViewController.swift
//  Rudder
//
//  Created by Brian Bae on 09/08/2021.
//

import UIKit

class SchoolSelectViewController: UIViewController {
    
    
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet weak var showPicker: UITextField!
    
    let schoolPicker = UIPickerView()
    var selectedSchoolId: Int!
    
    @IBAction func touchUpNextButton(_ sender: UIButton){
        self.performSegue(withIdentifier: "GoSignUp2", sender: selectedSchoolId)
    }

    private var schools : [School] = []

}

extension SchoolSelectViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setBar()
        setSchoolPicker()
        schoolPicker.dataSource = self
        schoolPicker.delegate = self
        nextButton.titleLabel?.font = UIFont(name: "SF Pro Text Bold", size: 18)
        nextButton.backgroundColor = MyColor.superLightGray
        nextButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestSchools()
        setBarStyle()
        
    }
}

extension SchoolSelectViewController: UIPickerViewDataSource, UIPickerViewDelegate{
   
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schools.count+1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Select your University"
        }
        return schools[row-1].schoolName
    }
}

extension SchoolSelectViewController {
    @objc private func requestSchools() {
        
        RequestSchool.schools { (schools: [School]?) in
            if let schools = schools {
                self.schools = schools
                self.schoolPicker.reloadAllComponents()
            }
        }
    }
}

extension SchoolSelectViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let signUpViewController: SignUpViewController =
            segue.destination as? SignUpViewController else {
            return
        }
        signUpViewController.universityId = selectedSchoolId
    }
}

extension SchoolSelectViewController{
    func setSchoolPicker(){
        showPicker.tintColor = .clear
        showPicker.text = "Select your University"
        showPicker.borderStyle = .none
        
        schoolPicker.delegate = self
        showPicker.inputView = schoolPicker
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let tmpBarButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(self.done))
        tmpBarButton.tintColor = MyColor.rudderPurple
        let button = tmpBarButton
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        showPicker.inputAccessoryView = toolBar
    }
    
    @objc func done(){
        if schoolPicker.selectedRow(inComponent: 0) != 0 {
            showPicker.text = schools[schoolPicker.selectedRow(inComponent: 0) - 1].schoolName
            selectedSchoolId = schools[schoolPicker.selectedRow(inComponent: 0) - 1].schoolId
            nextButton.backgroundColor = MyColor.rudderPurple
            nextButton.isEnabled = true
        } else {
            showPicker.text = "Select your University"
            nextButton.backgroundColor = MyColor.superLightGray
            nextButton.isEnabled = false
        }
        
        //index out of range
        
        showPicker.endEditing(true)
    }
}

extension SchoolSelectViewController{
    func setBar(){
        self.navigationItem.hidesBackButton = true
        let label = UILabel()
        label.text = " Sign Up"
        label.textAlignment = .left
        label.font = UIFont(name: "SF Pro Text Bold", size: 20)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
        
        let backButtonView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(origin: .zero, size: CGSize(width: 40, height: 40))
        backButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        backButton.addTarget(self, action: #selector(goBack(_:)), for: .touchUpInside)
        backButtonView.addSubview(backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backButtonView)
        
    }
    
    func setBarStyle(){
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    @objc func goBack(_ sender: UIBarButtonItem){
        print("go Back touched")
        self.navigationController?.popViewController(animated: true)
    }
}
