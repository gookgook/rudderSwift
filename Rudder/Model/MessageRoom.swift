//
//  MessageRoom.swift
//  Rudder
//
//  Created by 박민호 on 2022/01/24.
//

import Foundation

struct MessageRoom: Codable {
    let postMessageRoomId: Int
    let messageSendTime: String
    let postMessageBody: String
    let userId: String
}
