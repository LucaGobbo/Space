//
//  Rocket.swift
//  SpaceDomain
//
//  Created by Luca Gobbo on 18/10/2026.
//

import Foundation

public struct Rocket: Sendable, Hashable, Identifiable {
    // MARK: - Properties
    public let id: Int
    public var name: String
    public var fullName: String?
    public var variant: String?
    public var isActive: Bool
    public var imageURL: URL?
    public var successfulLaunches: Int?
    public var failedLaunches: Int?
    public var description: String?
    public var family: String?
    public var isReusable: Bool?
    public var stageCount: Int?

    public var successRate: Double? {
        guard let successfulLaunches, let failedLaunches else { return nil }
        let total = successfulLaunches + failedLaunches
        guard total > 0 else { return nil }
        return Double(successfulLaunches) / Double(total)
    }

    // MARK: - init
    public init(
        id: Int,
        name: String,
        fullName: String?,
        variant: String?,
        isActive: Bool,
        imageURL: URL?,
        successfulLaunches: Int? = nil,
        failedLaunches: Int? = nil,
        description: String? = nil,
        family: String? = nil,
        isReusable: Bool? = nil,
        stageCount: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.variant = variant
        self.isActive = isActive
        self.imageURL = imageURL
        self.successfulLaunches = successfulLaunches
        self.failedLaunches = failedLaunches
        self.description = description
        self.family = family
        self.isReusable = isReusable
        self.stageCount = stageCount
    }
}
