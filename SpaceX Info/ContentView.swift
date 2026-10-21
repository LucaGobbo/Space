//
//  ContentView.swift
//  SpaceX Info
//
//  Created by Luca Gobbo on 18/10/2026.
//

private import Space
private import SpaceAPI
private import SpaceData
import SwiftUI

struct ContentView: View {

    // MARK: Properties
    @AppStorage("isProductionEnvironment") private var isProductionEnvironment = false
    private var environment: APIEnvironment {
        isProductionEnvironment ? .production : .development
    }
    // MARK: - body

    var body: some View {
        SpaceTabView(
            launchRepository: LiveLaunchRepository(
                service: .init(environment: environment)
            ),
            rocketRepository: LiveRocketRepository(
                service: .init(environment: environment)
            )
        )
    }
}
