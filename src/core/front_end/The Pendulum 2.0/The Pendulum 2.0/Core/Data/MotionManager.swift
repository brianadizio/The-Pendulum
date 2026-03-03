// MotionManager.swift
// The Pendulum 2.0
// CoreMotion capture for Golden Cipher — separate _motion.csv per session

import Foundation
import CoreMotion

class MotionManager {
    static let shared = MotionManager()

    // MARK: - Properties

    private let motionManager = CMMotionManager()
    private var fileHandle: FileHandle?
    private(set) var motionFilePath: URL?
    private(set) var isCapturing: Bool = false

    // Write buffer — 50 rows (~0.5s at 100 Hz)
    private var writeBuffer: [String] = []
    private let writeBufferSize: Int = 50

    private var sessionStartTime: Date?

    // MARK: - Init

    private init() {}

    // MARK: - Sessions Directory

    private var sessionsDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let sessionsPath = documentsPath.appendingPathComponent("Sessions", isDirectory: true)
        if !FileManager.default.fileExists(atPath: sessionsPath.path) {
            try? FileManager.default.createDirectory(at: sessionsPath, withIntermediateDirectories: true)
        }
        return sessionsPath
    }

    // MARK: - Capture Control

    /// Start capturing device motion data for a session.
    /// Graceful no-op on Simulator or devices without motion hardware.
    func startCapture(sessionId: String) {
        guard !isCapturing else { return }
        guard motionManager.isDeviceMotionAvailable else {
            print("MotionManager: Device motion not available (Simulator?)")
            return
        }

        sessionStartTime = Date()

        // Create motion CSV file
        let filePath = sessionsDirectory.appendingPathComponent("session_\(sessionId)_motion.csv")
        motionFilePath = filePath

        let header = "timestamp,accelX,accelY,accelZ,gyroX,gyroY,gyroZ,pitch,roll,yaw\n"
        do {
            try header.write(to: filePath, atomically: true, encoding: .utf8)
            fileHandle = try FileHandle(forWritingTo: filePath)
            fileHandle?.seekToEndOfFile()
        } catch {
            print("MotionManager: Error creating motion CSV: \(error)")
            return
        }

        isCapturing = true
        writeBuffer.removeAll()

        // Configure 100 Hz update interval
        motionManager.deviceMotionUpdateInterval = 1.0 / 100.0

        motionManager.startDeviceMotionUpdates(to: OperationQueue()) { [weak self] motion, error in
            guard let self = self, let motion = motion, let startTime = self.sessionStartTime else { return }

            let timestamp = Date().timeIntervalSince(startTime)
            let accel = motion.userAcceleration  // Gravity removed
            let gyro = motion.rotationRate
            let attitude = motion.attitude

            let row = String(format: "%.4f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n",
                            timestamp,
                            accel.x, accel.y, accel.z,
                            gyro.x, gyro.y, gyro.z,
                            attitude.pitch, attitude.roll, attitude.yaw)

            self.bufferWrite(row)
        }

        print("MotionManager: Started capture for session \(sessionId)")
    }

    /// Stop capturing and flush remaining data.
    /// Returns the file URL of the motion CSV (nil if capture was not active).
    @discardableResult
    func stopCapture() -> URL? {
        guard isCapturing else { return nil }

        motionManager.stopDeviceMotionUpdates()
        flushWriteBuffer()
        fileHandle?.closeFile()
        fileHandle = nil
        isCapturing = false
        sessionStartTime = nil

        let path = motionFilePath
        print("MotionManager: Stopped capture")
        return path
    }

    // MARK: - Write Buffer

    private func bufferWrite(_ row: String) {
        writeBuffer.append(row)
        if writeBuffer.count >= writeBufferSize {
            flushWriteBuffer()
        }
    }

    private func flushWriteBuffer() {
        guard !writeBuffer.isEmpty, let handle = fileHandle else { return }
        let combined = writeBuffer.joined()
        if let data = combined.data(using: .utf8) {
            handle.write(data)
        }
        writeBuffer.removeAll(keepingCapacity: true)
    }
}
