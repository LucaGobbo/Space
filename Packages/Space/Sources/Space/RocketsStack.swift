//
//  RocketsStack.swift
//  Space
//
//  Created by Luca Gobbo on 18/10/2026.
//

import RocketDetailFeature
import RocketsOverviewFeature
import SpaceDomain
import SwiftUI

struct RocketsStack: View {
    // MARK: - Properties
    var rocketRepository: RocketRepository
    @State private var path: [RocketsRoute] = []

    // MARK: - Body
    var body: some View {
        NavigationStack(path: $path) {
            RocketsOverviewScreen(rocketRepository: rocketRepository)
                .navigationDestination(for: RocketsRoute.self) { route in
                    switch route {
                    case .rocket(let rocket):
                        RocketDetailScreen(
                            rocket: rocket,
                            repository: rocketRepository
                        )
                    }
                }
        }
    }
}

// MARK: - Previews

#Preview {
    RocketsStack(rocketRepository: MockRocketRepository())
}
