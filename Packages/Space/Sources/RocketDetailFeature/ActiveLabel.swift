//
//  ActiveLabel.swift
//  RocketDetailFeature
//
//  Created by Luca Gobbo on 18/10/2026.
//

import SwiftUI

struct ActiveLabel: View {
    // MARK: - Properties
    var isActive: Bool

    // MARK: - Body
    var body: some View {
        Label(
            isActive
                ? LocalizedStringResource("Active", bundle: #bundle)
                : LocalizedStringResource("Retired", bundle: #bundle),
            systemImage: isActive ? "checkmark.circle.fill" : "moon.zzz.fill"
        )
        .font(.subheadline.weight(.medium))
        .foregroundStyle(isActive ? Color.green : Color.secondary)
    }
}

// MARK: - Previews

@available(anyAppleOS, introduced: 27)
#Preview("Active", arguments: [true, false]) { isActive in
    ActiveLabel(isActive: isActive)
        .padding()
}
