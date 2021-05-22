//
//  DangerLocationModel.swift
//  Pathfinder
//
//  Created by 윤준수 on 2021/05/22.
//

import Foundation

struct DangerLocationModel: Codable {
    var response: Payload
}

struct Payload: Codable {
    var payload: [DangerLocationData]
}

struct DangerLocationData: Codable {
//    var id: Int
    var rideType: RideType
    var impulse: Impulse
    var latitude: String
    var longitude: String
//    var createdAt: String
//    var updatedAt: String

    enum RideType: String, Codable {
        case bicycle
        case kickBoard = "kick_board"
    }

    enum CodingKeys: String, CodingKey {
//        case id
        case rideType = "ride_type"
        case impulse
        case latitude = "lat"
        case longitude = "lng"
//        case createdAt = "created_at"
//        case updatedAt = "updated_at"
    }
}

struct Impulse: Codable {
    var text: String
    var level: Int
}
