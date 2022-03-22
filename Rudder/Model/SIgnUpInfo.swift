//
//  SIgnUpInfo.swift
//  Rudder
//
//  Created by Brian Bae on 13/09/2021.
//

import Foundation

struct SignUpInfo: Codable {
    let userId: String //변수이름바꾸기!!!!!!!!!!!!!!!!!!!!!!!
    let userPassword: String
    let email: String
    let recommendationCode: String
    let schoolId: Int
    let profileBody: String
    let userNickname: String
    let characterId: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userPassword = "user_password"
        case email
        case recommendationCode
        case schoolId = "school_id"
        case profileBody = "profile_body"
        case userNickname = "user_nickname"
        case characterId = "user_profile_image_id"
    }
    
}
