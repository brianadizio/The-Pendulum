// ProgressionNotificationManager.swift
// The Pendulum 2.0
// Schedules local notifications for the multi-day progression funnel

import UserNotifications

enum ProgressionNotificationManager {

  /// Schedule a reminder for the next play day (called when Nature sheet is dismissed)
  static func scheduleNextDayReminder() {
    let currentDay = CSVSessionManager.currentPlayDay
    guard currentDay < 3 else { return } // No reminder after Day 3

    let nextDay = currentDay + 1

    let content = UNMutableNotificationContent()
    content.title = "Day \(nextDay): Balance Profile Update"
    content.body = nextDay == 2
      ? "Your balance profile is ready to update. See if your control strategy has shifted."
      : "Your 3-day vestibular profile is complete."
    content.sound = .default

    // Schedule for tomorrow at 10 AM local time
    var dateComponents = DateComponents()
    dateComponents.hour = 10
    dateComponents.minute = 0
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

    let request = UNNotificationRequest(
      identifier: "pendulum_progression_day\(nextDay)",
      content: content,
      trigger: trigger
    )

    // Remove any existing progression notifications first
    UNUserNotificationCenter.current().removePendingNotificationRequests(
      withIdentifiers: ["pendulum_progression_day2", "pendulum_progression_day3"]
    )

    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        print("[Progression] Failed to schedule notification: \(error)")
      } else {
        print("[Progression] Scheduled Day \(nextDay) reminder for 10 AM tomorrow")
      }
    }
  }
}
