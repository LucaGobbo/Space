//
//  LaunchRepository.swift
//  SpaceDomain
//
//  Created by Luca Gobbo on 17/10/2026.
//

import Foundation

public struct LaunchPage: Sendable, Hashable {
    // MARK: - Properties
    public var launches: [Launch]
    public var totalCount: Int
    public var isLastPage: Bool

    // MARK: - init
    public init(launches: [Launch], totalCount: Int, isLastPage: Bool) {
        self.launches = launches
        self.totalCount = totalCount
        self.isLastPage = isLastPage
    }
}

/// Where view models get launches from, without knowing where they originate.
public protocol LaunchRepository: Sendable {
    /// - Parameter range: only launches scheduled within these dates; `nil` for all of them.
    func launches(in range: ClosedRange<Date>?, limit: Int, offset: Int) async throws -> LaunchPage
}

extension LaunchRepository {
    public func launches(limit: Int, offset: Int) async throws -> LaunchPage {
        try await launches(in: nil, limit: limit, offset: offset)
    }
}
