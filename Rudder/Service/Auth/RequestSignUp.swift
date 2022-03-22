//
//  RequestSignUp.swift
//  Rudder
//
//  Created by Brian Bae on 13/09/2021.
//

import Foundation

struct RequestSignUp {
    //login
    static func uploadInfo(signupInfo: SignUpInfo, completion: @escaping (Int) -> Void) -> Void{
        let url = URL(string: Utils.urlKey+"/signupin/signupinsert")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
        guard let EncodedUploadData = try? JSONEncoder().encode(signupInfo) else {
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
