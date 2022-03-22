//
//  PickCharacterViewController.swift
//  Rudder
//
//  Created by Brian Bae on 12/09/2021.
//

import UIKit

class PickCharacterViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!

    var chUrls: [String] = [] //상속때매 private풀음
    var chIds: [Int] = [] //상속때매 private풀음
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestCharacter()
    }

    func requestCharacter(){
        RequestCharacters.uploadInfo { (urls: [HdPrev]?) in
            if urls == nil {return}
           if let urls = urls {
                for i in 0...urls.count - 1 {
                    self.chUrls.append(urls[i].previewLink)
                    self.chIds.append(urls[i]._id) //이게 원인일수도
                }
           }
            DispatchQueue.main.async {
                self.makeCharacterButton()
            }
        }
    }
    
    func makeCharacterButton(){
        if chUrls[0] == "server error" {return}
        var lastButtonAnchor: NSLayoutYAxisAnchor = scrollView.bottomAnchor
        var tmp: NSLayoutYAxisAnchor = scrollView.topAnchor
        for i in 0...chUrls.count - 1 { // count
            let button = UIButton()
            button.setTitleColor(.systemGray, for: .normal)
            //button.frame.size = CGSize(width: 300, height: 300)
            button.heightAnchor.constraint(equalToConstant: 112).isActive = true
            button.widthAnchor.constraint(equalToConstant: 100).isActive = true
            
            
            
            let url = URL(string: chUrls[i])!
            
            let cacheKey: String = url.absoluteString
            if let cachedImage = ImageCache.imageCache.object(forKey: cacheKey as NSString) {
                DispatchQueue.main.async {
                    button.setImage(cachedImage, for: .normal)
                }
            }else{
                getData(from: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    print(response?.suggestedFilename ?? url.lastPathComponent)
                    // always update the UI from the main thread
                    DispatchQueue.main.async{
                        let image = UIImage(data: data)
                        guard image != nil else {return }
                        ImageCache.imageCache.setObject(image!, forKey: cacheKey as NSString)
                        button.setImage(image, for: .normal)
                    }
                }
            }
            
            scrollView.addSubview(button)
            button.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 0).isActive = true
            button.translatesAutoresizingMaskIntoConstraints = false
            button.topAnchor.constraint(equalTo: tmp, constant: 20).isActive = true
            button.tag = i
            button.addTarget(self, action: #selector(picked(_ :)), for: .touchUpInside)
            
            /*if i == 0 {
                button.setTitleColor(.black, for: .normal)
                currentButton = button
            }*/
            
            tmp = button.bottomAnchor
            lastButtonAnchor = button.bottomAnchor
        }
        scrollView.bottomAnchor.constraint(equalTo: lastButtonAnchor, constant: 100).isActive = true
        /*DispatchQueue.main.async {
            self.categoryScrollView.rightAnchor.constraint(equalTo: self.lastButtonAnchor, constant: 50).isActive = true
        }*/
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    @objc func picked(_ sender: UIButton){
        print("picked ",sender.tag)
        SetProfileViewController.charId = chIds[sender.tag]
        SetProfileViewController.chUrl = chUrls[sender.tag]
        SetProfileViewController.didPick = true
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}

