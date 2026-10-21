//
//  APIEnvironment.swift
//  SpaceAPI
//
//  Created by Luca Gobbo on 17/10/2026.
//

import Foundation

/// The Launch Library 2 deployment to talk to.
public enum APIEnvironment: Sendable {
    /// Rate limited (15 calls per hour when unauthenticated).
    case production
    /// Stale and limited data, but no rate limits.
    case development

    /// if the url is incorrect the app should crash, using a ! here is a valid exception
    public var baseURL: URL {
        switch self {
        case .production: URL(string: "https://ll.thespacedevs.com/2.3.0")!
        case .development: URL(string: "https://lldev.thespacedevs.com/2.3.0")!
        }
    }
}
