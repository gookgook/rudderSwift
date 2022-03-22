//
//  RequestNickChange.swift
//  Rudder
//
//  Created by 박민호 on 2022/01/21.
//


import Foundation

struct RequestNickChange {
    static func uploadInfo(nickname: String, completion: @escaping (Int) -> Void) -> Void{
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        let ncRequest = NcRequest(token: token, nickname: nickname)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(ncRequest) else {
          return
        }
        
        let url = URL(string: Utils.urlKey+"/users/updateNickname")!
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
                
                let decodedResponse: ResponseTypical = try decoder.decode(ResponseTypical.self, from: data)
                if decodedResponse.results.isSuccess {
                    completion(1) // main thread에다가 넣어야하나? UI update때매? requestUpdateCategory에서는 그렇게 했음
                }else{
                    if decodedResponse.results.error == "duplicate" { completion(2) }
                    else{ completion(-1) }// ''
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

struct NcRequest: Codable {
    let token: String
    let nickname: String
}
