//
//  Utils.swift
//  Rudder
//
//  Created by Brian Bae on 19/08/2021.
//

import Foundation

class Utils {
    static let urlKey = Bundle.main.infoDictionary!["TestURL"] as! String
    
    static func timeAgo(postDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat="yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: postDate)
        let rFormatter = RelativeDateTimeFormatter()
        if date == nil {
            return "temp datestring"
        }else {
            let datestring = rFormatter.localizedString(for: date!, relativeTo: Date())
            return datestring
        }
    }
    
    static var noticeShowed:Bool = false
    static var firstScreen:Int = 0 //0 is loginVC, 1 is tmpVC
}
