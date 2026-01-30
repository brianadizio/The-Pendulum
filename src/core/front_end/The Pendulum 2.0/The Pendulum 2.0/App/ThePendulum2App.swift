// ThePendulum2App.swift
// The Pendulum 2.0
// Main SwiftUI App entry point

import SwiftUI
import FirebaseCore

@main
struct ThePendulum2App: App {
    init() {
        FirebaseManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await FirebaseManager.shared.signInAnonymously()
                }
        }
    }
}
