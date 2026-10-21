import SnapshotTesting
import SpaceDomain
import SwiftUI
import Testing

@testable import SpaceUI

@MainActor
@Suite(.tags(.ui), .snapshots(record: .missing))
struct SpaceUISnapshotTests {

    init() throws {
        try SpaceUISnapshotTests.requireSimulator()
    }

    /// Reference images are recorded on an iPhone 18 Pro; any other device renders differently.
    nonisolated static let requiredSimulator = "iPhone 18 Pro"

    struct WrongSimulatorError: Error, CustomStringConvertible {
        let actual: String?
        var description: String {
            """
            Snapshot tests require the \(SpaceUISnapshotTests.requiredSimulator) simulator,
            but ran on \(actual ?? "a non-simulator destination").
            """
        }
    }

    static func requireSimulator() throws {
        let name = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"]
        guard name == requiredSimulator else { throw WrongSimulatorError(actual: name) }
    }

    @Suite("StatusLabel")
    @MainActor
    struct StatusLabelTests {
        init() throws {
            try SpaceUISnapshotTests.requireSimulator()
        }

        @Test(
            "WHEN showing a status, THEN it renders its symbol and abbreviation",
            arguments: ["success", "failure", "hold", "go", ""]
        )
        func status(abbreviation: String) {
            let view = StatusLabel(status: .init(name: abbreviation, abbreviation: abbreviation))
            assertSnapshot(
                of: view.padding(),
                as: .image(layout: .fixed(width: 160, height: 44)),
                named: abbreviation.isEmpty ? "unknown" : abbreviation,
                testName: "status"
            )
        }
    }

    @Suite("VersionView")
    @MainActor
    struct VersionViewTest {
        init() throws {
            try SpaceUISnapshotTests.requireSimulator()
        }

        @Test(
            "WHEN showing a status, THEN it renders its symbol and abbreviation",
        )
        func version() {
            let view = VersionView(version: "1.0.1", build: "23")
            assertSnapshot(
                of: view.padding(),
                as: .image(layout: .fixed(width: 160, height: 44)),
                named: "version",
                testName: "version"
            )
        }
    }

    @Suite("RefreshView")
    @MainActor
    struct RefreshViewTests {
        init() throws {
            try SpaceUISnapshotTests.requireSimulator()
        }

        @Test("WHEN loading failed, THEN it renders the label, description and refresh button")
        func refresh() {
            let view = RefreshView {
                Label("No launches", systemImage: "rocket")
            } description: {
                Text("Pull to refresh or try again.")
            }
            .background(.background)
            assertSnapshot(
                of: view,
                as: .image(layout: .fixed(width: 390, height: 300)),
                testName: "refresh"
            )
        }
    }
}
