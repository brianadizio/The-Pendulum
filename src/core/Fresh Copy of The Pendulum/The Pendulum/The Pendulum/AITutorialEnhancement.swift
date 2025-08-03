import UIKit
import Foundation

// MARK: - Enhanced Tutorial Mode for AI
extension PendulumAIManager {
    private var lastSuggestionTime: TimeInterval {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.lastSuggestionTime) as? TimeInterval ?? 0 }
        set { objc_setAssociatedObject(self, &AssociatedKeys.lastSuggestionTime, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    private struct AssociatedKeys {
        static var lastSuggestionTime = "lastSuggestionTime"
    }
    
    /// Enhanced tutorial mode that provides visual guidance
    func startEnhancedTutorial(viewModel: PendulumViewModel) {
        self.viewModel = viewModel
        self.currentMode = .tutorial
        tutorialStep = 0
        lastSuggestionTime = 0
        
        // Create a tutorial AI that suggests actions
        aiPlayer = PendulumAIPlayer(skillLevel: .expert)
        aiPlayer?.humanErrorEnabled = false
        
        // Set up enhanced callbacks for tutorial
        setupEnhancedTutorialCallbacks()
        
        // Start the AI analysis (but not playing)
        aiPlayer?.startPlaying()
        
        // Show initial tutorial message
        showTutorialMessage("Welcome to Tutorial Mode! Follow the AI's guidance to balance the pendulum.")
        
        // Start update loop
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateTutorialAI()
        }
    }
    
    private func setupEnhancedTutorialCallbacks() {
        // Tutorial mode: AI suggests but doesn't push
        // Add smarter filtering to avoid incorrect suggestions
        aiPlayer?.onPushLeft = { [weak self] in
            guard let self = self, self.shouldShowSuggestion(direction: .left) else { return }
            self.showTutorialSuggestion(direction: .left)
        }
        
        aiPlayer?.onPushRight = { [weak self] in
            guard let self = self, self.shouldShowSuggestion(direction: .right) else { return }
            self.showTutorialSuggestion(direction: .right)
        }
    }
    
    private func shouldShowSuggestion(direction: PushDirection) -> Bool {
        guard let viewModel = viewModel else { return false }
        let state = viewModel.currentState
        
        // Check if pendulum has fallen (past ±75 degrees from vertical)
        let normalizedAngle = atan2(sin(state.theta), cos(state.theta))
        let angleFromVertical = abs(normalizedAngle - Double.pi)
        
        if angleFromVertical > 1.309 { // 75 degrees in radians
            // Pendulum has fallen - don't suggest pushes
            return false
        }
        
        // Cooldown to prevent suggestion spam (minimum 0.8 seconds between suggestions)
        let currentTime = CACurrentMediaTime()
        if currentTime - lastSuggestionTime < 0.8 {
            return false
        }
        
        // Get angle from vertical (0 = upright, positive = tilting right)
        let angle = state.theta
        let velocity = state.thetaDot
        
        // Calculate where pendulum is heading
        let predictedAngle = angle + velocity * 0.2 // Look 0.2 seconds ahead
        
        // Minimum angle threshold to suggest a push (avoid over-suggesting)
        let minAngleThreshold = 0.15 // About 8.5 degrees
        
        // Smart logic:
        // - If tilting right (positive angle) and still moving right (positive velocity), suggest left push
        // - If tilting left (negative angle) and still moving left (negative velocity), suggest right push
        // - Consider predicted position to be proactive
        
        let shouldSuggest: Bool
        switch direction {
        case .left:
            // Suggest left push if pendulum is/will be tilting right
            shouldSuggest = predictedAngle > minAngleThreshold && velocity >= 0
        case .right:
            // Suggest right push if pendulum is/will be tilting left
            shouldSuggest = predictedAngle < -minAngleThreshold && velocity <= 0
        case .none:
            shouldSuggest = false
        }
        
        if shouldSuggest {
            lastSuggestionTime = currentTime
        }
        
        return shouldSuggest
    }
    
    private func updateTutorialAI() {
        guard let viewModel = viewModel,
              let aiPlayer = aiPlayer else { return }
        
        let state = viewModel.currentState
        
        // Update AI with current state
        aiPlayer.updatePendulumState(
            angle: state.theta,
            angleVelocity: state.thetaDot,
            time: state.time
        )
        
        // Enhanced tutorial progress tracking
        checkEnhancedTutorialProgress(state: state)
    }
    
    private func showTutorialSuggestion(direction: PushDirection) {
        // Send enhanced notification with visual cues
        NotificationCenter.default.post(
            name: Notification.Name("AITutorialSuggestion"),
            object: nil,
            userInfo: [
                "direction": direction,
                "urgency": getUrgencyLevel()
            ]
        )
    }
    
    private func getUrgencyLevel() -> String {
        guard let viewModel = viewModel else { return "normal" }
        let angleFromVertical = abs(atan2(sin(viewModel.currentState.theta), cos(viewModel.currentState.theta)) - Double.pi)
        
        if angleFromVertical > 1.0 {
            return "urgent"
        } else if angleFromVertical > 0.5 {
            return "important"
        } else {
            return "normal"
        }
    }
    
    private func checkEnhancedTutorialProgress(state: PendulumState) {
        let angleFromVertical = abs(atan2(sin(state.theta), cos(state.theta)) - Double.pi)
        
        switch tutorialStep {
        case 0:
            // Step 1: Get pendulum somewhat upright
            if angleFromVertical < 0.5 {
                tutorialStep = 1
                showTutorialMessage("Good! Now try to get it more vertical. Watch for the push hints!")
                NotificationCenter.default.post(name: Notification.Name("TutorialProgressUpdate"), object: nil, userInfo: ["step": 1])
            }
        case 1:
            // Step 2: Get pendulum nearly vertical
            if angleFromVertical < 0.35 {  // Match level 1 threshold
                tutorialStep = 2
                showTutorialMessage("Excellent! Now maintain balance briefly.")
                trackBalanceTime()
                NotificationCenter.default.post(name: Notification.Name("TutorialProgressUpdate"), object: nil, userInfo: ["step": 2])
            }
        case 2:
            // Step 3: Maintain for just 0.5 seconds (easier than Level 1!)
            if state.time > 0.5 && angleFromVertical < 0.35 {
                tutorialStep = 3
                showTutorialMessage("Perfect! Now try one more time.")
                NotificationCenter.default.post(name: Notification.Name("TutorialProgressUpdate"), object: nil, userInfo: ["step": 3])
            }
        case 3:
            // Step 4: Final success - just get it upright again briefly
            if state.time > 1.0 && angleFromVertical < 0.35 {
                tutorialStep = 4
                showTutorialMessage("🎉 Tutorial Complete! You've mastered the basics!")
                celebrateTutorialCompletion()
                NotificationCenter.default.post(name: Notification.Name("TutorialProgressUpdate"), object: nil, userInfo: ["step": 4])
            }
        default:
            break
        }
    }
    
    private func trackBalanceTime() {
        // Track how long the player maintains balance
        var balanceStartTime = Date()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self,
                  let viewModel = self.viewModel else {
                timer.invalidate()
                return
            }
            
            let angleFromVertical = abs(atan2(sin(viewModel.currentState.theta), cos(viewModel.currentState.theta)) - Double.pi)
            if angleFromVertical > 0.5 {
                // Lost balance
                timer.invalidate()
                if self.tutorialStep == 2 {
                    self.showTutorialMessage("Oops! Try again. Focus on the timing of your pushes.")
                }
            }
        }
    }
    
    private func showTutorialMessage(_ message: String) {
        NotificationCenter.default.post(
            name: Notification.Name("AITutorialMessage"),
            object: nil,
            userInfo: ["message": message]
        )
    }
    
    private func celebrateTutorialCompletion() {
        NotificationCenter.default.post(
            name: Notification.Name("AITutorialComplete"),
            object: nil,
            userInfo: ["score": 100]
        )
    }
}

// MARK: - Enhanced Tutorial UI
class TutorialSuggestionView: UIView {
    private let arrowView = UIImageView()
    private let labelView = UILabel()
    private var pulseAnimation: CABasicAnimation?
    
    init(direction: PushDirection) {
        super.init(frame: .zero)
        setupView(direction: direction)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView(direction: .left)
    }
    
    private func setupView(direction: PushDirection) {
        backgroundColor = FocusCalendarTheme.accentGold.withAlphaComponent(0.9)
        layer.cornerRadius = 25
        layer.zPosition = 1000 // High z-position to appear on top
        
        // Arrow
        let arrowImage = UIImage(systemName: direction == .left ? "arrow.left.circle.fill" : "arrow.right.circle.fill")
        arrowView.image = arrowImage
        arrowView.tintColor = .white
        arrowView.contentMode = .scaleAspectFit
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(arrowView)
        
        // Label
        labelView.text = "PUSH NOW!"
        labelView.font = FocusCalendarTheme.Fonts.titleFont(size: 14)
        labelView.textColor = .white
        labelView.textAlignment = .center
        labelView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(labelView)
        
        NSLayoutConstraint.activate([
            arrowView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            arrowView.centerXAnchor.constraint(equalTo: centerXAnchor),
            arrowView.widthAnchor.constraint(equalToConstant: 40),
            arrowView.heightAnchor.constraint(equalToConstant: 40),
            
            labelView.topAnchor.constraint(equalTo: arrowView.bottomAnchor, constant: 5),
            labelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            labelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            labelView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func showSuggestion(urgency: String) {
        // Set color based on urgency
        switch urgency {
        case "urgent":
            backgroundColor = UIColor.systemRed.withAlphaComponent(0.9)
            startUrgentPulse()
        case "important":
            backgroundColor = UIColor.systemOrange.withAlphaComponent(0.9)
            startNormalPulse()
        default:
            backgroundColor = FocusCalendarTheme.accentGold.withAlphaComponent(0.9)
            startNormalPulse()
        }
        
        // Show with animation
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [], animations: {
            self.alpha = 1
            self.transform = .identity
        })
        
        // Auto-hide after a short time
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.hideSuggestion()
        }
    }
    
    private func hideSuggestion() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.isHidden = true
            self.pulseAnimation?.repeatCount = 0
        }
    }
    
    private func startNormalPulse() {
        pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation?.fromValue = 1.0
        pulseAnimation?.toValue = 1.05  // Reduced from 1.1 for subtler effect
        pulseAnimation?.duration = 1.0   // Slower from 0.5 for less flashy
        pulseAnimation?.autoreverses = true
        pulseAnimation?.repeatCount = .infinity
        layer.add(pulseAnimation!, forKey: "pulse")
    }
    
    private func startUrgentPulse() {
        pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation?.fromValue = 1.0
        pulseAnimation?.toValue = 1.08  // Reduced from 1.2 for subtler effect
        pulseAnimation?.duration = 0.6   // Slower from 0.3 for less flashy
        pulseAnimation?.autoreverses = true
        pulseAnimation?.repeatCount = .infinity
        layer.add(pulseAnimation!, forKey: "pulse")
    }
}

// MARK: - Tutorial Progress Overlay
class TutorialProgressView: UIView {
    private let progressLabel = UILabel()
    private let stepIndicators: [UIView] = (0..<5).map { _ in
        let view = UIView()
        view.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 5
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = FocusCalendarTheme.cardBackgroundColor.withAlphaComponent(0.95)
        layer.cornerRadius = 15
        layer.borderWidth = 2
        layer.borderColor = FocusCalendarTheme.accentGold.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.zPosition = 1000 // High z-position to appear on top
        
        // Progress label
        progressLabel.text = "Tutorial Progress"
        progressLabel.font = FocusCalendarTheme.Fonts.titleFont(size: 16)
        progressLabel.textColor = FocusCalendarTheme.primaryTextColor
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressLabel)
        
        // Step indicators container
        let stackView = UIStackView(arrangedSubviews: stepIndicators)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            progressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            progressLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            stackView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            stackView.heightAnchor.constraint(equalToConstant: 10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    func updateProgress(step: Int) {
        for (index, indicator) in stepIndicators.enumerated() {
            UIView.animate(withDuration: 0.3) {
                if index <= step {
                    indicator.backgroundColor = FocusCalendarTheme.accentGold
                    indicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                } else {
                    indicator.backgroundColor = UIColor.systemGray.withAlphaComponent(0.3)
                    indicator.transform = .identity
                }
            }
        }
    }
}