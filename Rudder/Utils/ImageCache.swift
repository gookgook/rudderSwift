//
//  ImageCache.swift
//  Rudder
//
//  Created by Brian Bae on 11/09/2021.
//

import UIKit

class ImageCache {
    
    static let imageCache = NSCache<NSString, UIImage>()
    private init() {}
}
