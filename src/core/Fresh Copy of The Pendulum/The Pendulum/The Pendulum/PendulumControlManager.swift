import UIKit
import CoreMotion
import SpriteKit

/// Manages all control types for The Pendulum game
class PendulumControlManager: NSObject {
    
    // MARK: - Properties
    
    weak var viewModel: PendulumViewModel?
    weak var parentView: UIView?
    weak var scene: PendulumScene?
    
    // Push buttons to manage visibility
    weak var pushLeftButton: UIButton?
    weak var pushRightButton: UIButton?
    
    // Control type
    var currentControlType: ControlType = .push {
        didSet {
            setupControlType()
            saveControlPreference()
        }
    }
    
    // Control sensitivity (0.1 to 1.0)
    var sensitivity: Double = 0.5 {
        didSet {
            UserDefaults.standard.set(sensitivity, forKey: "controlSensitivity")
        }
    }
    
    // Motion manager for gyroscope and tilt controls
    private let motionManager = CMMotionManager()
    private var motionUpdateTimer: Timer?
    
    // UI Elements for different control types
    private var sliderControl: UISlider?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var swipeLeftGesture: UISwipeGestureRecognizer?
    private var swipeRightGesture: UISwipeGestureRecognizer?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    
    // Instruction labels to track and remove
    private var instructionLabels: [UILabel] = []
    
    // Control state
    private var isMotionActive = false
    private var lastSliderValue: Float = 0.5
    private var motionBaseline: CMAttitude?
    
    // Control session tracking
    private var currentSessionId: UUID?
    private var sessionStartTime: Date?
    private var forceApplicationCount = 0
    private var totalForceApplied: Double = 0
    
    // MARK: - Control Types
    
    enum ControlType: String, CaseIterable {
        case push = "Push"
        case slider = "Slider"
        case gyroscope = "Gyroscope"
        case swipe = "Swipe"
        case tilt = "Tilt"
        case tap = "Tap"
        
        var displayName: String {
            return rawValue
        }
        
        var description: String {
            switch self {
            case .push:
                return "Push the pendulum with touch buttons"
            case .slider:
                return "Slide finger to apply continuous force"
            case .gyroscope:
                return "Tilt device to control pendulum motion"
            case .swipe:
                return "Swipe gestures for impulse control"
            case .tilt:
                return "Tilt device to change gravity direction"
            case .tap:
                return "Tap screen areas to apply directional force"
            }
        }
        
        var requiresMotion: Bool {
            return self == .gyroscope || self == .tilt
        }
        
        var icon: String {
            switch self {
            case .push:
                return "hand.tap"
            case .slider:
                return "slider.horizontal.3"
            case .gyroscope:
                return "gyroscope"
            case .swipe:
                return "hand.draw"
            case .tilt:
                return "iphone.landscape"
            case .tap:
                return "hand.point.up"
            }
        }
    }
    
    // MARK: - Initialization
    
    init(viewModel: PendulumViewModel, parentView: UIView, scene: PendulumScene? = nil, pushLeftButton: UIButton? = nil, pushRightButton: UIButton? = nil) {
        super.init()
        self.viewModel = viewModel
        self.parentView = parentView
        self.scene = scene
        self.pushLeftButton = pushLeftButton
        self.pushRightButton = pushRightButton
        
        // Load saved preferences
        loadControlPreferences()
        
        // Setup initial control type
        setupControlType()
        
        // Setup motion manager
        setupMotionManager()
    }
    
    deinit {
        stopMotionUpdates()
        removeAllGestureRecognizers()
    }
    
    // MARK: - Control Setup
    
    private func setupControlType() {
        // Remove previous control UI
        removeAllControlUI()
        
        // Stop motion updates
        stopMotionUpdates()
        
        // Start new session
        startControlSession()
        
        // Hide push buttons by default
        pushLeftButton?.isHidden = true
        pushRightButton?.isHidden = true
        
        // Setup new control type
        switch currentControlType {
        case .push:
            setupPushControls()
        case .slider:
            setupSliderControl()
        case .swipe:
            setupSwipeControls()
        case .gyroscope:
            setupGyroscopeControl()
        case .tilt:
            setupTiltControl()
        case .tap:
            setupTapControl()
        }
    }
    
    // MARK: - Push Controls
    
    private func setupPushControls() {
        // Show push buttons
        pushLeftButton?.isHidden = false
        pushRightButton?.isHidden = false
        print("Push controls active - using existing button system")
    }
    
    // MARK: - Slider Control
    
    private func setupSliderControl() {
        guard let parentView = parentView else { return }
        
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.value = 0.5 // Center position
        slider.isContinuous = true
        
        // Golden Theme styling
        slider.minimumTrackTintColor = .goldenPrimary
        slider.maximumTrackTintColor = .goldenSecondary
        slider.thumbTintColor = .goldenAccent
        
        // Add target
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchEnded(_:)), for: [.touchUpInside, .touchUpOutside])
        
        parentView.addSubview(slider)
        
        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 40),
            slider.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -40),
            slider.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            slider.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        sliderControl = slider
        lastSliderValue = 0.5
        
        // Add instruction label
        addInstructionLabel(text: "Slide to control pendulum force", below: slider)
    }
    
    @objc private func sliderValueChanged(_ slider: UISlider) {
        let centerValue: Float = 0.5
        let delta = slider.value - centerValue
        let force = Double(delta) * 4.0 * sensitivity // Scale force
        
        // Apply force if there's significant change
        if abs(slider.value - lastSliderValue) > 0.02 {
            applyControlForce(force, controlData: [
                "sliderValue": slider.value,
                "deltaFromCenter": delta,
                "deltaFromPrevious": slider.value - lastSliderValue
            ])
            lastSliderValue = slider.value
        }
    }
    
    @objc private func sliderTouchEnded(_ slider: UISlider) {
        // Reset slider to center when touch ends
        UIView.animate(withDuration: 0.3) {
            slider.value = 0.5
        }
        lastSliderValue = 0.5
    }
    
    // MARK: - Gyroscope Control
    
    private func setupGyroscopeControl() {
        guard motionManager.isGyroAvailable else {
            showControlError("Gyroscope not available on this device")
            return
        }
        
        addInstructionLabel(text: "Tilt device left/right to control pendulum")
        calibrateGyroscope()
        startMotionUpdates()
    }
    
    private func calibrateGyroscope() {
        guard let parentView = parentView else { return }
        
        // Show calibration UI
        let calibrationLabel = UILabel()
        calibrationLabel.text = "Hold device level and tap to calibrate"
        calibrationLabel.textAlignment = .center
        calibrationLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        calibrationLabel.textColor = .goldenDark
        calibrationLabel.backgroundColor = UIColor.goldenBackground.withAlphaComponent(0.95)
        calibrationLabel.layer.cornerRadius = 12
        calibrationLabel.layer.borderWidth = 1
        calibrationLabel.layer.borderColor = UIColor.goldenPrimary.withAlphaComponent(0.3).cgColor
        calibrationLabel.clipsToBounds = true
        calibrationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        parentView.addSubview(calibrationLabel)
        
        NSLayoutConstraint.activate([
            calibrationLabel.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            calibrationLabel.centerYAnchor.constraint(equalTo: parentView.centerYAnchor),
            calibrationLabel.widthAnchor.constraint(equalToConstant: 280),
            calibrationLabel.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Add tap gesture for calibration
        let calibrateTap = UITapGestureRecognizer(target: self, action: #selector(calibrateMotion))
        calibrationLabel.addGestureRecognizer(calibrateTap)
        calibrationLabel.isUserInteractionEnabled = true
        
        // Remove after 5 seconds if not calibrated
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            calibrationLabel.removeFromSuperview()
        }
    }
    
    @objc private func calibrateMotion() {
        if motionManager.isDeviceMotionAvailable {
            motionBaseline = motionManager.deviceMotion?.attitude
            showControlMessage("Calibrated! Tilt to control.")
        }
    }
    
    // MARK: - Swipe Controls
    
    private func setupSwipeControls() {
        guard let parentView = parentView else { return }
        
        // Left swipe gesture
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        parentView.addGestureRecognizer(swipeLeft)
        swipeLeftGesture = swipeLeft
        
        // Right swipe gesture
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        parentView.addGestureRecognizer(swipeRight)
        swipeRightGesture = swipeRight
        
        addInstructionLabel(text: "Swipe left or right to apply impulse force")
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let baseForce = 3.0 * sensitivity
        let force = gesture.direction == .left ? -baseForce : baseForce
        
        applyControlForce(force, controlData: [
            "direction": gesture.direction == .left ? "left" : "right",
            "swipeType": "impulse"
        ])
        
        // Visual feedback
        showControlMessage(gesture.direction == .left ? "← Left Swipe" : "Right Swipe →")
    }
    
    // MARK: - Tilt Control
    
    private func setupTiltControl() {
        guard motionManager.isDeviceMotionAvailable else {
            showControlError("Device motion not available")
            return
        }
        
        addInstructionLabel(text: "Tilt device to change gravity direction")
        startMotionUpdates()
    }
    
    // MARK: - Tap Control
    
    private func setupTapControl() {
        guard let parentView = parentView else { return }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        parentView.addGestureRecognizer(tapGesture)
        tapGestureRecognizer = tapGesture
        
        addInstructionLabel(text: "Tap left or right side of screen to apply force")
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let parentView = parentView else { return }
        
        let location = gesture.location(in: parentView)
        let screenCenter = parentView.bounds.width / 2
        let force = location.x < screenCenter ? 2.0 * sensitivity : -2.0 * sensitivity
        let side = location.x < screenCenter ? "left" : "right"
        
        applyControlForce(force, controlData: [
            "tapLocation": ["x": location.x, "y": location.y],
            "side": side,
            "distanceFromCenter": abs(location.x - screenCenter)
        ])
        
        // Visual feedback
        showControlMessage(side == "left" ? "← Left Tap" : "Right Tap →")
    }
    
    // MARK: - Motion Updates
    
    private func setupMotionManager() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60Hz
        motionManager.gyroUpdateInterval = 1.0 / 60.0
    }
    
    private func startMotionUpdates() {
        guard currentControlType.requiresMotion else { return }
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates()
            
            motionUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
                self?.processMotionData()
            }
            
            isMotionActive = true
        }
    }
    
    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
        motionUpdateTimer?.invalidate()
        motionUpdateTimer = nil
        isMotionActive = false
    }
    
    private func processMotionData() {
        guard let motion = motionManager.deviceMotion else { return }
        
        switch currentControlType {
        case .gyroscope:
            processGyroscopeData(motion)
        case .tilt:
            processTiltData(motion)
        default:
            break
        }
    }
    
    private func processGyroscopeData(_ motion: CMDeviceMotion) {
        let rotationRate = motion.rotationRate
        let force = rotationRate.z * sensitivity * 2.0 // Use Z-axis rotation
        
        // Apply force if rotation is significant
        if abs(force) > 0.1 {
            applyControlForce(force, controlData: [
                "rotationRate": ["x": rotationRate.x, "y": rotationRate.y, "z": rotationRate.z],
                "attitude": ["pitch": motion.attitude.pitch, "roll": motion.attitude.roll, "yaw": motion.attitude.yaw]
            ])
        }
    }
    
    private func processTiltData(_ motion: CMDeviceMotion) {
        let roll = motion.attitude.roll
        let force = roll * sensitivity * 1.5 // Use device roll
        
        // Apply force based on tilt
        if abs(force) > 0.05 {
            applyControlForce(force, controlData: [
                "tiltAngle": roll,
                "gravity": ["x": motion.gravity.x, "y": motion.gravity.y, "z": motion.gravity.z]
            ])
        }
    }
    
    // MARK: - Force Application
    
    private func applyControlForce(_ force: Double, controlData: [String: Any] = [:]) {
        // Apply force to view model
        viewModel?.applyForce(force)
        
        // Track force application
        forceApplicationCount += 1
        totalForceApplied += abs(force)
        
        // Record control input for analytics
        recordControlInput(force: force, controlData: controlData)
    }
    
    // MARK: - Control Session Management
    
    private func startControlSession() {
        endControlSession() // End previous session if any
        
        currentSessionId = UUID()
        sessionStartTime = Date()
        forceApplicationCount = 0
        totalForceApplied = 0
        
        print("Started control session: \(currentSessionId?.uuidString ?? "unknown") with \(currentControlType.rawValue)")
    }
    
    private func endControlSession() {
        guard let sessionId = currentSessionId,
              let startTime = sessionStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        let averageForce = forceApplicationCount > 0 ? totalForceApplied / Double(forceApplicationCount) : 0
        
        // Save session data to Core Data
        saveControlSession(
            sessionId: sessionId,
            controlType: currentControlType,
            duration: duration,
            forceApplications: forceApplicationCount,
            averageForce: averageForce
        )
        
        print("Ended control session: \(sessionId.uuidString) - Duration: \(duration)s, Forces: \(forceApplicationCount)")
        
        currentSessionId = nil
        sessionStartTime = nil
    }
    
    // MARK: - UI Helpers
    
    private func addInstructionLabel(text: String, below view: UIView? = nil) {
        guard let parentView = parentView else { return }
        
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .goldenTextLight
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        parentView.addSubview(label)
        instructionLabels.append(label) // Track for removal
        
        if let belowView = view {
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: belowView.bottomAnchor, constant: 8),
                label.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20)
            ])
        } else {
            // Position in the simulation area, where push buttons normally appear
            NSLayoutConstraint.activate([
                label.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -350),
                label.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20)
            ])
        }
    }
    
    private func showControlMessage(_ message: String) {
        // TODO: Show temporary message to user
        print("Control: \(message)")
    }
    
    private func showControlError(_ error: String) {
        print("Control Error: \(error)")
        // Fallback to push controls
        currentControlType = .push
    }
    
    // MARK: - Cleanup
    
    private func removeAllControlUI() {
        // Remove slider
        sliderControl?.removeFromSuperview()
        sliderControl = nil
        
        // Remove all gesture recognizers
        removeAllGestureRecognizers()
        
        // Remove all instruction labels
        instructionLabels.forEach { $0.removeFromSuperview() }
        instructionLabels.removeAll()
        
        // Remove any calibration UI elements
        parentView?.subviews.forEach { view in
            if view.layer.cornerRadius == 8 && view.backgroundColor == UIColor.systemBackground.withAlphaComponent(0.9) {
                view.removeFromSuperview()
            }
        }
    }
    
    private func removeAllGestureRecognizers() {
        if let tapGesture = tapGestureRecognizer {
            parentView?.removeGestureRecognizer(tapGesture)
            tapGestureRecognizer = nil
        }
        
        if let swipeLeft = swipeLeftGesture {
            parentView?.removeGestureRecognizer(swipeLeft)
            swipeLeftGesture = nil
        }
        
        if let swipeRight = swipeRightGesture {
            parentView?.removeGestureRecognizer(swipeRight)
            swipeRightGesture = nil
        }
        
        if let panGesture = panGestureRecognizer {
            parentView?.removeGestureRecognizer(panGesture)
            panGestureRecognizer = nil
        }
    }
    
    // MARK: - Preferences
    
    private func loadControlPreferences() {
        if let savedControlType = UserDefaults.standard.string(forKey: "selectedControlType"),
           let controlType = ControlType(rawValue: savedControlType) {
            currentControlType = controlType
        }
        
        sensitivity = UserDefaults.standard.double(forKey: "controlSensitivity")
        if sensitivity == 0 {
            sensitivity = 0.5 // Default
        }
    }
    
    private func saveControlPreference() {
        UserDefaults.standard.set(currentControlType.rawValue, forKey: "selectedControlType")
    }
    
    // MARK: - Public Methods
    
    func switchToControlType(_ controlType: ControlType) {
        currentControlType = controlType
    }
    
    func updateSensitivity(_ newSensitivity: Double) {
        sensitivity = max(0.1, min(1.0, newSensitivity))
    }
    
    func getCurrentControlInfo() -> (type: ControlType, sensitivity: Double, isActive: Bool) {
        return (currentControlType, sensitivity, currentSessionId != nil)
    }
    
    // MARK: - Data Recording (Placeholder methods - implement with Core Data)
    
    private func recordControlInput(force: Double, controlData: [String: Any]) {
        // TODO: Implement Core Data recording
        let inputData = [
            "controlType": currentControlType.rawValue,
            "force": force,
            "timestamp": Date(),
            "controlData": controlData
        ] as [String : Any]
        
        print("Recording control input: \(inputData)")
    }
    
    private func saveControlSession(sessionId: UUID, controlType: ControlType, duration: TimeInterval, forceApplications: Int, averageForce: Double) {
        // TODO: Implement Core Data session saving
        print("Saving control session - Type: \(controlType.rawValue), Duration: \(duration), Applications: \(forceApplications)")
    }
}

// MARK: - Extensions

extension PendulumControlManager {
    
    /// Get available control types for the current device
    static func getAvailableControlTypes() -> [ControlType] {
        var availableTypes: [ControlType] = [.push, .slider, .swipe, .tap]
        
        // Check for motion availability
        let motionManager = CMMotionManager()
        if motionManager.isDeviceMotionAvailable || motionManager.isGyroAvailable {
            availableTypes.append(.gyroscope)
            availableTypes.append(.tilt)
        } else {
            // Enable for testing even if motion isn't detected (useful in simulator)
            #if DEBUG
            availableTypes.append(.gyroscope)
            availableTypes.append(.tilt)
            #endif
        }
        
        return availableTypes
    }
    
    /// Check if a control type requires special permissions
    static func requiresPermission(_ controlType: ControlType) -> Bool {
        return controlType.requiresMotion
    }
}