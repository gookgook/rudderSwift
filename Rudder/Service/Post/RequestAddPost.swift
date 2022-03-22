//
//  RequestAddPost.swift
//  Rudder
//
//  Created by Brian Bae on 18/08/2021.
//

import Foundation

struct AddPostResponse: Codable {
    let isSuccess: Bool
    let postId: Int
    
    enum CodingKeys: String, CodingKey {
        case isSuccess
        case postId = "post_id"
    }
}
struct ResponseAddPost: Codable {
    let results: AddPostResponse
}

struct RequestAddPost {
    //login
    static func uploadInfo(boardType: String, postBody: String, categoryId: Int, completion: @escaping (Int) -> Void) -> Void{
        let url = URL(string: Utils.urlKey+"/board/addPost")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        let postToAdd = PostToAdd(boardType: boardType, postTitle: "dummy title", postBody: postBody, token: token, categoryId: categoryId)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(postToAdd) else {
          
            return
         }
      
        let task = URLSession.shared.uploadTask(with: request, from: EncodedUploadData, completionHandler: { (data, response, error) in
            if let error = error {
                print ("error: \(error)")
                completion(-1)
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                completion(-1)
                return
            }
            
            guard let data = data else {
                print("전달받은 데이터 없음")
                DispatchQueue.main.async {
                    completion(-1)
                }
                return
            }
            
            
            let decoder:JSONDecoder = JSONDecoder()
            do {
                let TResponse: ResponseAddPost = try decoder.decode(ResponseAddPost.self, from: data)
                //let decodedResponse: Response = try decoder.decode(Response.self, from: data)
                if TResponse.results.isSuccess == false{
                    completion(-1)
                    return
                }
                DispatchQueue.main.async {
                    completion(TResponse.results.postId)
                }
            } catch {
                print("응답 디코딩 실패")
                print(error.localizedDescription)
                dump(error)
                DispatchQueue.main.async {
                    completion(-1)
                }
            }
            
            
           // completion(1) 사진올리는거때매 두번감
        })
        task.resume()
    }
}

//lewandowski
