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

    // MARK: - init
    public init(items: [Item], isLastPage: Bool) {
        self.items = items
        self.isLastPage = isLastPage
    }
}
