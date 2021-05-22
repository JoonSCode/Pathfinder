//
//  PathModel.swift
//  Pathfinder
//
//  Created by 윤준수 on 2021/05/22.
//

import Foundation

struct PathModel: Codable {
    var features: [PathPoint]
}

struct PathPoint: Codable {
    var geometry: Geometry
    var properties: Property
}

struct Geometry: Codable {
    let type: GeometryType
    let coordinates: [Coordinate]
}

enum Coordinate: Codable {
    case double(Double)
    case doubleArray([Double])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([Double].self) {
            self = .doubleArray(x)
            return
        }
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        throw DecodingError.typeMismatch(Coordinate.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Coordinate"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let x):
            try container.encode(x)
        case .doubleArray(let x):
            try container.encode(x)
        }
    }
}

enum GeometryType: String, Codable {
    case Point, LineString
}

struct Property: Codable {
    var description: String
    var turnType: Int?
    var pointType: String?
}
