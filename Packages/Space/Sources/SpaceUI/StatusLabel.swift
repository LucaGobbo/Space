//
//  StatusLabel.swift
//  Space
//
//  Created by Luca Gobbo on 17/10/2026.
//

import SpaceDomain
import SwiftUI

public struct StatusLabel: View {
    // MARK: - Properties
    @Environment(\.dimensions) private var dimensions
    private var status: Launch.Status

    // MARK: - init
    public init(status: Launch.Status) {
        self.status = status
    }

    // MARK: - Body
    public var body: some View {
        HStack(spacing: dimensions.spaceXs) {
            Image(systemName: status.symbol)
            Text(status.abbreviation)
        }
        .font(.subheadline.weight(.medium))
        .foregroundStyle(status.color)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(status.name)
    }
}

extension Launch.Status {
    public var symbol: String {
        switch abbreviation.lowercased() {
        case "success": "checkmark.circle.fill"
        case "failure": "xmark.circle.fill"
        case "hold": "pause.circle.fill"
        case "go": "arrow.up.circle.fill"
        default: "clock.fill"
        }
    }

    fileprivate var color: Color {
        switch abbreviation.lowercased() {
        case "go", "success": .green
        case "failure": .red
        case "hold": .orange
        default: .secondary
        }
    }
}

// MARK: - Previews

@available(anyAppleOS, introduced: 27)
#Preview(
    arguments: ["success", "failure", "hold", "go", ""].map { Launch.Status(name: $0, abbreviation: $0) }
) { status in
    StatusLabel(status: status)
}
