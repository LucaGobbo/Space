//
//  RocketsOverviewScreen.swift
//  RocketsOverviewFeature
//
//  Created by Luca Gobbo on 17/10/2026.
//

import SpaceDomain
private import SpaceUI
import SwiftUI

public struct RocketsOverviewScreen: View {
    // MARK: - Properties
    @State private var viewModel: RocketsOverviewViewModel

    // MARK: - init
    public init(rocketRepository: RocketRepository) {
        self._viewModel = State(initialValue: RocketsOverviewViewModel(rocketRepository: rocketRepository))
    }

    // MARK: - Body
    public var body: some View {
        RocketsList(
            rockets: viewModel.paginator.items,
            isPaging: viewModel.paginator.isPaging,
            nextPage: viewModel.requestNextPage
        )
        .overlay {
            if viewModel.paginator.isInitial {
                ProgressView {
                    Label {
                        Text("Loading rockets", bundle: #bundle)
                    } icon: {
                        Image(systemName: "airplane.departure")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .error(viewModel.paginator.error, dismiss: viewModel.dismissFailure)
        .task(id: viewModel.pageRequest) {
            await viewModel.fetch()
        }
        .refreshable {
            await viewModel.fetch(refresh: true)
        }
        .navigationTitle(LocalizedStringResource("Rockets", bundle: #bundle))
    }
}

// MARK: - Previews
#Preview {
    NavigationStack {
        RocketsOverviewScreen(rocketRepository: MockRocketRepository.delayed(for: .seconds(1)))
            .navigationDestination(
                for: RocketsRoute.self,
                destination: {
                    switch $0 {
                    case .rocket(let rocket):
                        Text(rocket.name)
                            .navigationTitle(rocket.name)
                    }
                }
            )

    }
}

#Preview("9. Paging two at a time") {
    NavigationStack {
        RocketsOverviewScreen(
            rocketRepository: MockRocketRepository(rockets: { _, offset in
                try await Task.sleep(for: .seconds(1.5))
                return try await MockRocketRepository.paginating(Rocket.samples)(2, offset)
            })
        )
    }
}

#Preview("10. Paging fails") {
    NavigationStack {
        RocketsOverviewScreen(
            rocketRepository: MockRocketRepository(rockets: { _, offset in
                try await Task.sleep(for: .seconds(0.5))
                guard offset == 0 else { throw URLError(.notConnectedToInternet) }
                return try await MockRocketRepository.paginating(Rocket.samples)(2, offset)
            })
        )
    }
}
