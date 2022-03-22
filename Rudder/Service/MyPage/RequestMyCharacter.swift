//
//  RequestMyCharacter.swift
//  Rudder
//
//  Created by Brian Bae on 11/09/2021.
//

import Foundation


struct RequestMyCharacter {
    //login
    static func uploadInfo( completion: @escaping (String) -> Void) -> Void{
                           

   
        let url = URL(string: (Utils.urlKey + "/signupin/profileImageUrl"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        let chRequest = ChRequest(token: token)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(chRequest) else {
          
            return
         }
      
        let task = URLSession.shared.uploadTask(with: request, from: EncodedUploadData, completionHandler: { (data, response, error) in
            if let error = error {
                print ("error: \(error)")
                completion("server error")
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                completion("server error")
                return
            }
            //lewandowski
            guard let data = data, error == nil else {
                print("server error")
                completion("server error")
                return
            }
            let decoder:JSONDecoder = JSONDecoder()
            do {
                let decodedResponse: ChResponse = try decoder.decode(ChResponse.self, from: data)
                
                completion(decodedResponse.results.url)
                
               } catch let error as NSError {
                   completion("server error")
                   print(error)
               }
        })
        task.resume()
    }
    
}

struct ChRequest: Codable{
    let token: String
}
struct TmpChResponse: Codable{
    let url: String
}
struct ChResponse: Codable{
    let results: TmpChResponse
}
