//
//  RequestMessageRooms.swift
//  Rudder
//
//  Created by 박민호 on 2022/01/24.
//

import Foundation

struct MessageRoomResponse: Codable {
    let results: ResponseMessageRoom
}

struct ResponseMessageRoom: Codable {
    let isSuccess: Bool
    let error: String
    let rooms: [MessageRoom]
}

struct RequestMessageRooms {
    private static let categoryURL: URL = URL(string: Utils.urlKey+"/message/getMyMessageRooms")!
}

extension RequestMessageRooms {
    static func messageRooms( completion: @escaping (_ messageRooms: [MessageRoom]?) -> Void) {
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        var request = URLRequest(url: categoryURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let uploadData = MRequest(token: token)
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
                
                let decodedResponse: MessageRoomResponse = try decoder.decode(MessageRoomResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse.results.rooms)
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
extension RequestMessageRooms {

    struct MRequest: Codable {
        let token: String
    }
}
