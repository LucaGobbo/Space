//
//  MockLaunchRepository.swift
//  SpaceDomain
//
//  Created by Luca Gobbo on 17/10/2026.
//

import Foundation

public struct MockLaunchRepository: LaunchRepository {
    // MARK: - Properties
    private let launches:
        @Sendable (
            _ range: ClosedRange<Date>?,
            _ limit: Int, _ offset: Int
        ) async throws -> LaunchPage

    // MARK: - init
    public init(
        launches:
            @escaping @Sendable (
                _ range: ClosedRange<Date>?,
                _ limit: Int,
                _ offset: Int
            ) async throws -> LaunchPage = MockLaunchRepository.paginating(Launch.samples)
    ) {
        self.launches = launches
    }

    public func launches(
        in range: ClosedRange<Date>?,
        limit: Int,
        offset: Int
    ) async throws -> LaunchPage {
        try await launches(range, limit, offset)
    }

    /// Serves one launch per request, so the first page is never the last until `Launch.samples` runs out.
    public static let paging = MockLaunchRepository { _, _, offset in
        try await Task.sleep(for: .seconds(1))
        guard Launch.samples.indices.contains(offset) else {
            return LaunchPage(launches: [], totalCount: Launch.samples.count, isLastPage: true)
        }
        return LaunchPage(
            launches: [Launch.samples[offset]],
            totalCount: offset + 1,
            isLastPage: offset == Launch.samples.count - 1
        )
    }

    /// Returns no launches.
    public static let empty = MockLaunchRepository { _, _, _ in
        try await Task.sleep(for: .seconds(0.3))
        return LaunchPage(launches: [], totalCount: 0, isLastPage: true)
    }

    /// Throws after a short delay.
    public static let failing = MockLaunchRepository { _, _, _ in
        try await Task.sleep(for: .seconds(0.4))
        throw NSError(domain: "", code: 2)
    }

    /// Pages through `Launch.samples` after waiting `duration` on every request.
    public static func delayed(for duration: Duration) -> MockLaunchRepository {
        let page = paginating(Launch.samples)
        return MockLaunchRepository { range, limit, offset in
            try await Task.sleep(for: duration)
            return try await page(range, limit, offset)
        }
    }

    /// A handler that pages through `launches` the way the live repository does; ignores `range`.
    public static func paginating(
        _ launches: [Launch]
    ) -> @Sendable (_ range: ClosedRange<Date>?, _ limit: Int, _ offset: Int) async throws -> LaunchPage {
        { _, limit, offset in
            let start = min(max(offset, 0), launches.count)
            let end = min(start + max(limit, 0), launches.count)
            return LaunchPage(
                launches: Array(launches[start..<end]),
                totalCount: launches.count,
                isLastPage: end >= launches.count
            )
        }
    }
}

// swiftlint:disable line_length
extension Launch {
    public static let samples: [Launch] = [
        Launch(
            id: "b1e2d3c4-5a6f-4789-8abc-0d1e2f3a4b5c",
            name: "Starship | Flight 12",
            date: nil,
            status: Status(name: "To Be Determined", abbreviation: "TBD"),
            launchSite: "Starbase, TX, USA",
            launchSiteCoordinate: Launch.Coordinate(latitude: 25.9972, longitude: -97.1561),
            imageURL: nil,
            missionDescription: nil,
            watchURLs: [],
            rocket: Launch.RocketConfiguration(
                id: 187,
                name: "Starship",
                fullName: "Starship Block 2",
                variant: "Block 2"
            )
        ),
        Launch(
            id: "0f9e8d7c-6b5a-4c3d-9e2f-1a0b9c8d7e6f",
            name: "Falcon 9 Block 5 | Crew-12",
            date: Date(timeIntervalSince1970: 1_790_000_000),
            status: Status(name: "Go for Launch", abbreviation: "Go"),
            launchSite: "Cape Canaveral SFS, FL, USA",
            launchSiteCoordinate: Launch.Coordinate(latitude: 28.56194122, longitude: -80.57735736),
            imageURL: URL(
                string:
                    "https://thespacedevs-dev.nyc3.digitaloceanspaces.com/media/images/falcon_9_liftof_image_20251102082912.jpg"
            ),
            missionDescription: "Crew rotation flight to the International Space Station.",
            watchURLs: [URL(string: "https://example.com/watch/crew-12")!],
            rocket: .falcon9
        ),
        Launch(
            id: "ed145de1-b768-43b5-8563-18ebc93b69b5",
            name: "Falcon 9 Block 5 | Starlink Group 10-17",
            date: Date(timeIntervalSince1970: 1_760_895_580),
            status: Status(name: "Launch Successful", abbreviation: "Success"),
            launchSite: "Cape Canaveral SFS, FL, USA",
            launchSiteCoordinate: Launch.Coordinate(latitude: 28.56194122, longitude: -80.57735736),
            imageURL: URL(
                string:
                    "https://thespacedevs-dev.nyc3.digitaloceanspaces.com/media/images/falcon_9_image_20230807133459.jpeg"
            ),
            missionDescription: "A batch of 28 satellites for the Starlink mega-constellation.",
            watchURLs: [],
            rocket: .falcon9
        ),
        Launch(
            id: "9a8b7c6d-5e4f-4a3b-8c2d-1e0f9a8b7c6d",
            name: "Falcon 9 Block 5 | Transporter-15",
            date: Date(timeIntervalSince1970: 1_730_000_000),
            status: Status(name: "Launch Successful", abbreviation: "Success"),
            launchSite: "Vandenberg SFB, CA, USA",
            launchSiteCoordinate: Launch.Coordinate(latitude: 34.632, longitude: -120.611),
            imageURL: URL(
                string:
                    "https://thespacedevs-dev.nyc3.digitaloceanspaces.com/media/images/falcon2520925_image_20231223073520.jpeg"
            ),
            missionDescription: "A rideshare mission carrying small satellites to sun-synchronous orbit.",
            watchURLs: [],
            rocket: .falcon9
        ),
        Launch(
            id: "6c7b2a1e-1f4d-4a53-9b0c-7f4d6a0e1a11",
            name: "Falcon Heavy | USSF-52",
            date: Date(timeIntervalSince1970: 1_700_000_000),
            status: Status(name: "Launch Successful", abbreviation: "Success"),
            launchSite: "Kennedy Space Center, FL, USA",
            launchSiteCoordinate: Launch.Coordinate(latitude: 28.6082, longitude: -80.6041),
            imageURL: URL(
                string:
                    "https://thespacedevs-dev.nyc3.digitaloceanspaces.com/media/images/falcon_heavy_on_image_20260427051334.jpg"
            ),
            missionDescription: "A US Space Force mission to orbit the X-37B spaceplane.",
            watchURLs: [URL(string: "https://example.com/watch/ussf-52")!],
            rocket: Launch.RocketConfiguration(id: 165, name: "Falcon Heavy", fullName: "Falcon Heavy", variant: nil)
        )
    ]
}

// swiftlint:enable line_length

extension Launch.RocketConfiguration {
    fileprivate static let falcon9 = Launch.RocketConfiguration(
        id: 164,
        name: "Falcon 9",
        fullName: "Falcon 9 Block 5",
        variant: "Block 5"
    )
}
