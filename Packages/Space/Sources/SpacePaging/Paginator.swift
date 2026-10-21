//
//  Paginator.swift
//  SpacePaging
//
//  Created by Luca Gobbo on 17/10/2026.
//

import OSLog
import Observation
private import SpaceCore

@Observable
public final class Paginator<Item: Sendable> {

    public nonisolated enum State: Sendable {
        case initial
        case paging([Item])
        case loading([Item])
        case complete([Item])
        case failure([Item], canContinue: Bool, String)
    }

    // MARK: - Properties
    public private(set) var state: State

    private let logger = Logger(subsystem: "org.space.app", category: "paginator")

    @ObservationIgnored
    private var load: @concurrent @Sendable (_ offset: Int) async throws -> Page<Item>

    public var items: [Item] { state.items }
    public var offset: Int { state.offset }
    public var isInitial: Bool { state.isInitial }
    public var isPaging: Bool { state.isPaging }
    public var error: String? { state.error }

    // MARK: - init
    public init(
        initialState: State = .initial,
        load: @concurrent @escaping @Sendable (_ offset: Int) async throws -> Page<Item>
    ) {
        self.load = load
        self.state = initialState
    }

    // MARK: - API

    @concurrent private func fetchPage(offset: Int, state: State) async throws -> State {
        let data = try await load(offset)
        var state = state
        state.received(data, replacing: offset == 0)
        return state
    }

    public func fetch(refresh: Bool = false) async {
        guard state.canFetch(refresh: refresh) else {
            return
        }
        state.dismissFailure()
        let offset = refresh ? 0 : state.offset
        state.startLoading()
        do {
            state = try await fetchPage(offset: offset, state: state)
        } catch  where error.isCancellation {
            state.cancelLoading()
        } catch {
            state.failed(error)
        }
    }

    public func dismissFailure() {
        state.dismissFailure()
    }
}

// MARK: - State
nonisolated extension Paginator.State {

    public var animationHash: Int {
        switch self {
        case .initial: 0
        case .paging: 1
        case .loading: 2
        case .complete: 3
        case .failure: 4
        }
    }

    public var items: [Item] {
        switch self {
        case .initial: []
        case .paging(let items), .loading(let items), .complete(let items): items
        case .failure(let items, _, _): items
        }
    }

    /// Number of items loaded so far, i.e. the offset of the next page.
    public var offset: Int { items.count }

    public var isInitial: Bool {
        if case .initial = self { true } else { false }
    }

    public var isLoading: Bool {
        if case .loading = self { true } else { false }
    }

    /// Whether more pages are available or being requested.
    public var isPaging: Bool {
        switch self {
        case .paging, .loading: true
        case .initial, .complete, .failure: false
        }
    }

    public var error: String? {
        switch self {
        case .initial, .paging, .loading, .complete: nil
        case .failure(_, _, let message): message
        }
    }

    var isContinuable: Bool {
        switch self {
        case .paging, .loading: true
        case .failure(_, let canContinue, _): canContinue
        case .initial, .complete: false
        }
    }

    func canFetch(refresh: Bool) -> Bool {
        !isLoading && (refresh || isInitial || isContinuable)
    }

    mutating func startLoading() {
        guard case .paging(let items) = self else { return }
        self = .loading(items)
    }

    mutating func cancelLoading() {
        guard case .loading(let items) = self else { return }
        self = .paging(items)
    }

    mutating func received(_ page: Page<Item>, replacing: Bool) {
        let items = replacing ? page.items : items + page.items
        self = page.isLastPage ? .complete(items) : .paging(items)
    }

    mutating func failed(_ error: Error) {
        self = .failure(items, canContinue: isContinuable, error.localizedDescription)
    }

    mutating func dismissFailure() {
        guard case .failure(let items, let canContinue, _) = self else { return }
        self = canContinue ? .paging(items) : .complete(items)
    }
}

nonisolated extension Paginator.State: Equatable where Item: Equatable {}
