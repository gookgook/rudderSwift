//
//  RequestAddComment.swift
//  Rudder
//
//  Created by Brian Bae on 24/08/2021.
//

import Foundation

struct RequestAddComment {
    //login
    static func uploadInfo(EncodedUploadData: Data, completion: @escaping (Int) -> Void) -> Void{
        let url = URL(string: Utils.urlKey+"/comment/addComment")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
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
