//
//  LaunchesList.swift
//  LaunchesOverviewFeature
//
//  Created by Luca Gobbo on 17/10/2026.
//

import SpaceDomain
import SwiftUI

struct LaunchesList: View {

    // MARK: - Properties
    private static let placeholderCount = 3
    private var placeholderCount: Int { min(totalCount - offset, Self.placeholderCount) }
    var launches: SectionedLaunches
    var isPaging: Bool = false
    var offset: Int = 0
    var totalCount: Int = 0
    var nextPage: () -> Void = {}
    var presentRocket: (Rocket.ID) -> Void = { _ in }

    // MARK: - Body
    var body: some View {
        List {
            if !launches.upcoming.isEmpty {
                LaunchSection(
                    title: LocalizedStringResource("Upcoming", bundle: #bundle),
                    launches: launches.upcoming,
                    presentRocket: presentRocket
                )
            }
            if !launches.past.isEmpty {
                LaunchSection(
                    title: LocalizedStringResource("Past", bundle: #bundle),
                    launches: launches.past,
                    presentRocket: presentRocket
                )
            }
            if isPaging, placeholderCount > 0 {
                ForEach(Self.placeholders(offset: offset, count: placeholderCount)) { launch in
                    LaunchCell(launch: launch).onAppear {
                        guard launch.id == Self.placeholderID(offset: offset, index: 0) else { return }
                        nextPage()
                    }
                }
                .redacted(reason: .placeholder)
                .allowsHitTesting(false)
            }
        }
        .animation(
            .smooth,
            value: AnimationHash(
                launches: launches,
                isPaging: isPaging,
                placeholderCount: placeholderCount
            )
        )
    }

    private struct AnimationHash: Equatable {
        var launches: SectionedLaunches
        var isPaging: Bool
        var placeholderCount: Int
    }

    struct LaunchSection: View {
        // MARK: - Properties
        var title: LocalizedStringResource
        var launches: [Launch]
        var presentRocket: (Rocket.ID) -> Void

        // MARK: - Body
        var body: some View {
            Section(title) {
                ForEach(launches) { launch in
                    NavigationLink(value: LaunchesRoute.launch(launch)) {
                        LaunchCell(launch: launch).contextMenu {
                            if let rocket = launch.rocket {
                                Button(
                                    LocalizedStringResource("View \(rocket.name)", bundle: #bundle),
                                    systemImage: "airplane.departure"
                                ) {
                                    presentRocket(rocket.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Paging placeholders

    private static func placeholderID(offset: Int, index: Int) -> String {
        "placeholder-\(offset)-\(index)"
    }

    private static func placeholders(offset: Int, count: Int) -> [Launch] {
        (0..<count).map { index in
            Launch(
                id: placeholderID(offset: offset, index: index),
                name: "Placeholder launch name",
                date: .now,
                status: Launch.Status(name: "Go for Launch", abbreviation: "Go"),
                launchSite: "Placeholder launch site",
                imageURL: nil,
                missionDescription: nil,
                watchURLs: [],
                rocket: nil
            )
        }
    }
}

// MARK: - Previews
#Preview {
    let now = Date.now
    NavigationStack {
        LaunchesList(
            launches: .init(launches: Launch.samples, now: now)
        )
        .navigationTitle(LocalizedStringResource("Launches", bundle: #bundle))
    }

}

#Preview("paging") {
    let now = Date.now
    NavigationStack {
        LaunchesList(
            launches: .init(launches: Launch.samples, now: now),
            isPaging: true,
            offset: Launch.samples.count,
            totalCount: Launch.samples.count + 3
        )
        .navigationTitle(LocalizedStringResource("Launches", bundle: #bundle))
    }

}
