//
//  LoadState.swift
//  SpaceDomain
//
//  Created by Luca Gobbo on 19/10/2026.
//

public enum LoadState<Value> {
    case loading
    case loaded(Value)
    case failed(String)

    public var value: Value? {
        switch self {
        case .loaded(let value): value
        case .failed, .loading: nil
        }
    }

    public var isLoaded: Bool {
        switch self {
        case .loaded: true
        case .failed, .loading: false
        }
    }

    public var isError: Bool {
        switch self {
        case .loaded, .loading: false
        case .failed: true
        }
    }

    public var isLoading: Bool {
        switch self {
        case .loading: true
        case .loaded, .failed: false
        }
    }

    public var error: String? {
        switch self {
        case .loaded, .loading: nil
        case .failed(let message): message
        }
    }
}

// MARK: - Conditional conformances
extension LoadState: Equatable where Value: Equatable {}
extension LoadState: Sendable where Value: Sendable {}
