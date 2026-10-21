//
//  LaunchCell.swift
//  Space
//
//  Created by Luca Gobbo on 17/10/2026.
//

import SpaceDomain
private import SpaceUI
import SwiftUI

struct LaunchCell: View {
    // MARK: - Properties
    @Environment(\.dimensions) private var dimensions
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    var launch: Launch

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: dimensions.spaceM) {
            ViewThatFits {

                HStack(alignment: .top) {
                    NameWithStatus(launch: launch)
                }
                VStack(alignment: .leading, spacing: dimensions.spaceM) {
                    NameWithStatus(launch: launch)
                }
            }

            VStack(alignment: .leading, spacing: dimensions.spaceS) {
                DateLabel(date: launch.date)
                if let launchSite = launch.launchSite {
                    Label(launchSite, systemImage: "mappin.and.ellipse")
                        .foregroundStyle(.secondary)
                }
            }
            .font(.caption2)
        }
    }

    private struct NameWithStatus: View {
        var name: String
        var status: Launch.Status?

        init(name: String, status: Launch.Status? = nil) {
            self.name = name
            self.status = status
        }

        init(launch: Launch) {
            self.name = launch.name
            self.status = launch.status
        }

        var body: some View {
            Text(name).font(.headline).frame(maxWidth: .infinity, alignment: .leading)

            if let status {
                StatusLabel(status: status)
            }
        }
    }

    private struct DateLabel: View {
        // MARK: - Properties
        var date: Date?

        // MARK: - Body
        var body: some View {
            Label {
                if let date {
                    Text(date, format: .dateTime.day().month().year().hour().minute())
                } else {
                    Text("Date TBD", bundle: #bundle)
                }
            } icon: {
                Image(systemName: "calendar")
            }
        }
    }
}

// MARK: - Previews
#Preview {
    List {
        ForEach(Launch.samples) { item in
            LaunchCell(launch: item)
        }
    }
}
