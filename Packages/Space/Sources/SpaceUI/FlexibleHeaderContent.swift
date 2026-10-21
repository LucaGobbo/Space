//
//  FlexibleHeaderContent.swift
//  SpaceUI
//
//  Created by Luca Gobbo on 18/10/2026.
//

import SwiftUI

/// Keeps a header anchored to the top of the enclosing scroll view while it is pulled past its top edge.
private struct FlexibleHeaderContent: ViewModifier {
    func body(content: Content) -> some View {
        content.visualEffect { effect, geometry in
            let overscroll = max(0, geometry.frame(in: .scrollView).minY)
            return effect.offset(y: -overscroll)
        }
    }
}

extension View {
    /// Keeps the view pinned to the top of the scroll view while it is pulled down.
    /// Combine with `backgroundExtensionEffect()` for the full effect.
    public func flexibleHeaderContent() -> some View {
        modifier(FlexibleHeaderContent())
    }
}
