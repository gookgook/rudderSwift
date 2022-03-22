//

// by 박민호 on 2022/01/21.
//

import UIKit
//spinner 추가해야할듯?
class ChangeCharacterViewController: PickCharacterViewController{
    
    var delegate: DoUpdateCharacterDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCharacter()
        // Do any additional setup after loading the view.
    }
    @objc override func picked(_ sender: UIButton){
        print("picked ",sender.tag)
        
        RequestUpdateCharacter.uploadInfo(profileImageId: chIds[sender.tag] ,completion: {
            status in
            //DispatchQueue.main.async {self.spinner.stopAnimating()}
            if status == 1{
                DispatchQueue.main.async {
                    self.delegate?.doUpdateCharacter()
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            }else if status == -1 {
                print("Server error")
            }
        })
    }
}
