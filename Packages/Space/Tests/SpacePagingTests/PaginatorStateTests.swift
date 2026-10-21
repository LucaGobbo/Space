//
//  PaginatorStateTests.swift
//  SpacePagingTests
//
//  Created by Luca Gobbo on 17/10/2026.
//

import Foundation
import Testing

@testable import SpacePaging

@Suite(.tags(.paging))
struct PaginatorStateTests {

    private typealias State = Paginator<Int>.State

    private func page(_ range: Range<Int>, isLastPage: Bool) -> Page<Int> {
        Page(items: Array(range), isLastPage: isLastPage)
    }

    @Test func `WHEN initial, THEN there are no items and fetching is allowed`() {
        let state = State.initial
        #expect(state.items.isEmpty)
        #expect(state.isInitial)
        #expect(state.canFetch(refresh: false))
    }

    @Test func `WHEN a page is received, THEN it appends`() {
        var state = State.paging([0, 1])
        state.received(page(2..<4, isLastPage: false), replacing: false)
        #expect(state == .paging([0, 1, 2, 3]))
        #expect(state.offset == 4)
    }

    @Test func `WHEN a page is received while restarting, THEN it replaces`() {
        var state = State.paging([0, 1, 2, 3])
        state.received(page(0..<2, isLastPage: false), replacing: true)
        #expect(state == .paging([0, 1]))
    }

    @Test func `WHEN the last page is received, THEN it completes`() {
        var state = State.initial
        state.received(page(0..<3, isLastPage: true), replacing: true)
        #expect(state == .complete([0, 1, 2]))
        #expect(!state.isPaging)
    }

    @Test func `WHEN loading, THEN fetching is blocked even when refreshing`() {
        var state = State.paging([0])
        state.startLoading()
        #expect(state == .loading([0]))
        #expect(state.isPaging)
        #expect(!state.canFetch(refresh: false))
        #expect(!state.canFetch(refresh: true))
    }

    @Test func `WHEN starting to load, THEN it only starts from paging`() {
        for var state in [State.initial, .complete([0]), .failure([0], canContinue: true, "x")] {
            let before = state
            state.startLoading()
            #expect(state == before)
        }
    }

    @Test func `WHEN loading is cancelled, THEN it returns to paging`() {
        var state = State.loading([0, 1])
        state.cancelLoading()
        #expect(state == .paging([0, 1]))
    }

    @Test func `WHEN complete, THEN only refreshing is allowed`() {
        let state = State.complete([0])
        #expect(!state.canFetch(refresh: false))
        #expect(state.canFetch(refresh: true))
    }

    @Test func `WHEN failing, THEN items and whether it can continue are kept`() {
        var fromLoading = State.loading([0, 1])
        fromLoading.failed(URLError(.timedOut))
        #expect(fromLoading == .failure([0, 1], canContinue: true, URLError(.timedOut).localizedDescription))
        #expect(fromLoading.error == URLError(.timedOut).localizedDescription)
        #expect(fromLoading.canFetch(refresh: false))

        var fromInitial = State.initial
        fromInitial.failed(URLError(.timedOut))
        #expect(fromInitial == .failure([], canContinue: false, URLError(.timedOut).localizedDescription))
        #expect(!fromInitial.canFetch(refresh: false))
        #expect(fromInitial.canFetch(refresh: true))
    }

    @Test func `WHEN dismissing a failure, THEN it returns to paging or complete`() {
        var canContinue = State.failure([0], canContinue: true, "x")
        canContinue.dismissFailure()
        #expect(canContinue == .paging([0]))

        var firstLoad = State.failure([], canContinue: false, "x")
        firstLoad.dismissFailure()
        #expect(firstLoad == .complete([]))
        #expect(!firstLoad.isInitial)
    }

    @Test func `WHEN dismissing a failure outside a failure state, THEN the state is left alone`() {
        for var state in [State.initial, .paging([0]), .complete([0])] {
            let before = state
            state.dismissFailure()
            #expect(state == before)
        }
    }
}
