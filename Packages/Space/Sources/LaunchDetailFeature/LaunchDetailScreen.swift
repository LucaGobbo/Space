//
//  LaunchDetailScreen.swift
//  LaunchDetailFeature
//
//  Created by Luca Gobbo on 18/10/2026.
//

import SpaceDomain
import SpaceUI
import SwiftUI

public struct LaunchDetailScreen: View {

    // MARK: - Properties
    @Environment(\.dimensions) private var dimensions
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var launch: Launch
    private var onSelectRocket: (Int) -> Void

    private static let dateFormat = Date.FormatStyle().day().month(.wide).year().hour().minute()

    // MARK: - init
    public init(
        launch: Launch,
        onSelectRocket: @escaping (Int) -> Void = { _ in }
    ) {
        self.launch = launch
        self.onSelectRocket = onSelectRocket
    }

    // MARK: - Body
    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: dimensions.spaceM) {
                HeroImage(imageURL: launch.imageURL)
                VStack(alignment: .leading, spacing: dimensions.spaceS) {
                    HStack {
                        Text(launch.name)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let status = launch.status {
                            StatusLabel(status: status)
                        }
                    }

                    if let date = launch.date {
                        Label(date.formatted(Self.dateFormat), systemImage: "calendar")
                            .font(.caption)
                    }
                }

                if let missionDescription = launch.missionDescription {
                    Text(missionDescription).foregroundStyle(.secondary)
                }

                if let rocket = launch.rocket {
                    Button {
                        onSelectRocket(rocket.id)
                    } label: {
                        RocketCard(rocket: rocket)
                    }
                    .buttonStyle(.plain)
                }

                GroupBox {
                    if let coordinate = launch.launchSiteCoordinate {
                        LaunchSiteMap(name: launch.launchSite ?? launch.name, coordinate: coordinate)
                    }
                } label: {
                    if let launchSite = launch.launchSite {
                        Label(launchSite, systemImage: "mappin.and.ellipse")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, dimensions.spaceM)
        }
        .toolbar {
            ForEach(launch.watchURLs, id: \.self) { url in
                ToolbarItem(placement: .secondaryAction) {
                    Link(destination: url) {
                        Label(
                            LocalizedStringResource("Watch the launch", bundle: #bundle), systemImage: "play.rectangle")
                    }
                }
            }
        }
        .navigationSubtitle(launch.date?.formatted(Self.dateFormat) ?? "")
        .navigationTitle(launch.name)
    }
}

// MARK: - Previews

@available(anyAppleOS, introduced: 27)
#Preview(arguments: Launch.samples.reversed()) { launch in
    NavigationStack {
        LaunchDetailScreen(launch: launch)
    }
}

#Preview {
    NavigationStack {
        LaunchDetailScreen(launch: Launch.samples.randomElement()!)
    }
}
