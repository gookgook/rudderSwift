//
//  RequestServerNotice.swift
//  Rudder
//
//  Created by Brian Bae on 12/09/2021.
//

import Foundation

struct GetNotice: Codable {
    let results: TmpGetNotice
}
struct TmpGetNotice: Codable {
    let isExist: Bool
    let notice: String

}

struct RequestServerNotice {
    //login
    static func uploadInfo( completion: @escaping (String?) -> Void) -> Void{ // completion optional!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        let url = URL(string: Utils.urlKey+"/signupin/getNotice")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dictionary = Bundle.main.infoDictionary
        guard dictionary != nil else {return}
        guard let version = dictionary!["CFBundleShortVersionString"] as? String else {return}
        
        print(version)
        
        let noticeRequest = NoticeRequest(os: "ios", version: version)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(noticeRequest) else {
          
            return
         }
      
        let task = URLSession.shared.uploadTask(with: request, from: EncodedUploadData, completionHandler: { (data, response, error) in
            if let error = error {
                print ("error: \(error)")
                completion(nil) //이번에 추가한거
                return
            }
            guard let response = response as? HTTPURLResponse,
                (200...299).contains(response.statusCode) else {
                print ("server error")
                completion(nil) //이번에 추가한거
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
                let TResponse: GetNotice = try decoder.decode(GetNotice.self, from: data)
                //let decodedResponse: Response = try decoder.decode(Response.self, from: data)
                if TResponse.results.isExist == true { completion(TResponse.results.notice) }
                else  {completion(nil) }
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

struct NoticeRequest: Codable {
    let os: String
    let version: String
}
