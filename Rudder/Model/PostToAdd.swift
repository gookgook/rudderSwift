//
//  PostToAdd.swift
//  Rudder
//
//  Created by Brian Bae on 25/08/2021.
//

import Foundation

struct PostToAdd: Codable {
    let boardType: String
    let postTitle: String //필요없음. 현재 api 명세 맞추기 위함
    let postBody: String
    let token: String
    let categoryId: Int
    
    enum CodingKeys: String, CodingKey {
        case boardType = "board_type"
        case postTitle = "post_title"
        case postBody = "post_body"
        case token
        case categoryId = "category_id"
    }
    
}
