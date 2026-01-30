// HealthKitManager.swift
// The Pendulum 2.0
// Singleton manager for Apple Health integration

import Foundation
import HealthKit
import Combine
import UIKit

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    // MARK: - Published Properties

    @Published private(set) var authorizationStatus: HealthAuthorizationStatus = .notDetermined
    @Published private(set) var lastSyncDate: Date?
    @Published private(set) var latestHealthSnapshot: HealthSnapshot?
    @Published private(set) var isSyncing: Bool = false

    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }

    // MARK: - Private Properties

    private let healthStore = HKHealthStore()
    private var cancellables = Set<AnyCancellable>()

    // UserDefaults keys
    private enum Keys {
        static let lastSyncDate = "healthkit_last_sync_date"
        static let authorizationStatus = "healthkit_authorization_status"
        static let cachedSnapshot = "healthkit_cached_snapshot"
    }

    // MARK: - Health Types

    /// Types we want to read from HealthKit
    private var typesToRead: Set<HKObjectType> {
        var types: Set<HKObjectType> = []

        if let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            types.insert(stepType)
        }
        if let hrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) {
            types.insert(hrType)
        }
        if let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            types.insert(hrvType)
        }
        if let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepType)
        }
        if let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            types.insert(calorieType)
        }

        return types
    }

    /// Types we want to write to HealthKit
    private var typesToWrite: Set<HKSampleType> {
        var types: Set<HKSampleType> = []

        if let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) {
            types.insert(mindfulType)
        }

        return types
    }

    // MARK: - Initialization

    private init() {
        loadCachedData()
        checkInitialAuthorizationStatus()
        setupForegroundSync()
    }

    /// Auto-sync health data when the app comes to foreground
    private func setupForegroundSync() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                guard let self = self, self.isAuthorized else { return }
                Task {
                    await self.syncHealthData()
                }
            }
            .store(in: &cancellables)
    }

    private func loadCachedData() {
        lastSyncDate = UserDefaults.standard.object(forKey: Keys.lastSyncDate) as? Date

        if let data = UserDefaults.standard.data(forKey: Keys.cachedSnapshot),
           let snapshot = try? JSONDecoder().decode(HealthSnapshot.self, from: data) {
            latestHealthSnapshot = snapshot
        }
    }

    private func checkInitialAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            authorizationStatus = .unavailable
            return
        }

        // Check if we've previously authorized (stored state)
        if UserDefaults.standard.bool(forKey: Keys.authorizationStatus) {
            authorizationStatus = .authorized
        }
    }

    // MARK: - Authorization

    /// Check if HealthKit is available on this device
    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    /// Request authorization to access HealthKit data
    func requestAuthorization() async throws -> Bool {
        guard isHealthKitAvailable else {
            await MainActor.run {
                authorizationStatus = .unavailable
            }
            return false
        }

        do {
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)

            // Check if we can at least write mindfulness (indicates user granted some permission)
            if let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) {
                let writeStatus = healthStore.authorizationStatus(for: mindfulType)

                await MainActor.run {
                    if writeStatus == .sharingAuthorized {
                        authorizationStatus = .authorized
                        UserDefaults.standard.set(true, forKey: Keys.authorizationStatus)
                    } else if writeStatus == .sharingDenied {
                        authorizationStatus = .denied
                        UserDefaults.standard.set(false, forKey: Keys.authorizationStatus)
                    }
                }

                // If authorized, trigger initial sync
                if writeStatus == .sharingAuthorized {
                    await syncHealthData()
                }

                return writeStatus == .sharingAuthorized
            }

            return false
        } catch {
            print("HealthKit authorization error: \(error.localizedDescription)")
            await MainActor.run {
                authorizationStatus = .denied
            }
            throw error
        }
    }

    /// Disconnect from HealthKit (clears local state, user must revoke in Settings)
    func disconnect() {
        UserDefaults.standard.set(false, forKey: Keys.authorizationStatus)
        UserDefaults.standard.removeObject(forKey: Keys.lastSyncDate)
        UserDefaults.standard.removeObject(forKey: Keys.cachedSnapshot)

        authorizationStatus = .notDetermined
        lastSyncDate = nil
        latestHealthSnapshot = nil
    }

    // MARK: - Write: Mindfulness Sessions

    /// Log a gameplay session as a mindfulness session in HealthKit
    func logMindfulnessSession(startDate: Date, endDate: Date) async throws {
        guard isAuthorized else {
            print("HealthKit not authorized, skipping mindfulness log")
            return
        }

        guard let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else {
            print("Mindful session type not available")
            return
        }

        let mindfulSample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: startDate,
            end: endDate
        )

        do {
            try await healthStore.save(mindfulSample)
            print("Successfully logged mindfulness session: \(Int(endDate.timeIntervalSince(startDate) / 60)) minutes")
        } catch {
            print("Failed to log mindfulness session: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Read: Health Metrics

    /// Fetch step count for a given date
    func fetchSteps(for date: Date) async throws -> Int {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return 0
        }

        let (startOfDay, endOfDay) = dayBounds(for: date)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                continuation.resume(returning: Int(steps))
            }

            healthStore.execute(query)
        }
    }

    /// Fetch resting heart rate for a given date
    func fetchRestingHeartRate(for date: Date) async throws -> Double? {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            return nil
        }

        let (startOfDay, endOfDay) = dayBounds(for: date)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: hrType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let hr = result?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                continuation.resume(returning: hr)
            }

            healthStore.execute(query)
        }
    }

    /// Fetch heart rate variability (SDNN) for a given date
    func fetchHeartRateVariability(for date: Date) async throws -> Double? {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            return nil
        }

        let (startOfDay, endOfDay) = dayBounds(for: date)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: hrvType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let hrv = result?.averageQuantity()?.doubleValue(for: HKUnit.secondUnit(with: .milli))
                continuation.resume(returning: hrv)
            }

            healthStore.execute(query)
        }
    }

    /// Fetch sleep duration for a given date (previous night)
    func fetchSleepDuration(for date: Date) async throws -> TimeInterval? {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
            return nil
        }

        // For sleep, look at the night before (6PM previous day to 12PM current day)
        let calendar = Calendar.current
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date)!
        let previousEvening = calendar.date(byAdding: .hour, value: -18, to: noon)!

        let predicate = HKQuery.predicateForSamples(withStart: previousEvening, end: noon, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: nil)
                    return
                }

                // Sum up asleep time (filter out "in bed" samples)
                let totalSleep = samples
                    .filter { $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                              $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                              $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                              $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }

                continuation.resume(returning: totalSleep > 0 ? totalSleep : nil)
            }

            healthStore.execute(query)
        }
    }

    /// Fetch active calories burned for a given date
    func fetchActiveCalories(for date: Date) async throws -> Double? {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return nil
        }

        let (startOfDay, endOfDay) = dayBounds(for: date)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: calorieType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let calories = result?.sumQuantity()?.doubleValue(for: .kilocalorie())
                continuation.resume(returning: calories)
            }

            healthStore.execute(query)
        }
    }

    /// Fetch mindfulness minutes logged today
    func fetchMindfulnessMinutes(for date: Date) async throws -> Int {
        guard let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else {
            return 0
        }

        let (startOfDay, endOfDay) = dayBounds(for: date)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: mindfulType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0)
                    return
                }

                let totalMinutes = samples.reduce(0) { total, sample in
                    total + Int(sample.endDate.timeIntervalSince(sample.startDate) / 60)
                }

                continuation.resume(returning: totalMinutes)
            }

            healthStore.execute(query)
        }
    }

    // MARK: - Batch Operations

    /// Fetch all health metrics for today as a snapshot
    func fetchDailyHealthSnapshot() async throws -> HealthSnapshot {
        let today = Date()

        async let steps = try? fetchSteps(for: today)
        async let hr = try? fetchRestingHeartRate(for: today)
        async let hrv = try? fetchHeartRateVariability(for: today)
        async let sleep = try? fetchSleepDuration(for: today)
        async let calories = try? fetchActiveCalories(for: today)
        async let mindful = try? fetchMindfulnessMinutes(for: today)

        let snapshot = HealthSnapshot(
            date: today,
            steps: await steps,
            restingHeartRate: await hr,
            heartRateVariability: await hrv,
            sleepDuration: await sleep,
            activeCalories: await calories,
            mindfulMinutesLogged: await mindful ?? 0
        )

        return snapshot
    }

    /// Sync health data and update cached snapshot
    func syncHealthData() async {
        guard isAuthorized else { return }

        await MainActor.run {
            isSyncing = true
        }

        do {
            let snapshot = try await fetchDailyHealthSnapshot()

            await MainActor.run {
                latestHealthSnapshot = snapshot
                lastSyncDate = Date()
                isSyncing = false

                // Cache the snapshot
                if let data = try? JSONEncoder().encode(snapshot) {
                    UserDefaults.standard.set(data, forKey: Keys.cachedSnapshot)
                }
                UserDefaults.standard.set(lastSyncDate, forKey: Keys.lastSyncDate)
            }
        } catch {
            print("Failed to sync health data: \(error.localizedDescription)")
            await MainActor.run {
                isSyncing = false
            }
        }
    }

    // MARK: - Helpers

    private func dayBounds(for date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return (startOfDay, endOfDay)
    }
}
