//
//  RequestPhotoUrl.swift
//  Rudder
//
//  Created by Brian Bae on 06/09/2021.
//

import Foundation

struct GetUrlResponse: Codable {
    let urls: [String]
}
struct ResponseGetUrl: Codable {
    let results: GetUrlResponse
}

struct RequestPhotoUrl {
    //login
    static func uploadInfo(postId: Int, photoType:String, completion: @escaping ([String]?) -> Void) -> Void{ // completion optional!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        let url = URL(string: Utils.urlKey+"/board/getUploadSignedUrls")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        let urlGetRequest = UrlGetRequest(contentTypes: [photoType], token: token, postId: postId)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(urlGetRequest) else {
          
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
                    completion(nil)  //error handle !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                }
                return
            }
            
            let decoder:JSONDecoder = JSONDecoder()
            do {
                let TResponse: ResponseGetUrl = try decoder.decode(ResponseGetUrl.self, from: data)
                //let decodedResponse: Response = try decoder.decode(Response.self, from: data)
                DispatchQueue.main.async {
                    completion(TResponse.results.urls)
                }
            } catch {
                print("응답 디코딩 실패")
                print(error.localizedDescription)
                dump(error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
            
            
            //completion(1)
        })
        task.resume()
    }
}

struct UrlGetRequest: Codable {
    let contentTypes: [String]
    let token: String
    let postId: Int
    
    enum CodingKeys: String, CodingKey {
        case contentTypes, token
        case postId = "post_id"
    }
}
