//
//  RequestSendMessage.swift
//  Rudder
//
//  Created by 박민호 on 2022/02/08.
//

import Foundation

struct RequestSendMessage{
    private static let categoryURL: URL = URL(string: Utils.urlKey+"/message/sendPostMessage")!
}

extension RequestSendMessage {
    static func uploadInfo( receiveUserInfoId: Int, messageBody: String, completion: @escaping  (Bool) -> Void) -> Void {
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        var request = URLRequest(url: categoryURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let uploadData = MessageToSend(token: token, receiveUserInfoId: receiveUserInfoId, messageBody: messageBody)
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
                    completion(false)
                }
                return
            }
            
          //isSuccess false 인거도 처리
            
            let decoder:JSONDecoder = JSONDecoder()
            do {
                
                let decodedResponse: ResponseTypical = try decoder.decode(ResponseTypical.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse.results.isSuccess)
                }
            } catch {
                print("응답 디코딩 실패")
                print(error.localizedDescription)
                dump(error)
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        })
        task.resume()
    }
}

struct MessageToSend: Codable {
    let token: String
    let receiveUserInfoId: Int
    let messageBody: String
}
