//
//  RequestComment.swift
//  Rudder
//
//  Created by Brian Bae on 28/07/2021.
//

import Foundation

struct ResponseComment: Codable {
    let comments: [Comment]
    
    enum CodingKeys: String, CodingKey {
        case comments = "results"
    }
}

struct RequestComment {
    
    private static let postsURL: URL = URL(string: Utils.urlKey+"/comment/showComment")!
}

extension RequestComment {
    static func comments( postId:Int, completion: @escaping (_ comments: [Comment]?) -> Void) {
        
        
        guard let token = UserDefaults.standard.string(forKey: "token") else {
            print("token failure")
            return
        }
        
        let uploadData = RequestInfoComment(postId: postId, token: token)
   
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
                
                let decodedResponse: ResponseComment = try decoder.decode(ResponseComment.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse.comments)
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

extension RequestComment{
    struct RequestInfoComment: Codable {
        let postId: Int
        let token: String
        
        enum CodingKeys: String, CodingKey {
            case postId = "post_id"
            case token
        }
        
    }
}

