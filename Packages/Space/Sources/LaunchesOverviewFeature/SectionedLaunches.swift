//
//  SectionedLaunches.swift
//  Space
//
//  Created by Luca Gobbo on 17/10/2026.
//

import Foundation
import SpaceDomain

nonisolated struct SectionedLaunches: Equatable {
    // MARK: - Properties
    var upcoming: [Launch]
    var past: [Launch]
    var isEmpty: Bool { upcoming.isEmpty && past.isEmpty }

    static let empty = Self.init(upcoming: [], past: [])

    // MARK: - init

    init(upcoming: [Launch], past: [Launch]) {
        self.upcoming = upcoming
        self.past = past
    }

    init(launches: [Launch], now: Date) {
        self.init(
            upcoming:
                launches
                .filter { ($0.date ?? .distantFuture) >= now }
                .sorted { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture) },
            past:
                launches
                .filter { ($0.date ?? .distantFuture) < now }
                .sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
        )
    }
}
