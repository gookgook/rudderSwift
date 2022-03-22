//
//  Message.swift
//  Rudder
//
//  Created by 박민호 on 2022/01/26.
//

import Foundation

struct Message: Codable {
    let postMessageId: Int
    let sendUserInfoId: Int
    let receiveUserInfoId: Int
    let messageSendTime: String
    let postMessageBody: String
    let isRead: Bool
    let isSender: Bool
}
