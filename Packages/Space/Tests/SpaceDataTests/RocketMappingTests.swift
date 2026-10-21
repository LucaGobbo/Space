import Foundation
import SpaceAPI
import SpaceDomain
import Testing

@testable import SpaceData

@Suite(.tags(.data))
struct RocketMappingTests {

    // MARK: - Rocket

    // swiftlint:disable line_length
    struct MappingRocket {
        static let falcon9Description =
            "Falcon 9 is a two-stage rocket designed and manufactured by SpaceX for the reliable and safe transport of satellites and the Dragon spacecraft into orbit. The Block 5 variant is the fifth major interval aimed at improving upon the ability for rapid reusability."

        @Test func `WHEN mapping a recorded rocket, THEN every field is mapped`() throws {
            let rocket = try #require(try RocketMappingTests.recordedPage().rockets.dropFirst().first)

            #expect(
                rocket
                    == Rocket(
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
                        description: Self.falcon9Description,
                        family: "Falcon 9",
                        isReusable: true,
                        stageCount: 2
                    ))
        }

        @Test func `WHEN mapping a recorded single rocket, THEN it equals the same rocket from the page`() throws {
            let single = try RocketMappingTests.recordedRocket()
            let fromPage = try #require(try RocketMappingTests.recordedPage().rockets.dropFirst().first)

            #expect(single == fromPage)
        }

        @Test func `WHEN fields are missing, THEN they map to nil and inactive`() throws {
            let rocket = try RocketMappingTests.rocket(
                """
                { "id": 1, "name": "Sparse", "full_name": null, "variant": null, "active": null, "image": null }
                """)

            #expect(
                rocket
                    == Rocket(
                        id: 1, name: "Sparse", fullName: nil, variant: nil, isActive: false, imageURL: nil))
        }

        @Test func `WHEN detail fields are missing, THEN they map to nil`() throws {
            let rocket = try RocketMappingTests.rocket(
                """
                { "id": 3, "name": "Bare", "description": null, "families": [], "reusable": null, "max_stage": null }
                """)

            #expect(rocket.description == nil)
            #expect(rocket.family == nil)
            #expect(rocket.isReusable == nil)
            #expect(rocket.stageCount == nil)
        }

        @Test func `WHEN an image has no URL, THEN there is no image URL`() throws {
            let rocket = try RocketMappingTests.rocket(
                """
                { "id": 2, "name": "No image URL", "image": { "image_url": null } }
                """)

            #expect(rocket.imageURL == nil)
        }
    }

    // MARK: - Page

    struct MappingPage {
        @Test func `WHEN mapping a recorded page, THEN the order is kept`() throws {
            let page = try RocketMappingTests.recordedPage()

            #expect(page.totalCount == 13)
            #expect(!page.isLastPage)
            #expect(page.rockets.map(\.id) == [133, 164, 169, 145, 55, 14, 161, 522, 527, 528])
        }

        @Test func `WHEN a page has no next URL, THEN it is the last page`() throws {
            let page = try RocketMappingTests.page(
                """
                { "count": 2, "next": null, "previous": null, "results": [] }
                """)

            #expect(page == RocketPage(rockets: [], totalCount: 2, isLastPage: true))
        }
    }

    // MARK: - Helpers

    /// A real Launch Library response for one rocket (Falcon 9 Block 5, `mode=detailed`).
    static func recordedRocket() throws -> Rocket {
        let url = try #require(
            Bundle.module.url(forResource: "rocket", withExtension: "json", subdirectory: "Fixtures"))
        let dto = try RocketsResponseDTO.decoder.decode(RocketsResponseDTO.Rocket.self, from: Data(contentsOf: url))
        return Rocket(dto: dto)
    }

    /// The first page of a real Launch Library response (SpaceX, `mode=detailed`).
    static func recordedPage() throws -> RocketPage {
        let url = try #require(
            Bundle.module.url(forResource: "rockets", withExtension: "json", subdirectory: "Fixtures"))
        let dto = try RocketsResponseDTO.decoder.decode(RocketsResponseDTO.self, from: Data(contentsOf: url))
        return RocketPage(dto: dto)
    }

    static func page(_ json: String) throws -> RocketPage {
        let dto = try RocketsResponseDTO.decoder.decode(RocketsResponseDTO.self, from: Data(json.utf8))
        return RocketPage(dto: dto)
    }

    /// Maps a single rocket, wrapped in a one-item response.
    static func rocket(_ json: String) throws -> Rocket {
        let page = try page(
            """
            { "count": 1, "next": null, "previous": null, "results": [\(json)] }
            """)
        return try #require(page.rockets.first)
    }

    // swiftlint:enable line_length
}
