//
//  RocketsList.swift
//  Space
//
//  Created by Luca Gobbo on 18/10/2026.
//

import SpaceDomain
import SwiftUI

struct RocketsList: View {

    // MARK: - Properties
    private static let placeholderCount = 10
    private var placeholderCount: Int { min(totalCount - rockets.count, Self.placeholderCount) }

    var rockets: [Rocket]
    var totalCount: Int = 0
    var isPaging: Bool = false
    var nextPage: () -> Void = {}

    // MARK: - Body
    var body: some View {
        List {
            ForEach(rockets) { rocket in
                NavigationLink(value: RocketsRoute.rocket(rocket)) {
                    RocketCell(rocket: rocket)
                }
            }
            if isPaging, placeholderCount > 0 {
                ForEach(rockets.count..<rockets.count + placeholderCount, id: \.self) { index in
                    RocketCell(rocket: Rocket.samples.first!)
                        .onAppear { if index == rockets.count { nextPage() } }
                        .redacted(reason: .placeholder)
                        .allowsHitTesting(false)
                }
            }
        }
        .animation(
            .default,
            value: AnimationHash(
                rockets: rockets,
                isPaging: isPaging,
                placeholderCount: placeholderCount
            )
        )
    }

    struct AnimationHash: Equatable {
        var rockets: [Rocket]
        var isPaging: Bool
        var placeholderCount: Int
    }
}

// MARK: - Previews

private func previewList(rockets: [Rocket], isPaging: Bool) -> some View {
    NavigationStack {
        RocketsList(
            rockets: rockets,
            totalCount: rockets.count + (isPaging ? 10 : 0),
            isPaging: isPaging,
            nextPage: {}
        )
        .navigationTitle(LocalizedStringResource("Rockets", bundle: #bundle))
        .navigationDestination(for: RocketsRoute.self) { _ in
            Text("Detail", bundle: #bundle)
        }
    }
}

#Preview("1. Empty") {
    previewList(rockets: [], isPaging: false)
}

#Preview("2. Empty, paging") {
    previewList(rockets: [], isPaging: true)
}

#Preview("3. One rocket") {
    previewList(rockets: Array(Rocket.samples.prefix(1)), isPaging: false)
}

#Preview("4. One rocket, paging") {
    previewList(rockets: Array(Rocket.samples.prefix(1)), isPaging: true)
}

#Preview("5. All loaded") {
    previewList(rockets: Rocket.samples, isPaging: false)
}

#Preview("6. Paging") {
    previewList(rockets: Rocket.samples, isPaging: true)
}

#Preview("7. Paging, dark") {
    previewList(rockets: Rocket.samples, isPaging: true)
        .preferredColorScheme(.dark)
}

#Preview("8. Paging, accessibility text") {
    previewList(rockets: Rocket.samples, isPaging: true)
        .dynamicTypeSize(.accessibility3)
}
