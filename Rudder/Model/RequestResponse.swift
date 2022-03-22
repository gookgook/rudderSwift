//
//  RequestResponse.swift
//  Rudder
//
//  Created by 박민호 on 2022/01/21.
//

import Foundation

struct AddLikeData: Codable {
    let postId: Int
    let token: String
    let plusValue: Int
    
    enum CodingKeys: String, CodingKey {
        case postId = "post_id"
        case token, plusValue
    }
}

struct AddLikeDataComment: Codable {
    let commentId: Int
    let token: String
    let plusValue: Int
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case token, plusValue
    }
}

struct TypicalResponse: Codable {
    let isSuccess: Bool
    let error: String
}

struct ResponseTypical: Codable {
    let results: TypicalResponse
}
