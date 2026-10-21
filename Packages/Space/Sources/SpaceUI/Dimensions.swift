//
//  Dimensions.swift
//  Space
//
//  Created by Luca Gobbo on 17/10/2026.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry public var dimensions = Dimensions()
}

public struct Dimensions: Equatable {
    // MARK: - Properties
    /// 8.0
    public var spaceXs: CGFloat = 4
    /// 8.0
    public var spaceS: CGFloat = 8
    /// 16.0
    public var spaceM: CGFloat = 16
}
