//
//  RequestDelete.swift
//  Rudder
//
//  Created by Brian Bae on 05/09/2021.
//

import Foundation

struct RequestDelete {
    //login
    static func uploadInfo(postId: Int, completion: @escaping (Int) -> Void) -> Void{
        let url = URL(string: Utils.urlKey+"/board/deletePost")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
        let uploadData = RequestInfo(postId: postId)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(uploadData) else {
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
extension RequestDelete {
    struct RequestInfo: Codable {
        let postId: Int
    
        enum CodingKeys: String, CodingKey {
            case postId = "post_id"
        }
    
    }
}
