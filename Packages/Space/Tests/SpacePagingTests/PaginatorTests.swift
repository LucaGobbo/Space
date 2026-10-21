//
//  PaginatorTests.swift
//  SpacePagingTests
//
//  Created by Luca Gobbo on 17/10/2026.
//

import Foundation
import Testing

@testable import SpacePaging

@Suite(.tags(.paging))
@MainActor
struct PaginatorTests {

    // MARK: - .initial

    @MainActor
    struct Initial {
        @Test func `WHEN fetching, THEN it loads the first page`() async {
            let state = await run(.fetch, from: .initial, loadsAt: 0, returning: .success(morePages))
            #expect(state == .paging([7, 8]))
        }

        @Test func `WHEN fetching and it is the last page, THEN it completes`() async {
            let state = await run(.fetch, from: .initial, loadsAt: 0, returning: .success(lastPage))
            #expect(state == .complete([7, 8]))
        }

        @Test func `WHEN fetching fails, THEN it cannot continue`() async {
            let state = await run(.fetch, from: .initial, loadsAt: 0, returning: .failure(Boom()))
            #expect(state == .failure([], canContinue: false, "boom"))
        }

        @Test(arguments: cancellations)
        func `WHEN fetching is cancelled, THEN it stays initial`(_ cancellation: any Error) async {
            let state = await run(.fetch, from: .initial, loadsAt: 0, returning: .failure(cancellation))
            #expect(state == .initial)
        }

        @Test func `WHEN refreshing, THEN it loads the first page`() async {
            let state = await run(.refresh, from: .initial, loadsAt: 0, returning: .success(morePages))
            #expect(state == .paging([7, 8]))
        }
    }

    // MARK: - .paging

    @MainActor
    struct Paging {
        @Test func `WHEN fetching, THEN it loads after the items so far and appends`() async {
            let state = await run(.fetch, from: .paging([0, 1]), loadsAt: 2, returning: .success(morePages))
            #expect(state == .paging([0, 1, 7, 8]))
        }

        @Test func `WHEN fetching the last page, THEN it completes`() async {
            let state = await run(.fetch, from: .paging([0, 1]), loadsAt: 2, returning: .success(lastPage))
            #expect(state == .complete([0, 1, 7, 8]))
        }

        @Test func `WHEN fetching fails, THEN items are kept and it can continue`() async {
            let state = await run(.fetch, from: .paging([0, 1]), loadsAt: 2, returning: .failure(Boom()))
            #expect(state == .failure([0, 1], canContinue: true, "boom"))
        }

        @Test(arguments: cancellations)
        func `WHEN fetching is cancelled, THEN it stays paging`(_ cancellation: any Error) async {
            let state = await run(.fetch, from: .paging([0, 1]), loadsAt: 2, returning: .failure(cancellation))
            #expect(state == .paging([0, 1]))
        }

        @Test func `WHEN refreshing, THEN it loads from the start and replaces`() async {
            let state = await run(.refresh, from: .paging([0, 1]), loadsAt: 0, returning: .success(morePages))
            #expect(state == .paging([7, 8]))
        }

        @Test func `WHEN refreshing fails, THEN items are kept and it can continue`() async {
            let state = await run(.refresh, from: .paging([0, 1]), loadsAt: 0, returning: .failure(Boom()))
            #expect(state == .failure([0, 1], canContinue: true, "boom"))
        }

        @Test func `WHEN refreshing is cancelled, THEN it stays paging`() async {
            let state = await run(.refresh, from: .paging([0, 1]), loadsAt: 0, returning: .failure(CancellationError()))
            #expect(state == .paging([0, 1]))
        }
    }

    // MARK: - .loading

    @MainActor
    struct Loading {
        @Test func `WHEN fetching, THEN it does not load`() async {
            let state = await run(.fetch, from: .loading([0, 1]), loadsAt: nil)
            #expect(state == .loading([0, 1]))
        }

        @Test func `WHEN refreshing, THEN it does not load`() async {
            let state = await run(.refresh, from: .loading([0, 1]), loadsAt: nil)
            #expect(state == .loading([0, 1]))
        }
    }

    // MARK: - .complete

    @MainActor
    struct Complete {
        @Test func `WHEN fetching, THEN it does not load`() async {
            let state = await run(.fetch, from: .complete([0, 1]), loadsAt: nil)
            #expect(state == .complete([0, 1]))
        }

        @Test func `WHEN refreshing, THEN it loads from the start and replaces`() async {
            let state = await run(.refresh, from: .complete([0, 1]), loadsAt: 0, returning: .success(morePages))
            #expect(state == .paging([7, 8]))
        }

        @Test func `WHEN refreshing returns the last page, THEN it stays complete`() async {
            let state = await run(.refresh, from: .complete([0, 1]), loadsAt: 0, returning: .success(lastPage))
            #expect(state == .complete([7, 8]))
        }

        @Test func `WHEN refreshing fails, THEN items are kept and it cannot continue`() async {
            let state = await run(.refresh, from: .complete([0, 1]), loadsAt: 0, returning: .failure(Boom()))
            #expect(state == .failure([0, 1], canContinue: false, "boom"))
        }

        @Test func `WHEN refreshing is cancelled, THEN it stays complete`() async {
            let cancellation = CancellationError()
            let state = await run(.refresh, from: .complete([0, 1]), loadsAt: 0, returning: .failure(cancellation))
            #expect(state == .complete([0, 1]))
        }
    }

    // MARK: - .failure that can continue

    @MainActor
    struct ContinuableFailure {
        let failed = Paginator<Int>.State.failure([0, 1], canContinue: true, "old")

        @Test func `WHEN fetching, THEN it retries after the items so far`() async {
            let state = await run(.fetch, from: failed, loadsAt: 2, returning: .success(morePages))
            #expect(state == .paging([0, 1, 7, 8]))
        }

        @Test func `WHEN fetching fails again, THEN the message is replaced`() async {
            let state = await run(.fetch, from: failed, loadsAt: 2, returning: .failure(Boom()))
            #expect(state == .failure([0, 1], canContinue: true, "boom"))
        }

        @Test func `WHEN fetching is cancelled, THEN it returns to paging`() async {
            let state = await run(.fetch, from: failed, loadsAt: 2, returning: .failure(CancellationError()))
            #expect(state == .paging([0, 1]))
        }

        @Test func `WHEN refreshing, THEN it loads from the start and replaces`() async {
            let state = await run(.refresh, from: failed, loadsAt: 0, returning: .success(morePages))
            #expect(state == .paging([7, 8]))
        }

        @Test func `WHEN dismissing the failure, THEN it returns to paging without loading`() async {
            let state = await run(.dismissFailure, from: failed, loadsAt: nil)
            #expect(state == .paging([0, 1]))
        }
    }

    // MARK: - .failure that cannot continue

    @MainActor
    struct TerminalFailure {
        let failed = Paginator<Int>.State.failure([0, 1], canContinue: false, "old")

        @Test func `WHEN fetching, THEN it does not load`() async {
            let state = await run(.fetch, from: failed, loadsAt: nil)
            #expect(state == failed)
        }

        @Test func `WHEN refreshing, THEN it loads from the start and replaces`() async {
            let state = await run(.refresh, from: failed, loadsAt: 0, returning: .success(morePages))
            #expect(state == .paging([7, 8]))
        }

        @Test func `WHEN refreshing fails again, THEN it cannot continue`() async {
            let state = await run(.refresh, from: failed, loadsAt: 0, returning: .failure(Boom()))
            #expect(state == .failure([0, 1], canContinue: false, "boom"))
        }

        @Test func `WHEN dismissing the failure, THEN it completes without loading`() async {
            let state = await run(.dismissFailure, from: failed, loadsAt: nil)
            #expect(state == .complete([0, 1]))
        }
    }

    // MARK: - dismissFailure() outside a failure

    @Test(arguments: [
        Paginator<Int>.State.initial, .paging([0, 1]), .loading([0, 1]), .complete([0, 1])
    ])
    func `WHEN dismissing a failure from a non-failure state, THEN nothing changes`(_ initial: Paginator<Int>.State)
        async
    {
        let state = await Self.run(.dismissFailure, from: initial, loadsAt: nil)
        #expect(state == initial)
    }

    // MARK: - Helpers

    enum Action { case fetch, refresh, dismissFailure }

    struct Boom: LocalizedError {
        var errorDescription: String? { "boom" }
    }

    struct UnexpectedLoad: Error {}

    static let morePages = Page(items: [7, 8], isLastPage: false)
    static let lastPage = Page(items: [7, 8], isLastPage: true)
    nonisolated static let cancellations: [any Error] = [CancellationError(), URLError(.cancelled)]

    /// `load` answers with `result` for `expectedOffset` and fails for any other offset (or when `nil`), so a
    /// wrong or unexpected load shows up in the resulting state.
    static func run(
        _ action: Action,
        from initial: Paginator<Int>.State,
        loadsAt expectedOffset: Int?,
        returning result: Result<Page<Int>, any Error> = .failure(UnexpectedLoad())
    ) async -> Paginator<Int>.State {
        let paginator = Paginator<Int>(initialState: initial) { offset in
            guard offset == expectedOffset else { throw UnexpectedLoad() }
            return try result.get()
        }
        switch action {
        case .fetch: await paginator.fetch()
        case .refresh: await paginator.fetch(refresh: true)
        case .dismissFailure: paginator.dismissFailure()
        }
        return paginator.state
    }
}
