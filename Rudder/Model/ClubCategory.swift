//
//  ClubCategory.swift
//  Rudder
//
//  Created by Brian Bae on 01/10/2021.
//

import Foundation

struct ClubCategory: Codable {
    let categoryId: Int
    let categoryName: String
    let schoolId: Int
    let categoryType: String
    let isMember: String
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case categoryName = "category_name"
        case schoolId = "school_id"
        case categoryType = "category_type"
        case isMember
    }
}
