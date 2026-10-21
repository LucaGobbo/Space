import Foundation
import SpaceDomain
import SpacePaging
import Testing

@testable import RocketsOverviewFeature

@Suite(.tags(.viewModel))
@MainActor
struct RocketsOverviewViewModelTests {

    // MARK: - fetch()

    @MainActor
    struct Fetching {
        @Test func `WHEN fetching for the first time, THEN it requests the first page`() async {
            let viewModel = makeViewModel { offset in
                offset == 0 ? page(one, two) : nil
            }

            await viewModel.fetch()

            #expect(viewModel.paginator.state == .paging([one, two]))
        }

        @Test func `WHEN fetching again, THEN it continues after the rockets so far`() async {
            let viewModel = makeViewModel(from: .paging([one, two])) { offset in
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
        @Test func `WHEN refreshing, THEN it requests the first page again and replaces the rockets`() async {
            let viewModel = makeViewModel(from: .paging([one, two, three])) { offset in
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

    // MARK: - requestNextPage()

    @MainActor
    struct NextPageRequests {
        @Test func `WHEN the next page is requested, THEN the page request is bumped`() {
            let viewModel = makeViewModel()

            viewModel.requestNextPage()

            #expect(viewModel.pageRequest == 1)
        }
    }

    // MARK: - Helpers

    nonisolated static let one = rocket(1)
    nonisolated static let two = rocket(2)
    nonisolated static let three = rocket(3)
    nonisolated static let four = rocket(4)

    nonisolated static func rocket(_ id: Int) -> Rocket {
        Rocket(id: id, name: "r\(id)", fullName: nil, variant: nil, isActive: true, imageURL: nil)
    }

    nonisolated static func page(_ rockets: Rocket..., isLastPage: Bool = false) -> RocketPage {
        RocketPage(rockets: rockets, totalCount: 99, isLastPage: isLastPage)
    }

    /// The repository answers with what `page` returns for the requested offset, and fails when it returns `nil`,
    /// which is how a wrong request shows up in the resulting state.
    static func makeViewModel(
        from state: Paginator<Rocket>.State = .initial,
        page: @escaping @Sendable (_ offset: Int) -> RocketPage? = { _ in nil }
    ) -> RocketsOverviewViewModel {
        RocketsOverviewViewModel(
            initialState: state,
            rocketRepository: MockRocketRepository(rockets: { _, offset in
                guard let result = page(offset) else { throw Boom() }
                return result
            })
        )
    }

    struct Boom: LocalizedError {
        var errorDescription: String? { "boom" }
    }
}
