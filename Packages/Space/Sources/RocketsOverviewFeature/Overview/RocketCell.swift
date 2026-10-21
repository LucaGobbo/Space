//
//  RocketCell.swift
//  Space
//
//  Created by Luca Gobbo on 18/10/2026.
//

import SpaceDomain
private import SpaceUI
import SwiftUI

struct RocketCell: View {

    // MARK: - Properties
    @Environment(\.dimensions) private var dimensions
    var rocket: Rocket

    private var totalLaunches: Int {
        (rocket.successfulLaunches ?? 0) + (rocket.failedLaunches ?? 0)
    }

    var succesRate: String? {
        guard let successRate = rocket.successRate else { return nil }
        let percentage = successRate.formatted(.percent.precision(.fractionLength(0)))
        return "\(percentage) (\(totalLaunches) launches)"
    }

    // MARK: - init
    var body: some View {
        HStack(alignment: .top, spacing: dimensions.spaceM) {
            AsyncImage(url: rocket.imageURL) { image in
                image.resizable()
                    .frame(width: 90, height: 90)
                    .scaledToFill()
            } placeholder: {
                Color.secondary.opacity(0.15)
            }
            .frame(width: 90, height: 90)
            .clipShape(ConcentricRectangle(corners: .concentric(minimum: 8)))

            VStack(alignment: .leading, spacing: dimensions.spaceXs) {
                Text(rocket.fullName ?? rocket.name)
                VStack(alignment: .leading, spacing: dimensions.spaceXs) {
                    if let variant = rocket.variant {
                        LabeledContent(LocalizedStringResource("Variant", bundle: #bundle), value: variant)
                    }
                    if let succesRate {
                        LabeledContent(LocalizedStringResource("Success rate", bundle: #bundle), value: "\(succesRate)")
                    }
                }
                .font(.caption)
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            RocketCell(rocket: Rocket.samples.randomElement()!)
        }
        .navigationTitle(LocalizedStringResource("Rockets", bundle: #bundle))
    }
}
