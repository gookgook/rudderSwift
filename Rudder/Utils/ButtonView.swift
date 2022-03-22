//
//  ButtonView.swift
//  Rudder
//
//  Created by 박민호 on 2022/03/21.
//

import UIKit

class ButtonView: UIView { 

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 0.5
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 1.0
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 1.0
        }
    }
}
