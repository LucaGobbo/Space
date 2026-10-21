//
//  SpaceTabView.swift
//  Space
//
//  Created by Luca Gobbo on 17/10/2026.
//

import SpaceDomain
import SwiftUI
import SpaceUI

public struct SpaceTabView: View {
    // MARK: - Properties
    private var launchRepository: LaunchRepository
    private var rocketRepository: RocketRepository

    // MARK: - init
    public init(launchRepository: LaunchRepository, rocketRepository: RocketRepository) {
        self.launchRepository = launchRepository
        self.rocketRepository = rocketRepository
    }

    // MARK: - Body
    public var body: some View {
        TabView {
            Tab {
                LaunchesStack(
                    launchRepository: launchRepository,
                    rocketRepository: rocketRepository
                )
            } label: {
                Label(LocalizedStringResource("Launches", bundle: #bundle), systemImage: "flame")
            }
            Tab {
                RocketsStack(rocketRepository: rocketRepository)
            } label: {
                Label(LocalizedStringResource("Rockets", bundle: #bundle), systemImage: "airplane.departure")
            }

            #if DEBUG
                Tab {
                    SettingsScreen()
                } label: {
                    Label(LocalizedStringResource("Settings", bundle: #bundle), systemImage: "gear")
                }
            #endif
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewSidebarFooter {
            VersionView()
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Previews
#Preview {
    SpaceTabView(
        launchRepository: MockLaunchRepository.delayed(for: .seconds(1)),
        rocketRepository: MockRocketRepository.delayed(for: .seconds(1))
    )
}
