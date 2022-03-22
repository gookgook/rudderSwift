//
//  RequestCheckNickname.swift
//  Rudder
//
//  Created by Brian Bae on 10/09/2021.
//

import Foundation

struct RequestCheckNickname {
    static func checkDuplication(nickname: String, completion: @escaping (Int) -> Void) -> Void{
        let url = URL(string: Utils.urlKey+"/signupin/checkDuplicationNickname")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let nicknameCheck = NicknameCheck(nickname: nickname)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(nicknameCheck) else {
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
                DispatchQueue.main.async { completion(3) }
                return
            }
            
            if let JSONString = String(data: data, encoding: String.Encoding.utf8) { //지워야함
               print(JSONString)
            }
            
            let decoder:JSONDecoder = JSONDecoder()
            do {
                let decodedResponse: DuplicateResponse = try decoder.decode(DuplicateResponse.self, from: data)  //duplicatedresponse 정의는 requestbasic에 
                DispatchQueue.main.async {
                    if decodedResponse.results.isDuplicated == true {
                        completion(1)
                    }else{
                        completion(2)
                    }
                }
            } catch {
                print("응답 디코딩 실패")
                print(error.localizedDescription)
                dump(error)
                DispatchQueue.main.async {
                    completion(3)
                }
            }
        })
        //spinner.stopAnimating()
        task.resume()
        
       // return status
    }
}

struct NicknameCheck: Codable {
    let nickname: String
}
