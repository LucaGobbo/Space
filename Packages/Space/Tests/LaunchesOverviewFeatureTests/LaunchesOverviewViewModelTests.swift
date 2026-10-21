import Foundation
import SpaceDomain
import SpacePaging
import Testing

@testable import LaunchesOverviewFeature

@Suite(.tags(.viewModel))
@MainActor
struct LaunchesOverviewViewModelTests {

    // MARK: - fetch()

    @MainActor
    struct Fetching {
        @Test func `WHEN fetching for the first time, THEN it requests the first page`() async {
            let viewModel = makeViewModel { _, offset in
                offset == 0 ? page(one, two) : nil
            }

            await viewModel.fetch()

            #expect(viewModel.paginator.state == .paging([one, two]))
        }

        @Test func `WHEN fetching again, THEN it continues after the launches so far`() async {
            let viewModel = makeViewModel(from: .paging([one, two])) { _, offset in
                offset == 2 ? page(three) : nil
            }

            await viewModel.fetch()

            #expect(viewModel.paginator.state == .paging([one, two, three]))
        }

        @Test func `WHEN fetching after the last page, THEN no request is made`() async {
            let viewModel = makeViewModel(from: .complete([one, two]))

            await viewModel.fetch()

            #expect(viewModel.paginator.state == .complete([one, two]))
        }
    }

    // MARK: - fetch(refresh: true)

    @MainActor
    struct Refreshing {
        @Test func `WHEN refreshing, THEN it requests the first page again and replaces the launches`() async {
            let viewModel = makeViewModel(from: .paging([one, two, three])) { _, offset in
                offset == 0 ? page(four) : nil
            }

            await viewModel.fetch(refresh: true)

            #expect(viewModel.paginator.state == .paging([four]))
        }
    }

    // MARK: - dismissFailure()

    @MainActor
    struct DismissingAFailure {
        @Test func `WHEN dismissing a failure, THEN it returns to paging without requesting`() {
            let viewModel = makeViewModel(from: .failure([one, two], canContinue: true, "boom"))

            viewModel.dismissFailure()

            #expect(viewModel.paginator.state == .paging([one, two]))
        }
    }

    // MARK: - dateFilter

    @MainActor
    struct DateFilter {
        let range = now...now.addingTimeInterval(86_400)

        @Test func `WHEN the filter changes, THEN it requests the new range from the start`() async {
            let range = range
            let viewModel = makeViewModel(from: .paging([one, two])) { requested, offset in
                requested == range && offset == 0 ? page(four) : nil
            }

            viewModel.dateFilter = range
            await viewModel.fetch()

            #expect(viewModel.paginator.state == .paging([four]))
        }

        @Test func `WHEN the filter is cleared, THEN it requests all launches from the start`() async {
            let viewModel = makeViewModel(from: .paging([one, two]), dateFilter: range) { requested, offset in
                requested == nil && offset == 0 ? page(three) : nil
            }

            viewModel.dateFilter = nil
            await viewModel.fetch()

            #expect(viewModel.paginator.state == .paging([three]))
        }

        @Test func `WHEN the filter is set to the same value, THEN it keeps continuing`() async {
            let range = range
            let viewModel = makeViewModel(from: .paging([one, two]), dateFilter: range) { requested, offset in
                requested == range && offset == 2 ? page(three) : nil
            }

            viewModel.dateFilter = range
            await viewModel.fetch()

            #expect(viewModel.paginator.state == .paging([one, two, three]))
        }
    }

    // MARK: - requestNextPage()

    @MainActor
    struct NextPageRequests {
        @Test func `WHEN the next page is requested, THEN the page request is bumped`() {
            let viewModel = makeViewModel()

            viewModel.requestNextPage()

            #expect(viewModel.pageRequest == 1)
        }
    }

    // MARK: - launches

    @MainActor
    struct Sectioning {
        @Test func `WHEN launches are loaded, THEN they are split around now and sorted`() {
            let past = launch("past", at: now.addingTimeInterval(-100))
            let longAgo = launch("longAgo", at: now.addingTimeInterval(-200))
            let atNow = launch("atNow", at: now)
            let soon = launch("soon", at: now.addingTimeInterval(100))
            let undated = launch("undated", at: nil)

            let viewModel = makeViewModel(from: .paging([longAgo, soon, undated, past, atNow]))

            #expect(
                viewModel.launches
                    == SectionedLaunches(
                        upcoming: [atNow, soon, undated],
                        past: [longAgo, past]
                    ))
        }
    }

    // MARK: - Helpers

    nonisolated static let now = Date(timeIntervalSince1970: 1_750_000_000)

    nonisolated static let one = launch("a")
    nonisolated static let two = launch("b")
    nonisolated static let three = launch("c")
    nonisolated static let four = launch("d")

    nonisolated static func launch(_ id: String, at date: Date? = nil) -> Launch {
        Launch(
            id: id, name: id, date: date, status: nil, launchSite: nil, imageURL: nil,
            missionDescription: nil, watchURLs: [], rocket: nil)
    }

    nonisolated static func page(_ launches: Launch..., isLastPage: Bool = false) -> LaunchPage {
        LaunchPage(launches: launches, totalCount: 99, isLastPage: isLastPage)
    }

    /// The repository answers with what `page` returns for the requested range and offset, and fails when it
    /// returns `nil`, which is how a wrong request shows up in the resulting state.
    static func makeViewModel(
        from state: Paginator<Launch>.State = .initial,
        dateFilter: ClosedRange<Date>? = nil,
        page: @escaping @Sendable (_ range: ClosedRange<Date>?, _ offset: Int) -> LaunchPage? = { _, _ in nil }
    ) -> LaunchesOverviewViewModel {
        LaunchesOverviewViewModel(
            now: { now },
            dateFilter: dateFilter,
            initialState: state,
            launchRepository: MockLaunchRepository { range, _, offset in
                guard let result = page(range, offset) else { throw Boom() }
                return result
            }
        )
    }

    struct Boom: LocalizedError {
        var errorDescription: String? { "boom" }
    }
}
