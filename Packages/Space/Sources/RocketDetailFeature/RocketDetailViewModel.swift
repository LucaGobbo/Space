//
//  RocketDetailViewModel.swift
//  RocketDetailFeature
//
//  Created by Luca Gobbo on 18/10/2026.
//

import Observation
private import SpaceCore
import SpaceDomain

@Observable
final class RocketDetailViewModel {

    // MARK: - Properties
    private(set) var state: LoadState<Rocket>
    private var rocketID: Int

    @ObservationIgnored
    private var repository: RocketRepository

    // MARK: - init

    /// Starts loaded: the rocket is already complete, so nothing is fetched.
    init(rocket: Rocket, repository: RocketRepository) {
        self.state = .loaded(rocket)
        self.rocketID = rocket.id
        self.repository = repository
    }

    /// Starts loading: `load()` fetches the rocket by its id.
    init(rocketID: Int, repository: RocketRepository) {
        self.state = .loading
        self.rocketID = rocketID
        self.repository = repository
    }

    // MARK: - API

    @concurrent private func fetchRocket() async throws -> Rocket {
        try await repository.rocket(id: rocketID)
    }

    func load(isRefresh: Bool = false) async {
        guard !state.isLoaded || isRefresh else { return }
        do {
            state = .loaded(try await fetchRocket())
        } catch  where error.isCancellation {
            // The screen went away; `.task` starts again when it comes back.
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
