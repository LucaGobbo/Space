//
//  Error+Cancellation.swift
//  SpaceCore
//
//  Created by Luca Gobbo on 17/10/2026.
//

import Foundation

extension Error {
    /// Whether this error only reports that the work was cancelled (structured or `URLSession`).
    public var isCancellation: Bool {
        self is CancellationError || (self as? URLError)?.code == .cancelled
    }
}
