//
//  RocketDetailScreen.swift
//  RocketDetailFeature
//
//  Created by Luca Gobbo on 18/10/2026.
//

import SpaceDomain
import SwiftUI

public struct RocketDetailScreen: View {

    // MARK: - Properties
    @State private var viewModel: RocketDetailViewModel

    // MARK: - init

    /// Shows a rocket that is already loaded, for example one picked from the rockets list.
    public init(rocket: Rocket, repository: RocketRepository) {
        _viewModel = State(
            initialValue: RocketDetailViewModel(
                rocket: rocket,
                repository: repository
            )
        )
    }

    /// Loads the rocket with this id first, for example when coming from a launch.
    public init(rocketID: Int, repository: RocketRepository) {
        _viewModel = State(
            initialValue: RocketDetailViewModel(
                rocketID: rocketID,
                repository: repository
            )
        )
    }

    // MARK: - Body
    public var body: some View {
        LoadingView(
            state: viewModel.state,
            placeHolder: .previewValue
        ) { rocket in
            RocketDetailView(
                rocket: rocket
            )
        }
        .navigationTitle(viewModel.state.value?.name ?? "")
        .navigationSubtitle(viewModel.state.value?.variant ?? "")
        .overlay {
            if let error = viewModel.state.error {
                ContentUnavailableView {
                    Label(
                        LocalizedStringResource("Couldn't load the rocket", bundle: #bundle),
                        systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error)
                } actions: {
                    Button(LocalizedStringResource("Try again", bundle: #bundle)) {
                        Task { await viewModel.load() }
                    }
                }
                .transition(.blurReplace)
            }
        }
        .animation(.default, value: viewModel.state)
        .task { await viewModel.load() }
    }
}

// MARK: - Previews

#Preview("Rocket") {
    NavigationStack {
        RocketDetailScreen(
            rocket: Rocket.samples[0],
            repository: MockRocketRepository.delayed(for: .seconds(1.5))
        )
    }
}

#Preview("Loading by id") {
    NavigationStack {
        RocketDetailScreen(
            rocketID: 164,
            repository: MockRocketRepository.delayed(for: .seconds(2))
        )
    }
}

#Preview("Failed") {
    NavigationStack {
        RocketDetailScreen(
            rocketID: 164,
            repository: MockRocketRepository.failing
        )
    }
}
