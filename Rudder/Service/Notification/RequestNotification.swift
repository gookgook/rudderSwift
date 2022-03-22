//
//  RequestNotification.swift
//  Rudder
//
//  Created by 박민호 on 2022/02/21.
//

import Foundation

struct ResponseNotification: Codable {
    let comments: [Comment]
    
    enum CodingKeys: String, CodingKey {
        case comments = "results"
    }
}

struct RequestNotification {
    
    private static let postsURL: URL = URL(string: Utils.urlKey+"/notificationApi/getNotifications")!
}

extension RequestNotification {
    static func notifications( completion: @escaping (_ notifications: [UserNotification]?) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("token failure")
            return
        }
        
        let uploadData = NRequest(token: token)
   
        var request = URLRequest(url: postsURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let EncodedUploadData = try? JSONEncoder().encode(uploadData) else {
            return
        }
        //print(uploadData)
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
                    completion(nil)
                }
                return
            }
            
            let decoder:JSONDecoder = JSONDecoder()
            do {
                
                let decodedResponse: ResponseN = try decoder.decode(ResponseN.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse.results.notifications)
                }
            } catch {
                print("응답 디코딩 실패")
                print(error.localizedDescription)
                dump(error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        })
        task.resume()
    }
}

extension RequestNotification{
    struct NRequest: Codable {
        let token: String
    }
    
    struct NResponse: Codable {
        let isSuccess: Bool
        let error: String
        let notifications: [UserNotification]
    }
    
    struct ResponseN: Codable {
        let results: NResponse
    }
}
