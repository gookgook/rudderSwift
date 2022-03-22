//
//  Category.swift
//  Rudder
//
//  Created by Brian Bae on 05/09/2021.
//

import Foundation

struct Category: Codable {
    let categoryId: Int
    let categoryName: String
    let isSelect: Bool! //이거 selected에는 isselect 안오는거때매
    let categoryType: String
    let categoryAbbreviation: String
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case categoryName = "category_name"
        case isSelect
        case categoryType = "category_type"
        case categoryAbbreviation = "category_abbreviation"
    }
}
