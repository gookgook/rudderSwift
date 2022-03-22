//
//  RequestSinglePost.swift
//  Rudder
//
//  Created by 박민호 on 2022/03/01.
//

import Foundation



struct RequestSinglePost {
    private static let categoryURL: URL = URL(string: Utils.urlKey+"/board/postFromPostId")!
}

extension RequestSinglePost {
    static func singlePost(postId: Int ,completion: @escaping (_ post: Post?) -> Void) {
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        var request = URLRequest(url: categoryURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let uploadData = SPRequest(token: token, postId: postId)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(uploadData) else {
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
            guard let data = data else {
                print("전달받은 데이터 없음")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let decoder:JSONDecoder = JSONDecoder()
            do {
                
                let decodedResponse: ResponseSP = try decoder.decode(ResponseSP.self, from: data)
                guard decodedResponse.results.error != "delete" else {
                    completion(nil)
                    return
                }
                DispatchQueue.main.async {
                    completion(decodedResponse.results.post)
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

extension RequestSinglePost {
    struct SPResponse: Codable {
        let post: Post
        let isSuccess: Bool
        let error: String
    }
    
    struct ResponseSP: Codable {
        let results: SPResponse
    }
    
    struct SPRequest: Codable {
        let token: String
        let postId: Int
    }

}

