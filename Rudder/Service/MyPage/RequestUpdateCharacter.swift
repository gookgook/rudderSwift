//
//  RequestUpdateCharacter.swift
//  Rudder
//
//  Created by 박민호 on 2022/01/21.
//

import Foundation


struct RequestUpdateCharacter {
    static func uploadInfo(profileImageId: Int, completion: @escaping (Int) -> Void) -> Void{
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        let ccRequest = CcRequest(token: token, profileImageId: profileImageId)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(ccRequest) else {
          return
        }
        
        let url = URL(string: Utils.urlKey+"/users/updateUserProfileImage")!
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
            
            guard let data = data, error == nil else {
                print("server error")
                return
            }
            
            let decoder:JSONDecoder = JSONDecoder()
            do {
                
                let decodedResponse: ResponseTypical = try decoder.decode(ResponseTypical.self, from: data)
                if decodedResponse.results.isSuccess { completion(1) }// main thread에다가 넣어야하나? UI update때매? requestUpdateCategory에서는 그렇게 했음
                else{ completion(-1) }
                
            } catch {
                print("응답 디코딩 실패")
                print(error.localizedDescription)
                dump(error)
                DispatchQueue.main.async {  //왜 dispatchqueue에 넣음? UI때문?
                    completion(-1)
                }
            }
            
            completion(1)
        })
        task.resume()
    }
}

struct CcRequest: Codable {
    let token: String
    let profileImageId: Int
}
