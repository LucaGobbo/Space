//
//  RefreshView.swift
//  SpaceUI
//
//  Created by Luca Gobbo on 17/10/2026.
//

import SwiftUI

public struct RefreshView<Label: View, Description: View>: View {
    // MARK: - Properties
    @Environment(\.refresh) private var refresh
    @ViewBuilder private var label: Label
    @ViewBuilder private var description: Description

    // MARK: - init
    public init(
        @ViewBuilder label: () -> Label,
        @ViewBuilder description: () -> Description = { EmptyView() }
    ) {
        self.label = label()
        self.description = description()
    }

    // MARK: - Body
    public var body: some View {
        ContentUnavailableView {
            label
        } description: {
            description
        } actions: {
            Button {
                Task {
                    await refresh?()
                }
            } label: {
                SwiftUI.Label(LocalizedStringResource("Refresh", bundle: #bundle), systemImage: "arrow.clockwise")
            }

        }
    }
}
