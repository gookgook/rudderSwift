//
//  RequestBlockUser.swift
//  Rudder
//
//  Created by 박민호 on 2022/03/11.
//

import Foundation

struct RequestBlockUser {
    //login
    static func uploadInfo(userInfoId: Int, completion: @escaping (Int) -> Void) -> Void{
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        let buRequest = BURequest(token: token, blockUserInfoId: userInfoId)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(buRequest) else {return}
        let url = URL(string: Utils.urlKey+"/users/blockUser")!
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
            //lewandowski
            guard let data = data, error == nil else {
                print("server error")
                completion(-1)
                return
            }
            let decoder:JSONDecoder = JSONDecoder()
            do {
                let decodedResponse: ResponseBU = try decoder.decode(ResponseBU.self, from: data)
                
                if decodedResponse.results.isSuccess == true {
                    completion(1)
                }
                
               } catch let error as NSError {
                   completion(-1)
                   print(error)
               }
        })
        
        task.resume()
    }
    
    struct BURequest: Codable {
        let token: String
        let blockUserInfoId: Int
    }
    
    struct BUResponse: Codable {
        let isSuccess: Bool
    }
    struct ResponseBU: Codable {
        let results: BUResponse
    }
}
