//
//  RequestAddCategory.swift
//  Rudder
//
//  Created by 박민호 on 2022/03/08.
//

import Foundation


struct RequestAddCategory {
    //login
    static func uploadInfo(categoryName: String, completion: @escaping (Int) -> Void) -> Void{
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        let ucRequest = ACRequest(token: token, categoryName: categoryName)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(ucRequest) else {return}
        let url = URL(string: Utils.urlKey+"/board/requestAddCategory")!
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
                let decodedResponse: ResponseAC = try decoder.decode(ResponseAC.self, from: data)
                
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
    
    struct ACRequest: Codable {
        let token: String
        let categoryName: String
        
        enum CodingKeys: String, CodingKey {
            case token
            case categoryName = "category_name"
        }
    }
    
    struct ACResponse: Codable {
        let isSuccess: Bool
    }
    struct ResponseAC: Codable {
        let results: ACResponse
    }
}

