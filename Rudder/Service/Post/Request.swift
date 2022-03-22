//
//  Request.swift
//  Rudder
//
//  Created by Brian Bae on 15/07/2021.
//

import UIKit

struct Response: Codable {
    let posts: [Post]
    
}

struct Request {
    
    private static let postsURL: URL = URL(string: (Utils.urlKey + "/board/renderPost"))!
}

extension Request {
    static func posts( categoryId: Int , endPostId: Int, searchbody: String, completion: @escaping (_ posts: [Post]?) -> Void) {
        
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        print(categoryId)
        
        
        let uploadData = RequestInfo(boardType: "bulletin", pagingIndex: 0 , endPostId: endPostId , categoryId: categoryId, token: token, searchBody: searchbody)
   
        var request = URLRequest(url: postsURL)
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

            
            let decoder:JSONDecoder = JSONDecoder()
            do {
                let TResponse: [Post] = try decoder.decode([Post].self, from: data)
                let decodedResponse: Response = Response(posts: TResponse)
                //let decodedResponse: Response = try decoder.decode(Response.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse.posts)
                }
            } catch {
                print("응답 디코딩 실패 헀음")
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

extension Request{
    struct RequestInfo: Codable {
        let boardType: String 
        let pagingIndex: Int
        let endPostId: Int
        let categoryId: Int
        let token: String
        let searchBody: String
        //let searchBody: String
        
        enum CodingKeys: String, CodingKey {
            case boardType = "board_type"
            case categoryId = "category_id"
            case pagingIndex, endPostId, token, searchBody
        }
        
    }
}
