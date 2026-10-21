//
//  LoadingView.swift
//  Space
//
//  Created by Luca Gobbo on 19/10/2026.
//

import SpaceDomain
import SwiftUI

public struct LoadingView<Value: Equatable, Content: View>: View {
    // MARK: - Properties
    @Environment(\.refresh) private var refresh
    private var state: LoadState<Value>
    private var placeHolder: Value
    @ViewBuilder private var content: (Value) -> Content

    // MARK: - init
    public init(
        state: LoadState<Value>,
        placeHolder: Value,
        @ViewBuilder content: @escaping (Value) -> Content
    ) {
        self.state = state
        self.placeHolder = placeHolder
        self.content = content
    }

    // MARK: - Body
    public var body: some View {
        ScrollView {
            content(state.value ?? placeHolder)
                .redacted(reason: state.value == nil ? .placeholder : [])
                .opacity(state.isError ? 0 : 1)
        }
        .overlay {
            if let error = state.error {
                ContentUnavailableView {
                    Label(
                        LocalizedStringResource("Couldn't load the rocket", bundle: #bundle),
                        systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error)
                } actions: {
                    Button(LocalizedStringResource("Try again", bundle: #bundle)) {
                        Task { await refresh?() }
                    }
                }
                .transition(.blurReplace)
            }
        }
        .animation(.default, value: state)
    }
}
