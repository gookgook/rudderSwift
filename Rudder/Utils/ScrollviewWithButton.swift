//
//  ScrollviewWithButton.swift
//  Rudder
//
//  Created by Brian Bae on 08/10/2021.
//

import UIKit

class ScrollViewWithButton: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.isKind(of: UIButton.self) {
          return true
        }

        return super.touchesShouldCancel(in: view)
    }
}
