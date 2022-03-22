//
//  RequestForgotCheckCode.swift
//  Rudder
//
//  Created by 박민호 on 2022/02/16.
//

import Foundation

struct RequestForgotCheckCode {
    
    //login
    static func uploadInfo(email: String, verificationCode: String, completion: @escaping (Bool) -> Void) -> Void{
                           

   
        let url = URL(string: (Utils.urlKey + "/signupin/checkCode"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let checkCode = CheckCode(email: email, verifyCode: verificationCode)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(checkCode) else {
          
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
                let decodedResponse: CheckCodeResponse = try decoder.decode(CheckCodeResponse.self, from: data)
                
                completion(decodedResponse.results.isSuccessForgot)
                
               } catch let error as NSError {
                   completion(false)
                   print(error)
               }
        })
        task.resume()
    }
    
}

extension RequestForgotCheckCode {
    struct CheckCode: Codable {
        let email: String
        let verifyCode: String //
    }
    struct TmpCheckCodeResponse: Codable {
        let isSuccessForgot: Bool
    }
    struct CheckCodeResponse: Codable {
        let results: TmpCheckCodeResponse
    }
}
