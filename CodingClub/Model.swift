//
//  Model.swift
//  CodingClub
//
//  Created by Aang Muammar Zein on 11/07/23.
//

struct ResponseModelWithoutData: Codable {
    var code: Int
    var status: Bool
    var message: String
}

struct ResponseModel: Codable {
    var code: Int
    var status: Bool
    var message: String
    var data:[DataModel]
}

struct DataModel: Codable,Hashable {
    var id: String
    var translate_en: String
    var translate_id: String
    var created_at: String
}
