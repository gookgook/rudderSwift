//
//  RequestCharacters.swift
//  Rudder
//
//  Created by Brian Bae on 12/09/2021.
//

import Foundation

struct RequestCharacters {
    //login
    static func uploadInfo( completion: @escaping (_ urls: [HdPrev]?) -> Void) {
                           

   
        let url = URL(string: (Utils.urlKey + "/signupin/profileImageList"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
      
        let task = URLSession.shared.dataTask(with: request,completionHandler: { (data, response, error) in
            if let error = error {
                print ("error: \(error)")
                completion(nil)
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                completion(nil)
                return
            }
            //lewandowski
            guard let data = data, error == nil else {
                print("server error")
                completion(nil)
                return
            }
            let decoder:JSONDecoder = JSONDecoder()
            do {
                let decodedResponse: ChListResponse = try decoder.decode(ChListResponse.self, from: data)
                
                completion(decodedResponse.results.profileImageList)
                
               } catch let error as NSError {
                   completion(nil)
                   print(error)
               }
        })
        task.resume()
    }
    
}
struct HdPrev: Codable {
    let hdLink: String
    let previewLink: String
    let _id: Int
}

struct TmpChListResponse: Codable{
    let profileImageList: [HdPrev]
}
struct ChListResponse: Codable{
    let results: TmpChListResponse
}
