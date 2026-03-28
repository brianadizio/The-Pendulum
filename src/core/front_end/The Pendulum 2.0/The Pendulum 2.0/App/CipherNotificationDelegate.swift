//
//  CipherNotificationDelegate.swift
//  The Pendulum 2.0
//
//  Handles FCM token registration and cipher auth push notifications.
//

import UIKit
import FirebaseMessaging
import UserNotifications

class CipherNotificationDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    // MARK: - App Launch

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configure FCM
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
            if let error = error {
                print("[Cipher] Notification permission error: \(error)")
            }
        }

        return true
    }

    // MARK: - APNs Token

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("[Cipher] Failed to register for remote notifications: \(error)")
    }

    // MARK: - FCM Token

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("[Cipher] FCM token: \(token)")

        // Register token with Cipher API
        Task { @MainActor in
            let userId = CipherEnrollmentManager.shared.cipherUserId
            guard userId != "anonymous" else { return }
            try? await CipherAuthService.shared.registerDevice(userId: userId, fcmToken: token)
        }
    }

    // MARK: - Foreground Notification

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo

        // If it's a cipher challenge, show banner
        if userInfo["cipher_challenge_id"] != nil {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.banner, .sound])
        }
    }

    // MARK: - Notification Tapped

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        if let challengeId = userInfo["cipher_challenge_id"] as? String {
            // Post notification so the UI can present the auth level
            NotificationCenter.default.post(
                name: .cipherChallengeReceived,
                object: nil,
                userInfo: ["challengeId": challengeId]
            )
        } else if response.notification.request.identifier.hasPrefix("pendulum_progression_") {
            // Local progression notification tapped — show Nature sheet
            NotificationCenter.default.post(name: .progressionNotificationTapped, object: nil)
        }

        completionHandler()
    }

    // MARK: - Silent Push (Background)

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if userInfo["cipher_challenge_id"] != nil {
            // Challenge data received in background — UI will handle when foregrounded
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
}

// MARK: - Notification Name

extension Notification.Name {
    static let cipherChallengeReceived = Notification.Name("cipherChallengeReceived")
    static let cipherAuthResultReceived = Notification.Name("cipherAuthResultReceived")
    static let cipherAuthErrorOccurred = Notification.Name("cipherAuthErrorOccurred")
}
