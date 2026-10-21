//
//  LaunchesStack.swift
//  Space
//
//  Created by Luca Gobbo on 18/10/2026.
//

import LaunchDetailFeature
import LaunchesOverviewFeature
import RocketDetailFeature
import SpaceDomain
import SwiftUI

struct LaunchesStack: View {
    // MARK: - Properties
    var launchRepository: LaunchRepository
    var rocketRepository: RocketRepository
    @State private var path: [LaunchesRoute] = []

    // MARK: - Body
    var body: some View {
        NavigationStack(path: $path) {
            LaunchesOverviewScreen(
                launchRepository: launchRepository,
                presentRocket: { id in
                    path.append(.rocket(id: id))
                }
            )
            .navigationDestination(for: LaunchesRoute.self) { route in
                switch route {
                case .launch(let launch):
                    LaunchDetailScreen(launch: launch) { path.append(.rocket(id: $0)) }
                case .rocket(let id):
                    RocketDetailScreen(rocketID: id, repository: rocketRepository)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview {
    LaunchesStack(
        launchRepository: MockLaunchRepository(),
        rocketRepository: MockRocketRepository()
    )
}
