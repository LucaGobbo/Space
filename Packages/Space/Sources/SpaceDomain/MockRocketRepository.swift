//
//  MockRocketRepository.swift
//  SpaceDomain
//
//  Created by Luca Gobbo on 18/10/2026.
//

import Foundation

/// Delegates `rockets(limit:offset:)` and `rocket(id:)` to injected closures. For previews and tests.
public struct MockRocketRepository: RocketRepository {
    // MARK: - Properties
    private var rockets: @Sendable (_ limit: Int, _ offset: Int) async throws -> RocketPage
    private var rocket: @Sendable (_ id: Int) async throws -> Rocket

    // MARK: - init
    public init(
        rockets:
            @escaping @Sendable (
                _ limit: Int,
                _ offset: Int
            ) async throws -> RocketPage = MockRocketRepository.paginating(Rocket.samples),
        rocket:
            @escaping @Sendable (_ id: Int) async throws -> Rocket = MockRocketRepository.finding(Rocket.samples)
    ) {
        self.rockets = rockets
        self.rocket = rocket
    }

    public func rockets(limit: Int, offset: Int) async throws -> RocketPage {
        try await rockets(limit, offset)
    }

    public func rocket(id: Int) async throws -> Rocket {
        try await rocket(id)
    }

    /// Returns no rockets.
    public static let empty = MockRocketRepository(
        rockets: { _, _ in
            try await Task.sleep(for: .seconds(0.3))
            return RocketPage(rockets: [], totalCount: 0, isLastPage: true)
        },
        rocket: { _ in throw URLError(.fileDoesNotExist) }
    )

    /// Throws after a short delay.
    public static let failing = MockRocketRepository(
        rockets: { _, _ in
            try await Task.sleep(for: .seconds(0.4))
            throw NSError(domain: "", code: 2)
        },
        rocket: { _ in
            try await Task.sleep(for: .seconds(0.4))
            throw NSError(domain: "", code: 2)
        }
    )

    /// Pages through and finds in `Rocket.samples` after waiting `duration` on every request.
    public static func delayed(for duration: Duration) -> MockRocketRepository {
        let page = paginating(Rocket.samples)
        let find = finding(Rocket.samples)
        return MockRocketRepository(
            rockets: { limit, offset in
                try await Task.sleep(for: duration)
                return try await page(limit, offset)
            },
            rocket: { id in
                try await Task.sleep(for: duration)
                return try await find(id)
            }
        )
    }

    /// A handler that returns the rocket with the given id, or throws when there is none.
    public static func finding(_ rockets: [Rocket]) -> @Sendable (_ id: Int) async throws -> Rocket {
        { id in
            guard let rocket = rockets.first(where: { $0.id == id }) else {
                throw URLError(.fileDoesNotExist)
            }
            return rocket
        }
    }

    /// A handler that pages through `rockets` the way the live repository does.
    public static func paginating(
        _ rockets: [Rocket]
    ) -> @Sendable (_ limit: Int, _ offset: Int) async throws -> RocketPage {
        { limit, offset in
            let start = min(max(offset, 0), rockets.count)
            let end = min(start + max(limit, 0), rockets.count)
            return RocketPage(
                rockets: Array(rockets[start..<end]),
                totalCount: rockets.count,
                isLastPage: end >= rockets.count
            )
        }
    }
}

// swiftlint:disable line_length
extension Rocket {

    public static let previewValue: Rocket = Rocket(
        id: -1,
        name: "Falcon 9",
        fullName: "Falcon 9 Block 5",
        variant: "Block 5",
        isActive: true,
        imageURL: nil,
        successfulLaunches: 636,
        failedLaunches: 1,
        description:
            "Falcon 9 is a two-stage rocket designed and manufactured by SpaceX for the reliable and safe transport of satellites and the Dragon spacecraft into orbit.",
        family: "Falcon 9",
        isReusable: true,
        stageCount: 2
    )

    public static let samples: [Rocket] = [
        Rocket(
            id: 164,
            name: "Falcon 9",
            fullName: "Falcon 9 Block 5",
            variant: "Block 5",
            isActive: true,
            imageURL: URL(
                string:
                    "https://thespacedevs-dev.nyc3.digitaloceanspaces.com/media/images/falcon_9_image_20230807133459.jpeg"
            ),
            successfulLaunches: 636,
            failedLaunches: 1,
            description:
                "Falcon 9 is a two-stage rocket designed and manufactured by SpaceX for the reliable and safe transport of satellites and the Dragon spacecraft into orbit.",
            family: "Falcon 9",
            isReusable: true,
            stageCount: 2
        ),
        Rocket(
            id: 165,
            name: "Falcon Heavy",
            fullName: "Falcon Heavy",
            variant: nil,
            isActive: true,
            imageURL: URL(
                string:
                    "https://thespacedevs-dev.nyc3.digitaloceanspaces.com/media/images/falcon_heavy_image_20220129192819.jpeg"
            ),
            successfulLaunches: 11,
            failedLaunches: 0,
            description:
                "Falcon Heavy is a partially reusable heavy-lift launch vehicle built from three Falcon 9 first-stage cores.",
            family: "Falcon",
            isReusable: true,
            stageCount: 3
        ),
        Rocket(
            id: 187,
            name: "Starship",
            fullName: "Starship Block 2",
            variant: "Block 2",
            isActive: true,
            imageURL: URL(
                string:
                    "https://thespacedevs-dev.nyc3.digitaloceanspaces.com/media/images/starship_on_the_image_20250111100520.jpg"
            ),
            successfulLaunches: 3,
            failedLaunches: 2,
            description: "Starship is a fully reusable super heavy-lift launch vehicle under development by SpaceX.",
            family: "Starship",
            isReusable: true,
            stageCount: 2
        ),
        Rocket(
            id: 133,
            name: "Falcon 1",
            fullName: "Falcon 1",
            variant: "1",
            isActive: false,
            imageURL: URL(
                string:
                    "https://thespacedevs-dev.nyc3.digitaloceanspaces.com/media/images/falcon_image_20190222030438.jpeg"
            ),
            successfulLaunches: 2,
            failedLaunches: 3,
            description:
                "Falcon 1 was a small, two-stage, expendable rocket and the first privately developed liquid-fuel rocket to reach orbit.",
            family: "Falcon",
            isReusable: false,
            stageCount: 2
        )
    ]
}

// swiftlint:enable line_length
