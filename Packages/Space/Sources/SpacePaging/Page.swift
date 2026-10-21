//
//  Page.swift
//  SpacePaging
//
//  Created by Luca Gobbo on 17/10/2026.
//

public nonisolated struct Page<Item: Sendable>: Sendable {
    // MARK: - Properties
    public let items: [Item]
    public let isLastPage: Bool
    public var totalCount: Int

    // MARK: - init
    public init(items: [Item], isLastPage: Bool, totalCount: Int) {
        self.items = items
        self.isLastPage = isLastPage
        self.totalCount = totalCount
    }
}
