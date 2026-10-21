//
//  RocketService.swift
//  SpaceAPI
//
//  Created by Luca Gobbo on 18/10/2026.
//

import Foundation
private import OSLog

public struct RocketService: Sendable {
    // MARK: - Properties
    public var environment: APIEnvironment
    public var session: URLSession

    // MARK: - init
    public init(
        environment: APIEnvironment,
        session: URLSession = .shared
    ) {
        self.environment = environment
        self.session = session
    }

    // MARK: - API

    /// `GET /launcher_configurations/`: one page of rockets, optionally filtered by manufacturer name.
    public func rockets(
        limit: Int = 10,
        offset: Int = 0,
        manufacturer: String? = nil
    ) async throws -> RocketsResponseDTO {
        guard
            var components = URLComponents(
                url: environment.baseURL.appending(path: "launcher_configurations/"),
                resolvingAgainstBaseURL: false
            )
        else {
            throw URLError(.badURL)
        }
        components.queryItems = [
            URLQueryItem(name: "mode", value: "detailed"),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        if let manufacturer {
            components.queryItems?.append(URLQueryItem(name: "manufacturer__name", value: manufacturer))
        }

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        Logger(subsystem: "io.spacex.rocketservice", category: "api").info("\(url)")

        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try RocketsResponseDTO.decoder.decode(RocketsResponseDTO.self, from: data)
    }

    /// `GET /launcher_configurations/{id}/`: one rocket with all its details.
    public func rocket(id: Int) async throws -> RocketsResponseDTO.Rocket {
        guard
            var components = URLComponents(
                url: environment.baseURL.appending(path: "launcher_configurations/\(id)/"),
                resolvingAgainstBaseURL: false
            )
        else {
            throw URLError(.badURL)
        }
        components.queryItems = [URLQueryItem(name: "mode", value: "detailed")]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        Logger(subsystem: "io.spacex.rocketservice", category: "api").info("\(url)")

        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try RocketsResponseDTO.decoder.decode(RocketsResponseDTO.Rocket.self, from: data)
    }
}
