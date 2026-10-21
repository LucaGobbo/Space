//
//  RocketTypeBox.swift
//  RocketDetailFeature
//
//  Created by Luca Gobbo on 18/10/2026.
//

import SpaceDomain
import SpaceUI
import SwiftUI

/// The family, reusability and stage count of a rocket. Fields the rocket doesn't have are omitted.
struct RocketTypeBox: View {
    // MARK: - Properties
    @Environment(\.dimensions) private var dimensions
    var rocket: Rocket

    // MARK: - Body
    var body: some View {
        GroupBox {
            VStack(spacing: dimensions.spaceS) {
                if let family = rocket.family {
                    LabeledContent(LocalizedStringResource("Family", bundle: #bundle), value: family)
                }
                if let isReusable = rocket.isReusable {
                    LabeledContent(LocalizedStringResource("Reusability", bundle: #bundle)) {
                        Text(
                            isReusable
                                ? LocalizedStringResource("Reusable", bundle: #bundle)
                                : LocalizedStringResource("Expendable", bundle: #bundle)
                        )
                    }
                }
                if let stageCount = rocket.stageCount {
                    LabeledContent(LocalizedStringResource("Stages", bundle: #bundle), value: stageCount.formatted())
                }
            }
            .font(.subheadline)
        } label: {
            Label(LocalizedStringResource("Type", bundle: #bundle), systemImage: "airplane.departure")
        }
    }
}

// MARK: - Previews
@available(anyAppleOS, introduced: 27)
#Preview(arguments: Rocket.samples) { rocket in
    RocketTypeBox(rocket: rocket)
        .padding()
}
