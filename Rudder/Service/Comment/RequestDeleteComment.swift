//
//  RequestDeleteComment.swift
//  Rudder
//
//  Created by Brian Bae on 11/09/2021.
//

import Foundation

struct RequestDeleteComment {
    //login
    static func uploadInfo(postId: Int, commentId: Int, completion: @escaping (Int) -> Void) -> Void{
        let url = URL(string: Utils.urlKey+"/comment/deleteComment")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
        let uploadData = RequestInfo(commentId: commentId, postId: postId)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(uploadData) else {
            completion(-1)
            return
        }
        
        let task = URLSession.shared.uploadTask(with: request, from: EncodedUploadData, completionHandler: { (data, response, error) in
            if let error = error {
                print ("error: \(error)")
                completion(-1)
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                completion(-1)
                return
            }
            
            completion(1)
        })
        task.resume()
    }
}
extension RequestDeleteComment {
    struct RequestInfo: Codable {
        let commentId: Int
        let postId: Int
    
        enum CodingKeys: String, CodingKey {
            case commentId = "comment_id"
            case postId = "post_id"
        }
    
    }
}
