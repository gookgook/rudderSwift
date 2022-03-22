//
//  Alert.swift
//  Rudder
//
//  Created by Brian Bae on 12/09/2021.
//

import UIKit

class Alert: NSObject {

    static func showAlert(title: String!, message : String!, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message ,preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "ok"), style: UIAlertAction.Style.cancel, handler: nil))

        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func serverAlert(viewController: UIViewController) {
        RequestServerNotice.uploadInfo( completion: {
            notice in
            guard notice != nil else {return}
            DispatchQueue.main.async {
                let alert = UIAlertController(title: notice, message: nil ,preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "ok"), style: UIAlertAction.Style.cancel, handler: nil))

                viewController.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    static func showAlertWithCB(title: String, message: String!, isConditional: Bool, viewController: UIViewController, completionBlock: @escaping (_: Bool) -> Void) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

               // Check whether it's conditional or not ('YES' 'NO, or just 'OK')
               if isConditional
               {
                alert.addAction(UIAlertAction(title: NSLocalizedString("YES", comment: ""), style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) in
                       alert.dismiss(animated: true, completion: nil)
                       completionBlock(true)
                   }))

                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) in
                       alert.dismiss(animated: true, completion: nil)
                       completionBlock(false)
                   }))
               }
               else
               {
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "ok"), style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) in
                       alert.dismiss(animated: true, completion: nil)
                       completionBlock(true)
                   }))
               }

               viewController.present(alert, animated: true, completion: nil)
           }

}
