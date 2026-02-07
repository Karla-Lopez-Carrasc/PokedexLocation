//
//  Pokemon.swift
//  diplomado-10-pokedex-kits
//
//  Created by Alejandro Mendoza on 17/01/26.
//

import Foundation

struct Pokemon: Codable {

    struct Location: Codable {
        let latitude: Double
        let longitude: Double
    }

    struct Evolution: Codable {
        let name: String
        let num: String
    }

    let id: Int
    let number: String
    let name: String
    let imageURL: String
    let type: [String]
    let weaknesses: [String]?
    let prevEvolution: [Evolution]?
    let nextEvolution: [Evolution]?
    let location: Location?

    private enum CodingKeys: String, CodingKey {
        case id
        case number = "num"
        case name
        case imageURL = "img"
        case type
        case weaknesses
        case prevEvolution = "prev_evolution"
        case nextEvolution = "next_evolution"
        case location
    }
}
