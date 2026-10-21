//
//  LaunchesRoute.swift
//  SpaceDomain
//
//  Created by Luca Gobbo on 18/10/2026.
//

public enum LaunchesRoute: Hashable, Sendable {
    case launch(Launch)
    case rocket(id: Int)
}
