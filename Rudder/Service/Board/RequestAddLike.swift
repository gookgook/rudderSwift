//
//  RequestAddLike.swift
//  Rudder
//
//  Created by Brian Bae on 26/08/2021.
//

import Foundation

struct LikeResponse: Codable {
    let isSuccess: Bool
    let likeCount: Int
    
    enum CodingKeys: String, CodingKey {
        case isSuccess
        case likeCount = "like_count"
    }
}
struct ResponseLike: Codable {
    let results: LikeResponse
}

struct RequestAddLike {
    static func uploadInfo(addLikeData: AddLikeData, completion: @escaping (Int) -> Void) -> Void{
        
        guard let EncodedUploadData = try? JSONEncoder().encode(addLikeData) else {
          return
        }
        
        let url = URL(string: Utils.urlKey+"/board/addlike")!
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
                
                let decodedResponse: ResponseLike = try decoder.decode(ResponseLike.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse.results.likeCount)
                }
            } catch {
                print("응답 디코딩 실패")
                print(error.localizedDescription)
                dump(error)
                DispatchQueue.main.async {
                    completion(-1)
                }
            }
            
            completion(1)
        })
        task.resume()
    }
}
