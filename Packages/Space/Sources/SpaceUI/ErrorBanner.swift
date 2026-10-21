//
//  ErrorBanner.swift
//  Space
//
//  Created by Luca Gobbo on 17/10/2026.
//

import SwiftUI

/// Notification-style banner shown at the bottom of the screen when loading fails.
public struct ErrorBanner: View {

    // MARK: - Properties
    @Environment(\.dimensions) private var dimensions

    private var message: String
    private var onDismiss: () -> Void

    // MARK: - init
    public init(
        message: String,
        onDismiss: @escaping () -> Void
    ) {
        self.message = message
        self.onDismiss = onDismiss
    }

    // MARK: - Body
    public var body: some View {
        HStack(alignment: .top, spacing: dimensions.spaceS) {
            HStack(spacing: dimensions.spaceS) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)

                Text(message)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Dismiss", bundle: #bundle))
        }
        .padding(dimensions.spaceM)
        .glassEffect(.regular.tint(.red.opacity(0.15)), in: .rect(cornerRadius: 20))
    }
}

extension View {
    public func error(_ message: String?, dismiss: @escaping () -> Void) -> some View {
        modifier(
            ErrorViewModifier(
                message: message,
                dismiss: dismiss
            )
        )
    }
}

private struct ErrorViewModifier: ViewModifier {
    // MARK: - Properties
    @Environment(\.dimensions) private var dimensions
    var message: String?
    var dismiss: () -> Void

    // MARK: - Body
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let message {
                    ErrorBanner(message: message) {
                        dismiss()
                    }
                    .padding(.horizontal, dimensions.spaceM)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.default, value: message == nil)
    }
}

// MARK: - Previews

#Preview("Banner") {
    ErrorBanner(message: "Couldn't load launches. Check your connection and try again.") {}
        .padding()
}

#Preview("Swipe to dismiss") {
    @Previewable @State var message: String? = "Couldn't load launches. Check your connection and try again."

    NavigationStack {
        List(0..<20, id: \.self) { Text("Row \($0)") }
            .navigationTitle("Launches")
            .toolbar {
                Button("Show error") {
                    message = "Couldn't load launches. Check your connection and try again."
                }
            }
            .error(message) { message = nil }
    }

}
