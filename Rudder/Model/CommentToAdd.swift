//
//  CommentToAdd.swift
//  Rudder
//
//  Created by Brian Bae on 25/08/2021.
//

import Foundation

struct CommentToAdd: Codable {
    let postId: Int
    let commentBody: String //필요없음. 현재 api 명세 맞추기 위함
    let token: String
    let status: String
    let groupNum: Int
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case commentBody = "comment_body"
        case token, status
        case groupNum = "group_num"
    }
}
