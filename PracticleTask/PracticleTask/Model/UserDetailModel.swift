//
//  UserDetailModel.swift
//  PracticleTask
//
//  Created by krina kalariya on 26/04/24.
//

import Foundation

struct UserDetailModel: Codable {
    let userID, id: Int?
    let title, body: String?

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case id, title, body
    }
}
