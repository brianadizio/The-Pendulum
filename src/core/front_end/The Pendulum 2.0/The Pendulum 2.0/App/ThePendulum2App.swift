// ThePendulum2App.swift
// The Pendulum 2.0
// Main SwiftUI App entry point

import SwiftUI
import FirebaseCore

@main
struct ThePendulum2App: App {
    init() {
        FirebaseManager.shared.configure()

        // Initialize PurchaseManager early to start listening for transactions
        // and record trial start date on first launch
        _ = PurchaseManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await FirebaseManager.shared.signInAnonymously()

                    // Sync trial start date with Firebase (prevents reinstall gaming)
                    await PurchaseManager.shared.syncTrialStartWithFirebase()

                    // Request ATT permission + initialize Singular SDK (delayed for UI readiness)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        AppTrackingManager.shared.requestTrackingAndInitializeSingular { _ in
                            SingularTracker.trackInstall()
                        }
                    }
                }
        }
    }
}
