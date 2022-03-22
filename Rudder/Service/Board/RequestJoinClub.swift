//
//  RequestJoinClub.swift
//  Rudder
//
//  Created by Brian Bae on 04/10/2021.
//

import Foundation

struct RequestJoinClub {
    static func uploadInfo(categoryId: Int , completion: @escaping (Int) -> Void) -> Void{
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        let joinClubData = JoinClubData(token: token, requestBody: "dummy body", categoryId: categoryId)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(joinClubData) else {
          return
        }
        
        let url = URL(string: Utils.urlKey+"/board/requestJoinClub")!
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
                completion(-1)
                return
            }
            
            completion(1)
        })
        task.resume()
    }
}

struct JoinClubData: Codable {
    
    let token: String
    let requestBody: String
    let categoryId: Int
    
    enum CodingKeys: String, CodingKey {
        case token
        case requestBody = "request_body"
        case categoryId = "category_id"
    }
}
