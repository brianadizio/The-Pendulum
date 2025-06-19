import UIKit
import Foundation

// MARK: - Enhanced Tutorial Mode for AI
extension PendulumAIManager {
    
    /// Enhanced tutorial mode that provides visual guidance
    func startEnhancedTutorial(viewModel: PendulumViewModel) {
        self.viewModel = viewModel
        self.currentMode = .tutorial
        tutorialStep = 0
        
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
        aiPlayer?.onPushLeft = { [weak self] in
            self?.showTutorialSuggestion(direction: .left)
        }
        
        aiPlayer?.onPushRight = { [weak self] in
            self?.showTutorialSuggestion(direction: .right)
        }
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
            }
        case 1:
            // Step 2: Get pendulum nearly vertical
            if angleFromVertical < 0.2 {
                tutorialStep = 2
                showTutorialMessage("Excellent! Now maintain balance for 5 seconds.")
                trackBalanceTime()
            }
        case 2:
            // Step 3: Maintain for 5 seconds
            if state.time > 5.0 && angleFromVertical < 0.3 {
                tutorialStep = 3
                showTutorialMessage("Perfect! Try using smaller, gentler pushes now.")
            }
        case 3:
            // Step 4: Advanced balancing
            if state.time > 10.0 && angleFromVertical < 0.3 {
                tutorialStep = 4
                showTutorialMessage("🎉 Tutorial Complete! You've mastered the basics!")
                celebrateTutorialCompletion()
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
        pulseAnimation?.toValue = 1.1
        pulseAnimation?.duration = 0.5
        pulseAnimation?.autoreverses = true
        pulseAnimation?.repeatCount = .infinity
        layer.add(pulseAnimation!, forKey: "pulse")
    }
    
    private func startUrgentPulse() {
        pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation?.fromValue = 1.0
        pulseAnimation?.toValue = 1.2
        pulseAnimation?.duration = 0.3
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
        backgroundColor = FocusCalendarTheme.cardBackgroundColor
        layer.cornerRadius = 15
        layer.borderWidth = 2
        layer.borderColor = FocusCalendarTheme.accentGold.cgColor
        
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