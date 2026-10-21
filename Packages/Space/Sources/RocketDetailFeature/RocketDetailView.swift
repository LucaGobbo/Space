//
//  RocketDetailView.swift
//  RocketDetailFeature
//
//  Created by Luca Gobbo on 18/10/2026.
//

import SpaceDomain
import SpaceUI
import SwiftUI

/// The content of a loaded rocket. Holds no state, so it previews with any `Rocket`.
struct RocketDetailView: View {
    // MARK: - Properties
    @Environment(\.dimensions) private var dimensions
    var rocket: Rocket

    // MARK: - Body
    var body: some View {
        LazyVStack(alignment: .leading, spacing: dimensions.spaceM) {
            HeroImage(imageURL: rocket.imageURL)
            ActiveLabel(isActive: rocket.isActive)
            if let description = rocket.description, !description.isEmpty {
                Text(description).foregroundStyle(.secondary)
            }
            RocketTypeBox(rocket: rocket)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, dimensions.spaceM)

    }
}

// MARK: - Previews
@available(anyAppleOS, introduced: 27)
#Preview(arguments: Rocket.samples) { rocket in
    NavigationStack {
        ScrollView {
            RocketDetailView(rocket: rocket)
        }

    }
}
