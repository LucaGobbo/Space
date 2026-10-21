//
//  SettingsScreen.swift
//  Space
//
//  Created by Luca Gobbo on 19/10/2026.
//

import Foundation
import SwiftUI
import SpaceUI

// Debug menu: the environment switch crashes the app on purpose, so it never ships in release builds.
#if DEBUG
    struct SettingsScreen: View {

        // MARK: - Properties
        @AppStorage("isProductionEnvironment") private var isProductionEnvironment = false
        @State private var isProductionEnvironmentToggle: Bool
        @State private var isConfirmationDialogPresented = false

        // MARK: - init
        init() {

            self._isProductionEnvironmentToggle = .init(
                initialValue: UserDefaults.standard.bool(forKey: "isProductionEnvironment")
            )
        }

        // MARK: - Body
        var body: some View {
            NavigationStack {
                Form {
                    Section {
                        Toggle("Production environment", isOn: $isProductionEnvironmentToggle)
                        Button("Save", role: .destructive) {
                            isConfirmationDialogPresented.toggle()
                        }
                        .disabled(isProductionEnvironmentToggle == isProductionEnvironment)
                        .confirmationDialog(
                            "Change environment",
                            isPresented: $isConfirmationDialogPresented,
                            titleVisibility: .visible
                        ) {
                            Button("Save", role: .destructive) {
                                isProductionEnvironment = isProductionEnvironmentToggle
                                fatalError("crash app to change environment")
                            }
                        } message: {
                            Text("Changing the environment means restarting the app")
                        }

                    } footer: {
                        Text(
                            """
                            When changing to a different environment, you need to save it first.
                            We crash the application to restart and switch the environment.

                            ⚠️ Production environment has a rate limit of 15 request per hour
                            """
                        )
                        .multilineTextAlignment(.leading)
                    }
                }
                .safeAreaInset(edge: .bottom) {

                    VersionView()
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .padding()

                }
                .navigationTitle("Settings")
                .navigationSubtitle("Debug menu")
            }
        }
    }

    #Preview {
        SettingsScreen()
    }
#endif
