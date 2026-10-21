import Foundation
import SpaceAPI
import SpaceDomain
import Testing

@testable import SpaceData

@Suite(.tags(.data))
struct LaunchMappingTests {

    // MARK: - Launch

    struct MappingLaunch {
        // swiftlint:disable line_length
        @Test func `WHEN mapping a recorded launch, THEN every field is mapped`() throws {
            let launch = try #require(try LaunchMappingTests.recordedPage().launches.first)

            #expect(
                launch
                    == Launch(
                        id: "ed145de1-b768-43b5-8563-18ebc93b69b5",
                        name: "Falcon 9 Block 5 | Starlink Group 10-17",
                        date: ISO8601DateFormatter().date(from: "2025-10-19T17:39:40Z"),
                        status: Launch.Status(name: "Launch Successful", abbreviation: "Success"),
                        launchSite: "Cape Canaveral SFS, FL, USA",
                        launchSiteCoordinate: Launch.Coordinate(latitude: 28.56194122, longitude: -80.57735736),
                        imageURL: URL(
                            string:
                                "https://thespacedevs-dev.nyc3.digitaloceanspaces.com/media/images/falcon2520925_image_20221009234147.png"
                        ),
                        missionDescription:
                            "A batch of 28 satellites for the Starlink mega-constellation - SpaceX's project for space-based Internet communication system.",
                        watchURLs: [],
                        rocket: Launch.RocketConfiguration(
                            id: 164, name: "Falcon 9", fullName: "Falcon 9 Block 5", variant: "Block 5")
                    ))
        }
        // swiftlint:enable line_length

        @Test func `WHEN fields are missing, THEN they map to nil and empty`() throws {
            let launch = try LaunchMappingTests.launch(
                """
                { "id": "def", "name": "Sparse launch", "net": null, "status": null, "image": null,
                  "pad": null, "mission": null, "rocket": null }
                """)

            #expect(
                launch
                    == Launch(
                        id: "def",
                        name: "Sparse launch",
                        date: nil,
                        status: nil,
                        launchSite: nil,
                        imageURL: nil,
                        missionDescription: nil,
                        watchURLs: [],
                        rocket: nil
                    ))
        }

        @Test func `WHEN a pad has no location, THEN there is no launch site`() throws {
            let launch = try LaunchMappingTests.launch(
                """
                { "id": "ghi", "name": "No site", "pad": { "location": null } }
                """)

            #expect(launch.launchSite == nil)
        }

        @Test func `WHEN a pad has no coordinates, THEN there is no launch site coordinate`() throws {
            let launch = try LaunchMappingTests.launch(
                """
                { "id": "mno", "name": "No coordinates",
                  "pad": { "latitude": null, "longitude": null, "location": { "name": "Somewhere" } } }
                """)

            #expect(launch.launchSiteCoordinate == nil)
            #expect(launch.launchSite == "Somewhere")
        }

        @Test func `WHEN a rocket has no full name or variant, THEN they are nil`() throws {
            let launch = try LaunchMappingTests.launch(
                """
                { "id": "jkl", "name": "Bare rocket",
                  "rocket": { "configuration": { "id": 1, "name": "Falcon 1", "full_name": null, "variant": null } } }
                """)

            #expect(launch.rocket == Launch.RocketConfiguration(id: 1, name: "Falcon 1", fullName: nil, variant: nil))
        }
    }

    // MARK: - Page

    struct MappingPage {
        @Test func `WHEN mapping a recorded page, THEN the order is kept`() throws {
            let page = try LaunchMappingTests.recordedPage()

            #expect(page.totalCount == 227)
            #expect(!page.isLastPage)
            #expect(
                page.launches.map(\.id) == [
                    "ed145de1-b768-43b5-8563-18ebc93b69b5", "0d2920f2-87d9-4c5a-aebe-614d8baae2a2",
                    "67c287d7-199e-4811-a43a-b540b3c4d186", "6ecd1d24-db6d-4144-8e1b-f6ba5ceae8be",
                    "b99e48e1-e424-4b4f-8523-a19259d6a6c6", "5707ddea-8f06-4a3b-83d1-cfd8a3017637",
                    "22eb6520-2a51-4f60-b1b8-41a6bf711768", "94ec1605-bd9c-47fa-9f36-69148ee4e370",
                    "e92f090c-cb6a-4e1a-8e07-5a97dbf1c450", "41d2ac1b-a506-47ae-8e44-8b65f5d6f239"
                ])
        }

        @Test func `WHEN a page has no next URL, THEN it is the last page`() throws {
            let page = try LaunchMappingTests.page(
                """
                { "count": 2, "next": null, "previous": null, "results": [] }
                """)

            #expect(page == LaunchPage(launches: [], totalCount: 2, isLastPage: true))
        }
    }

    // MARK: - Helpers

    static func recordedPage() throws -> LaunchPage {
        let url = try #require(
            Bundle.module.url(forResource: "launches", withExtension: "json", subdirectory: "Fixtures"))
        let dto = try LaunchesResponseDTO.decoder.decode(LaunchesResponseDTO.self, from: Data(contentsOf: url))
        return LaunchPage(dto: dto)
    }

    static func page(_ json: String) throws -> LaunchPage {
        let dto = try LaunchesResponseDTO.decoder.decode(LaunchesResponseDTO.self, from: Data(json.utf8))
        return LaunchPage(dto: dto)
    }

    /// Maps a single launch, wrapped in a one-item response.
    static func launch(_ json: String) throws -> Launch {
        let page = try page(
            """
            { "count": 1, "next": null, "previous": null, "results": [\(json)] }
            """)
        return try #require(page.launches.first)
    }
}
