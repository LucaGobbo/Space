//
//  RocketsResponseDTO.swift
//  SpaceAPI
//
//  Created by Luca Gobbo on 18/10/2026.
//

import Foundation

public struct RocketsResponseDTO: Decodable, Sendable {
    // MARK: - Properties
    public let count: Int
    public let next: URL?
    public let previous: URL?
    public let results: [Rocket]

    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    /// A launcher configuration.
    public struct Rocket: Decodable, Sendable, Identifiable {
        public let id: Int
        public let name: String
        public let fullName: String?
        public let variant: String?
        public let active: Bool?
        public let image: Image?
        public let successfulLaunches: Int?
        public let failedLaunches: Int?
        public let description: String?
        public let families: [Family]?
        public let reusable: Bool?
        public let minStage: Int?
        public let maxStage: Int?
    }

    public struct Family: Decodable, Sendable {
        public let name: String
    }

    public struct Image: Decodable, Sendable {
        public let imageUrl: URL?
    }
}
