//
//  Spinner.swift
//  Rudder
//
//  Created by Brian Bae on 19/08/2021.
//

import UIKit

class Spinner {
    //private lazy
    
    var indicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large) //request구조체에서는 네트워킹하는동안 상태표시줄에 indicator표시하는 코드 있음. uiactivityindicator아니고 다른 코드로
        indicator.backgroundColor = UIColor.lightGray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    func showSpinner(view: UIView){
        view.addSubview(indicator)
        
        let safeAreaLayoutGuide: UILayoutGuide = view.safeAreaLayoutGuide //autolayout code로 구현함
        
        self.indicator.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor).isActive = true
        self.indicator.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        indicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        
        self.indicator.stopAnimating()
        self.indicator.removeFromSuperview()
    }
}
