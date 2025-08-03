import UIKit
import Foundation

// MARK: - PendulumViewController Export Extension

extension PendulumViewController {
    
    // MARK: - Properties
    
    // Add this property to PendulumViewController class:
    // var dataExporter: BalanceDataExporter?
    
    // MARK: - Export Setup
    
    func setupDataExporter() {
        if dataExporter == nil {
            dataExporter = BalanceDataExporter()
            print("📊 Balance data exporter initialized successfully")
        } else {
            print("📊 Balance data exporter already exists")
        }
        
        // Start recording when game starts
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGameStartForRecording),
            name: Notification.Name("GameStarted"),
            object: nil
        )
        
        // Stop recording when game stops
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGameStopForRecording),
            name: Notification.Name("GameStopped"),
            object: nil
        )
        
        // Handle memory warnings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataMemoryWarning(_:)),
            name: Notification.Name("BalanceDataMemoryWarning"),
            object: nil
        )
        
        // Listen for balance snapshot recording
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBalanceSnapshot(_:)),
            name: Notification.Name("RecordBalanceSnapshot"),
            object: nil
        )
    }
    
    // MARK: - Recording Control
    
    @objc private func handleGameStartForRecording() {
        dataExporter?.startRecording()
        print("Balance data recording started")
    }
    
    @objc private func handleGameStopForRecording() {
        dataExporter?.stopRecording()
        print("Balance data recording stopped")
    }
    
    @objc private func handleDataMemoryWarning(_ notification: Notification) {
        guard let count = notification.userInfo?["count"] as? Int else { return }
        
        // Show a subtle warning
        let warningMessage = "Recording buffer nearing capacity (\(count) samples)"
        updateGameMessageLabel(warningMessage)
        
        // Optionally auto-save or prompt user
        if count > 35000 {
            // Could auto-present export or just continue with circular buffer
            print("Balance data buffer at maximum capacity - using circular buffer")
        }
    }
    
    @objc private func handleBalanceSnapshot(_ notification: Notification) {
        guard let dataExporter = dataExporter else {
            print("📊 Balance snapshot ignored - no data exporter")
            return
        }
        
        guard dataExporter.isRecording else {
            print("📊 Balance snapshot ignored - not recording")
            return
        }
        
        guard let state = notification.userInfo?["state"] as? PendulumState else {
            print("📊 Balance snapshot ignored - no state in notification")
            return
        }
        
        dataExporter.recordSnapshot(state: state)
    }
    
    // MARK: - Recording Integration
    
    func recordCurrentState() {
        guard let dataExporter = dataExporter else { return }
        
        let state = viewModel.currentState
        dataExporter.recordSnapshot(state: state)
    }
    
    func recordPushAction(direction: PushDirection, magnitude: Double) {
        guard let dataExporter = dataExporter else { return }
        
        let state = viewModel.currentState
        dataExporter.recordSnapshot(state: state, action: direction, magnitude: magnitude)
    }
    
    // MARK: - Export UI
    
    func presentExportViewController() {
        // Stop any active recording
        dataExporter?.stopRecording()
        
        // Create and configure export view controller
        let exportVC = ExportViewController()
        exportVC.exporter = dataExporter  // Pass the existing data exporter
        exportVC.modalPresentationStyle = .pageSheet
        
        // Configure for iPad
        if let sheet = exportVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        
        // For iPad popover presentation
        if let popover = exportVC.popoverPresentationController {
            // Position relative to AI button if available
            if let aiButton = view.viewWithTag(1002) {
                popover.sourceView = aiButton
                popover.sourceRect = aiButton.bounds
            } else {
                popover.sourceView = view
                popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.minY + 100, width: 0, height: 0)
            }
            popover.permittedArrowDirections = [.up, .down]
        }
        
        present(exportVC, animated: true) { [weak self] in
            // Update UI to show export is available
            self?.updateGameMessageLabel("Export your balance signature to ground AI responses")
        }
    }
    
    // MARK: - Integration Points
    
    func integrateDataRecording() {
        // This method should be called from appropriate places in PendulumViewController
        
        // 1. In viewDidLoad:
        // setupDataExporter()
        
        // 2. In the physics update loop (wherever pendulum state updates):
        // recordCurrentState()
        
        // 3. In pushLeftButtonTapped:
        // recordPushAction(direction: .left, magnitude: 2.0)
        
        // 4. In pushRightButtonTapped:
        // recordPushAction(direction: .right, magnitude: 2.0)
        
        // 5. When viewModel.applyForce is called:
        // let direction: PushDirection = force > 0 ? .left : .right
        // recordPushAction(direction: direction, magnitude: abs(force))
    }
}

// MARK: - ViewModel Integration

extension PendulumViewModel {
    
    /// Override or extend applyForce to record push actions
    func applyForceWithRecording(_ force: Double) {
        // Apply the force
        applyForce(force)
        
        // Notify for recording
        let direction: PushDirection = force > 0 ? .left : .right
        NotificationCenter.default.post(
            name: Notification.Name("PendulumPushAction"),
            object: nil,
            userInfo: [
                "direction": direction,
                "magnitude": abs(force),
                "state": currentState
            ]
        )
    }
}

// MARK: - ExportViewController Core Data Integration

extension ExportViewController {
    
    /// Save export data to Core Data for persistence
    func saveExportToCoreData(package: BalanceDataExporter.ExportPackage) {
        // This would integrate with your Core Data model
        // For now, just save to documents directory
        
        // You could create a Core Data entity like:
        // BalanceSession
        // - sessionId: String
        // - timestamp: Date
        // - personalityData: Data (JSON encoded personality)
        // - csvPath: String
        // - analysisPath: String
        // - level: Int32
        // - duration: Double
    }
}