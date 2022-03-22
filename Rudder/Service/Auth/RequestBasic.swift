//
//  RequestBasic.swift
//  Rudder
//
//  Created by Brian Bae on 05/08/2021.
//

import Foundation

struct RequestBasic {
    //login
    static func uploadInfo(EncodedUploadData: Data, completion: @escaping (Int) -> Void) -> Void{

   
        let url = URL(string: (Utils.urlKey + "/signupin/loginJWT"))!
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
            //lewandowski
            guard let data = data, error == nil else {
                print("server error")
                return
            }
            let decoder:JSONDecoder = JSONDecoder()
            do {
                let decodedResponse: LoginResponse = try decoder.decode(LoginResponse.self, from: data)
                
                if decodedResponse.results.success == true {
                    print("login success")
                    UserDefaults.standard.set(decodedResponse.results.token, forKey: "token")
                    UserDefaults.standard.synchronize()
                    completion(1)
                }else{
                    if decodedResponse.results.error == "IDWRONG" || decodedResponse.results.error == "PASSWORDWRONG" {
                        print("ID or Password Wrong")
                        completion(2)
                    }else{
                        print("server error")
                    }
                }
               } catch let error as NSError {
                   print(error)
               }
            
            completion(3)
        })
        task.resume()
    }
    
    //idDuplicationCheck
    static func checkIdDuplication(EncodedUploadData: Data, completion: @escaping (Int) -> Void) -> Void{
        let url = URL(string: Utils.urlKey+"/signupin/checkduplication")!
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
            
            guard let data = data else {
                print("전달받은 데이터 없음")
                DispatchQueue.main.async {
                    completion(3)
                }
                return
            }
            
            
            if let JSONString = String(data: data, encoding: String.Encoding.utf8) { //지워야함
               print(JSONString)
            }
            
            let decoder:JSONDecoder = JSONDecoder()
            do {
                
                let decodedResponse: DuplicateResponse = try decoder.decode(DuplicateResponse.self, from: data)
                DispatchQueue.main.async {
                    if decodedResponse.results.isDuplicated == true {
                        completion(1)
                    }else{
                        completion(2)
                    }
                }
            } catch {
                print("응답 디코딩 실패")
                print(error.localizedDescription)
                dump(error)
                DispatchQueue.main.async {
                    completion(3)
                }
            }
        })
        //spinner.stopAnimating()
        task.resume()
        
       // return status
    }
    
    
    //verifyemail
    static func verifyEmail(EncodedUploadData: Data, completion: @escaping (Int) -> Void) -> Void{
        let url = URL(string: Utils.urlKey+"/signupin/checkduplication")!
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
            
            
            guard let data = data else {
                print("전달받은 데이터 없음")
                DispatchQueue.main.async {
                    completion(3)
                }
                return
            }
            
            
            if let JSONString = String(data: data, encoding: String.Encoding.utf8) { //지워야함
               print(JSONString)
            }
            
            let decoder:JSONDecoder = JSONDecoder()
            do {
                /*let TResponse: [Comment] = try decoder.decode([Comment].self, from: data)
                let decodedResponse: ResponseComment = ResponseComment(comments: TResponse)*/
                
                let decodedResponse: DuplicateResponse = try decoder.decode(DuplicateResponse.self, from: data)
                DispatchQueue.main.async {
                    if decodedResponse.results.isDuplicated == true {
                        completion(1)
                    }else{
                        completion(2)
                    }
                }
            } catch {
                print("응답 디코딩 실패")
                print(error.localizedDescription)
                dump(error)
                DispatchQueue.main.async {
                    completion(3)
                }
            }
        })
        //spinner.stopAnimating()
        task.resume()
        
       // return status
    }
    
}

struct IsDuplicated: Codable {
    let isDuplicated: Bool
}
struct DuplicateResponse : Codable {
    let results: IsDuplicated
}
struct LoginSuccess: Codable {
    let success: Bool
    let error: String
    let token: String
}
struct LoginResponse: Codable{
    let results: LoginSuccess
}
