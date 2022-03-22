//
//  RequestEmailVerify.swift
//  Rudder
//
//  Created by Brian Bae on 09/09/2021.
//

import Foundation

struct RequestEmailVerify {
    //login
    static func uploadInfo(email: String, schoolId: Int, completion: @escaping (Int) -> Void) -> Void{

   
        let url = URL(string: (Utils.urlKey + "/schoolverify/verifyEmail"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print(schoolId, email)
        let verifyRequest = RequestVerify(email: email, schoolId: schoolId)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(verifyRequest) else {
          
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
            //lewandowski
            guard let data = data, error == nil else {
                print("server error")
                return
            }
            let decoder:JSONDecoder = JSONDecoder()
            do {
                let decodedResponse: ResponseVerify = try decoder.decode(ResponseVerify.self, from: data)
                
                if decodedResponse.results.isVerify == true {
                    completion(1)
                }else{
                    completion(0)
                }
                
               } catch let error as NSError {
                   completion(-1)
                   print(error)
               }
        })
        task.resume()
    }
}

extension RequestEmailVerify {
    struct RequestVerify: Codable {
        let email: String
        let schoolId: Int //
        
        enum CodingKeys: String, CodingKey {
            case email
            case schoolId = "school_id"
            
        }
    }
    
    struct VerifyResponse: Codable {
        let isVerify: Bool
        let fail: String
    }
    struct ResponseVerify: Codable {
        let results: VerifyResponse
    }
}
