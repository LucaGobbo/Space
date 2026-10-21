//
//  LaunchesOverviewViewModel.swift
//  LaunchesOverviewFeature
//
//  Created by Luca Gobbo on 17/10/2026.
//

import Observation
import SpaceDomain
import SpacePaging
import SwiftUI

@Observable
final class LaunchesOverviewViewModel {

    nonisolated private static let pageSize = 10

    // MARK: - Properties
    @ObservationIgnored
    private var now: @Sendable () -> Date

    @ObservationIgnored
    private var launchRepository: LaunchRepository

    @ObservationIgnored
    private var paginatorFilter: ClosedRange<Date>?

    private(set) var paginator: Paginator<Launch>
    private(set) var pageRequest = 0

    var dateFilter: ClosedRange<Date>?

    /// For now we keep it here, if peformance becomes an issue we could move this off the main thread.
    var launches: SectionedLaunches {
        SectionedLaunches(launches: paginator.items, now: now())
    }

    // MARK: - init
    init(
        now: @escaping @Sendable () -> Date = { .now },
        dateFilter: ClosedRange<Date>? = nil,
        initialState: Paginator<Launch>.State = .initial,
        launchRepository: LaunchRepository
    ) {
        self.now = now
        self.launchRepository = launchRepository
        self.dateFilter = dateFilter
        self.paginatorFilter = dateFilter
        self.paginator = Self.makePaginator(launchRepository, range: dateFilter, initialState: initialState)
    }

    private static func makePaginator(
        _ repository: LaunchRepository,
        range: ClosedRange<Date>?,
        initialState: Paginator<Launch>.State = .initial
    ) -> Paginator<Launch> {
        Paginator(initialState: initialState) { offset in
            let response = try await repository.launches(in: range, limit: pageSize, offset: offset)
            return Page(items: response.launches, isLastPage: response.isLastPage)
        }
    }

    // MARK: - API

    func fetch(refresh: Bool = false) async {
        if paginatorFilter != dateFilter {
            paginatorFilter = dateFilter
            paginator = Self.makePaginator(launchRepository, range: dateFilter)
        }
        await paginator.fetch(refresh: refresh)
    }

    func requestNextPage() {
        pageRequest += 1
    }

    func dismissFailure() {
        paginator.dismissFailure()
    }
}
