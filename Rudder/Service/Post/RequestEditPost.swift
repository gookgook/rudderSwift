//
//  RequestEditPost.swift
//  Rudder
//
//  Created by Brian Bae on 06/09/2021.
//

import Foundation

struct PostToEdit: Codable {
    let postBody: String
    let postId: Int
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case postBody = "post_body"
        case postId = "post_id"
        case token
    }
    
}

struct RequestEditPost {
    static func uploadInfo(postId:Int, postBody: String, completion: @escaping (Int) -> Void) -> Void{
        let url = URL(string: Utils.urlKey+"/board/editPost")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        let postToEdit = PostToEdit(postBody: postBody, postId: postId, token: token)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(postToEdit) else {
          return
        }
      
        let task = URLSession.shared.uploadTask(with: request, from: EncodedUploadData, completionHandler: { (data, response, error) in
            if let error = error {
                print ("error: \(error)")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                return
            }
            
            completion(1)
        })
        task.resume()
    }
}
