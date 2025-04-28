//
//  The_PendulumApp.swift
//  The Pendulum
//
//  Created by Brian DiZio on 4/27/25.
//

import SwiftUI
import UIKit

// NOTE: This SwiftUI wrapper is kept for reference but not currently used
// We're using AppDelegate/SceneDelegate as the entry point instead

struct The_PendulumApp: App {
    var body: some Scene {
        WindowGroup {
            PendulumViewControllerRepresentable()
                .ignoresSafeArea()
        }
    }
}

// SwiftUI wrapper for UIKit view controller
struct PendulumViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PendulumViewController {
        return PendulumViewController()
    }
    
    func updateUIViewController(_ uiViewController: PendulumViewController, context: Context) {
        // Updates can be handled here if needed
    }
}
