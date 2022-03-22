//
//  RequestMessages.swift
//  Rudder
//
//  Created by 박민호 on 2022/01/26.
//

import Foundation

struct MessageResponse: Codable {
    let results: ResponseMessage
}

struct ResponseMessage: Codable {
    let isSuccess: Bool
    let error: String
    let messages: [Message]
}

struct RequestMessages {
    private static let categoryURL: URL = URL(string: Utils.urlKey+"/message/getMessagesByRoom")!
}

extension RequestMessages {
    static func messages( postMessageRoomId: Int, completion: @escaping (_ messages: [Message]?) -> Void) {
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        var request = URLRequest(url: categoryURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let uploadData = MRequest2(token: token, postMessageRoomId: postMessageRoomId)
        guard let EncodedUploadData = try? JSONEncoder().encode(uploadData) else { return }

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
            
          //isSuccess false 인거도 처리
            
            let decoder:JSONDecoder = JSONDecoder()
            do {
                
                let decodedResponse: MessageResponse = try decoder.decode(MessageResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse.results.messages)
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

extension RequestMessages {
    struct MRequest2: Codable {
        let token: String
        let postMessageRoomId: Int
    }
}
