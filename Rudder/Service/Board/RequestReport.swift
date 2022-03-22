//
//  RequestReport.swift
//  Rudder
//
//  Created by Brian Bae on 06/09/2021.
//

import Foundation

struct RequestReport {
    //login
    static func uploadInfo(EncodedUploadData: Data, completion: @escaping (Int) -> Void) -> Void{
        let url = URL(string: Utils.urlKey+"/reviewsearch/sendReport")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      
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
