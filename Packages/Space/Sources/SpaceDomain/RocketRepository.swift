//
//  RocketRepository.swift
//  SpaceDomain
//
//  Created by Luca Gobbo on 18/10/2026.
//

import Foundation

public struct RocketPage: Sendable, Hashable {
    // MARK: - Properties
    public var rockets: [Rocket]
    public var totalCount: Int
    public var isLastPage: Bool

    // MARK: - init
    public init(rockets: [Rocket], totalCount: Int, isLastPage: Bool) {
        self.rockets = rockets
        self.totalCount = totalCount
        self.isLastPage = isLastPage
    }
}

/// Where view models get rockets from, without knowing where they originate.
public protocol RocketRepository: Sendable {
    func rockets(limit: Int, offset: Int) async throws -> RocketPage
    func rocket(id: Int) async throws -> Rocket
}
