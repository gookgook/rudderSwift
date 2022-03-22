//
//  Comment.swift
//  Rudder
//
//  Created by Brian Bae on 28/07/2021.
//

import Foundation

struct Comment: Codable, Equatable {
    
    // MARK: - Nested Types
    //let category: String
    let commentId: Int
    
    let userNickname: String
    let timeAgo: String
    let commentBody: String
    let userInfoId: Int
    let status: String
    let groupNum: Int
    let likeCount: Int
    let isMine: Bool
    
    var isLiked: Bool
    
    let userProfileImageUrl: String
    // MARK: - Properties
    
    // MARK: Privates
}

extension Comment {
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case userNickname = "user_id"
        case timeAgo = "post_time"
        case commentBody = "comment_body"
        case userInfoId = "user_info_id"
        case status
        case groupNum = "group_num"
        case likeCount = "like_count"
        case isLiked, isMine, userProfileImageUrl
    }
}
