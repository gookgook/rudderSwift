//
//  Report.swift
//  Rudder
//
//  Created by Brian Bae on 06/09/2021.
//

import Foundation

struct Report: Codable {
    let token: String
    let postId: Int
    let reportBody: String
    let postType: String
    
    enum CodingKeys: String, CodingKey {
        case token
        case postId = "post_id"
        case reportBody = "report_body"
        case postType = "post_type"
    }    
}
