import UIKit

struct School: Codable {
    let schoolId: Int
    let schoolName: String
    
    enum CodingKeys: String, CodingKey {
        case schoolId = "school_id"
        case schoolName = "school_name"
    }
}
struct ResponseSchool: Codable {
    let schools: [School]
    
    enum CodingKeys: String, CodingKey {
        case schools = "results"
    }
}

struct RequestSchool {
    private static let schoolsURL: URL = URL(string: Utils.urlKey+"/signupin/schoolList")!
}

extension RequestSchool {
    static func schools( completion: @escaping (_ schools: [School]?) -> Void) {
        
        var request = URLRequest(url: schoolsURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
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
            
            //if let JSONString = String(data: data, encoding: String.Encoding.utf8) { print(JSONString) }
            
            let decoder:JSONDecoder = JSONDecoder()
            do {
                
                let decodedResponse: ResponseSchool = try decoder.decode(ResponseSchool.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse.schools)
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
