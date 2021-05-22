//
//  LocationModel.swift
//  Pathfinder
//
//  Created by 윤준수 on 2021/05/22.
//

import Foundation

struct LocationModel: Codable {
    var searchPoiInfo: SearchPoiInfo
}

struct SearchPoiInfo: Codable {
    var pois: Pois
    struct Pois: Codable {
        var poi: [Poi]
    }
}

struct Poi: Codable {
    var name: String
    var latitude: String
    var longitude: String
    var distance: String

    enum CodingKeys: String, CodingKey {
        case name
        case latitude = "noorLat"
        case longitude = "noorLon"
        case distance = "radius"
    }
}
