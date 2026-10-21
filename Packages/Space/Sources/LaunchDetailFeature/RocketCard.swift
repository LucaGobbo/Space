//
//  RocketCard.swift
//  Space
//
//  Created by Luca Gobbo on 18/10/2026.
//

import SpaceDomain
import SwiftUI

struct RocketCard: View {
    // MARK: - Properties
    var rocket: Launch.RocketConfiguration

    // MARK: - Body
    var body: some View {
        GroupBox {
            HStack {
                VStack(alignment: .leading) {
                    Text(rocket.name).font(.headline)
                    if let variant = rocket.variant, !variant.isEmpty {
                        Text(variant)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        } label: {
            Label(LocalizedStringResource("Rocket", bundle: #bundle), systemImage: "airplane.departure")
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Previews

#Preview {
    RocketCard(
        rocket: .init(
            id: 1,
            name: "Rocket",
            fullName: "long fullname",
            variant: "my variant"
        )
    )
}
