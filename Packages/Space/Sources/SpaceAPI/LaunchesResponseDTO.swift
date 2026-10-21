//
//  LaunchesResponseDTO.swift
//  SpaceAPI
//
//  Created by Luca Gobbo on 17/10/2026.
//

import Foundation

public struct LaunchesResponseDTO: Decodable, Sendable {
    // MARK: - Properties
    public var count: Int
    public var next: URL?
    public var previous: URL?
    public var results: [Launch]

    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    public struct Launch: Decodable, Sendable, Identifiable {
        public let id: String
        public var name: String
        public var net: Date?
        public var status: Status?
        public var image: Image?
        public var pad: Pad?
        public var mission: Mission?
        public var rocket: Rocket?
    }

    public struct Status: Decodable, Sendable {
        public var name: String
        public var abbrev: String
    }

    public struct Image: Decodable, Sendable {
        public var imageUrl: URL?
    }

    /// Launch site.
    public struct Pad: Decodable, Sendable {
        public var latitude: Double?
        public var longitude: Double?
        public var location: Location?

        public struct Location: Decodable, Sendable {
            // MARK: - Properties
            public var name: String
        }
    }

    public struct Mission: Decodable, Sendable {
        public var description: String?
        /// Links to watch the launch.
        public var vidUrls: [VideoURL]

        public struct VideoURL: Decodable, Sendable {
            // MARK: - Properties
            public var url: URL
        }
    }

    public struct Rocket: Decodable, Sendable {
        public var configuration: Configuration

        public struct Configuration: Decodable, Sendable {
            public let id: Int
            public var name: String
            public var fullName: String?
            public var variant: String?
        }
    }
}
