//
//  Protocols.swift
//  Rudder
//
//  Created by 박민호 on 2022/01/19.
//

import Foundation

protocol DoRefreshDelegate {
    func doRefreshChange()
}

protocol DoUpdateCharacterDelegate {
    func doUpdateCharacter()
}

protocol DoUpdateMessageDelegate {
    func doUpdateMessage()
}

protocol DoUpdateMessageRoomDelegate {
    func doUpdateMessageRoom()
}

protocol DoUpdateMessageDirectDelegate {
    func doUpdateMessageDirect()
}

protocol DoUpdatePostBodyDelegate {
    func doUpdatePostBody(postBody: String)
}

protocol DoUpdateLikeButtonDelegate {
    func doUpdateLikeButton(likeCount: Int) // +1 or -1
}

protocol DoUpdateCommentCountDelegate {
    func doUpdateCommentCount(commentCount: Int) // +1 or -1
}
