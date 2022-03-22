//
//  RequestSendId.swift
//  Rudder
//
//  Created by 박민호 on 2022/02/14.
//

import Foundation

struct RequestSendId{
    private static let sendIdURL: URL = URL(string: Utils.urlKey+"/signupin/sendIdToEmail")!
}

extension RequestSendId {
    static func uploadInfo( email: String , completion: @escaping  (Bool) -> Void) -> Void {
        
        var request = URLRequest(url: sendIdURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let uploadData = MailToSend(email: email)
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
                
                let decodedResponse: ResponseMailSend = try decoder.decode(ResponseMailSend.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse.results.sendIdToEmail)
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

struct MailToSend: Codable {
    let email: String
}

struct MailSendResponse: Codable {
    let sendIdToEmail: Bool
}
struct ResponseMailSend: Codable {
    let results: MailSendResponse
}
