//
//  RequestMyPost.swift
//  Rudder
//
//  Created by 박민호 on 2022/03/03.
//

import Foundation

struct RequestMyPost {

    private static let postsURL: URL = URL(string: (Utils.urlKey + "/board/myPosts"))!
    private static let commentsURL: URL = URL(string: (Utils.urlKey + "/board/postsWithMyComment"))!
}

extension RequestMyPost {
    static func posts( myPostOrComment: Int ,offset: Int, completion: @escaping (_ posts: [Post]?) -> Void) {
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        
        let uploadData = RequestInfo(token: token, offset: offset)
   
        var request: URLRequest
        if myPostOrComment == 0 { request = URLRequest(url: postsURL) }
        else { request = URLRequest(url: commentsURL) }
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
            
            
            //isSuccess false도 처리
            let decoder:JSONDecoder = JSONDecoder()
            do {
                let decodedResponse: ResponseMyPost = try decoder.decode(ResponseMyPost.self, from: data)
                print("post",decodedResponse.results.posts.count)
                DispatchQueue.main.async {
                    completion(decodedResponse.results.posts)
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

extension RequestMyPost{
    
    struct MyPostResponse: Codable {
        let isSuccess: Bool
        let error: String
        let posts: [Post]
    }
    struct ResponseMyPost: Codable {
        let results: MyPostResponse
    }
    
    struct RequestInfo: Codable {

        let token: String
        let offset: Int
    }
}
