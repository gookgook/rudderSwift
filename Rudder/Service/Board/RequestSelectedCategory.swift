//
//  RequestSelectedCategory.swift
//  Rudder
//
//  Created by Brian Bae on 05/10/2021.
//



import Foundation




struct RequestSelectedCategory {
    private static let categoryURL: URL = URL(string: Utils.urlKey+"/board/userSelectCategoryList")!
}

extension RequestSelectedCategory {
    static func categories( completion: @escaping (_ categories: [Category]?) -> Void) {
        
        guard let token: String = UserDefaults.standard.string(forKey: "token"),
              token.isEmpty == false else {
            print("no token")
            return
        }
        
        var request = URLRequest(url: categoryURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let uploadData = CRequest(token: token)
        
        guard let EncodedUploadData = try? JSONEncoder().encode(uploadData) else {
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
                    completion(nil)
                }
                return
            }
            
            /*if let JSONString = String(data: data, encoding: String.Encoding.utf8) { //지워야함
               print(JSONString)
            }*/
            
            let decoder:JSONDecoder = JSONDecoder()
            do {
                
                let decodedResponse: ResponseCategory = try decoder.decode(ResponseCategory.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse.categories)
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


