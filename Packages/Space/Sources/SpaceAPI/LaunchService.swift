//
//  LaunchService.swift
//  SpaceAPI
//
//  Created by Luca Gobbo on 17/10/2026.
//

import Foundation
private import OSLog

public struct LaunchService: Sendable {
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

    /// `GET /launches/`: one page of launches,
    /// optionally filtered by launch service provider (agency) id and net (launch) date range.
    public func launches(
        limit: Int = 10,
        offset: Int = 0,
        agencyID: Int? = nil,
        range: ClosedRange<Date>? = nil
    ) async throws -> LaunchesResponseDTO {
        guard
            var components = URLComponents(
                url: environment.baseURL.appending(path: "launches/"),
                resolvingAgainstBaseURL: false
            )
        else {
            throw URLError(.badURL)
        }
        components.queryItems = [
            URLQueryItem(name: "mode", value: "normal"),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        if let agencyID {
            components.queryItems?.append(URLQueryItem(name: "lsp__id", value: String(agencyID)))
        }

        if let range {
            components.queryItems?.append(URLQueryItem(name: "net__gte", value: range.lowerBound.formatted(.iso8601)))
            components.queryItems?.append(URLQueryItem(name: "net__lte", value: range.upperBound.formatted(.iso8601)))
        }

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        Logger(subsystem: "io.spacex.launchservice", category: "api").info("\(url)")

        let (data, response) = try await session.data(from: url)

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try LaunchesResponseDTO.decoder.decode(LaunchesResponseDTO.self, from: data)
    }
}
