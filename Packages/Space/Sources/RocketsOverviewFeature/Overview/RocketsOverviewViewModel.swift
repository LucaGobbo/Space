//
//  RocketsOverviewViewModel.swift
//  RocketsOverviewFeature
//
//  Created by Luca Gobbo on 18/10/2026.
//

import Observation
import SpaceDomain
import SpacePaging

@Observable
final class RocketsOverviewViewModel {

    // MARK: - Properties
    nonisolated private static let pageSize = 10
    private(set) var paginator: Paginator<Rocket>
    private(set) var pageRequest = 0

    // MARK: - init
    init(
        initialState: Paginator<Rocket>.State = .initial,
        rocketRepository: RocketRepository
    ) {
        self.paginator = Paginator(initialState: initialState) { offset in
            let response = try await rocketRepository.rockets(limit: Self.pageSize, offset: offset)
            return Page(items: response.rockets, isLastPage: response.isLastPage)
        }
    }

    // MARK: - API

    func fetch(refresh: Bool = false) async {
        await paginator.fetch(refresh: refresh)
    }

    func requestNextPage() {
        pageRequest += 1
    }

    func dismissFailure() {
        paginator.dismissFailure()
    }
}
