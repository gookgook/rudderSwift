//
//  RequestCheckCode.swift
//  Rudder
//
//  Created by Brian Bae on 09/09/2021.
//

import Foundation

struct RequestCheckCode {
    //login
    static func uploadInfo(email: String, verifyCode: String, completion: @escaping (Int) -> Void) -> Void{
                           

   
        let url = URL(string: (Utils.urlKey + "/schoolverify/checkCode"))!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let checkCode = CheckCode(email: email, verifyCode: verifyCode)
        
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
                
                if decodedResponse.results.isSuccess == true {
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

extension RequestCheckCode {
    struct CheckCode: Codable {
        let email: String
        let verifyCode: String //
    }
    struct TmpCheckCodeResponse: Codable {
        let isSuccess: Bool
    }
    struct CheckCodeResponse: Codable {
        let results: TmpCheckCodeResponse
    }
}
