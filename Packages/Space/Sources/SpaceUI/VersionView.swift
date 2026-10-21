//
//  VersionView.swift
//  Space
//
//  Created by Luca Gobbo on 19/10/2026.
//

import SwiftUI

public struct VersionView: View {
    // MARK: - Properties
    private var version: String
    private var build: String

    // MARK: - init

    public init(version: String, build: String) {
        self.version = version
        self.build = build
    }

    public init(bundle: Bundle = .main) {
        self.version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "–"
        self.build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "–"
    }

    // MARK: - Body
    public var body: some View {
        Text("SpaceX Info app: \(version) (\(build))", bundle: #bundle)
    }
}

// MARK: - Previews

#Preview {
    VersionView()
}
