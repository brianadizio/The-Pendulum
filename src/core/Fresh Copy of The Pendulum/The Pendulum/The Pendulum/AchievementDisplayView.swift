// AchievementDisplayView.swift
// Visual achievement notification system with particle effects

import UIKit

class AchievementDisplayView: UIView {
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let pointsLabel = UILabel()
    private let backgroundView = UIView()
    private let glowView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Main background with glassmorphism effect
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        backgroundView.layer.cornerRadius = 16
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        
        // Glow effect background
        glowView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.3)
        glowView.layer.cornerRadius = 18
        glowView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(glowView, belowSubview: backgroundView)
        
        // Icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(iconImageView)
        
        // Title label
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(titleLabel)
        
        // Description label
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        descriptionLabel.textAlignment = .left
        descriptionLabel.numberOfLines = 2
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(descriptionLabel)
        
        // Points label
        pointsLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        pointsLabel.textColor = .systemYellow
        pointsLabel.textAlignment = .right
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(pointsLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Background
            backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            
            // Glow
            glowView.topAnchor.constraint(equalTo: topAnchor),
            glowView.leadingAnchor.constraint(equalTo: leadingAnchor),
            glowView.trailingAnchor.constraint(equalTo: trailingAnchor),
            glowView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Icon
            iconImageView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: pointsLabel.leadingAnchor, constant: -8),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: backgroundView.bottomAnchor, constant: -12),
            
            // Points
            pointsLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            pointsLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            pointsLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func configure(with achievement: AchievementType, points: Int) {
        // Set icon
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        iconImageView.image = UIImage(systemName: achievement.icon, withConfiguration: config)
        iconImageView.tintColor = achievement.color
        
        // Set texts
        titleLabel.text = achievement.rawValue
        descriptionLabel.text = achievement.description
        pointsLabel.text = "+\(points)"
        
        // Set glow color
        glowView.backgroundColor = achievement.color.withAlphaComponent(0.3)
        
        // Set border color
        backgroundView.layer.borderColor = achievement.color.withAlphaComponent(0.5).cgColor
    }
    
    func animateIn() {
        // Initial state
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: -50).scaledBy(x: 0.8, y: 0.8)
        
        // Animate in
        UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: [], animations: {
            // Phase 1: Slide in and scale up
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.6) {
                self.alpha = 1.0
                self.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1.1, y: 1.1)
            }
            
            // Phase 2: Settle to normal size
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                self.transform = .identity
            }
        }, completion: nil)
        
        // Glow pulse animation
        glowView.alpha = 0.5
        UIView.animate(withDuration: 1.0, delay: 0.2, options: [.repeat, .autoreverse], animations: {
            self.glowView.alpha = 0.8
        }, completion: nil)
    }
    
    func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseIn], animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(translationX: 0, y: -30).scaledBy(x: 0.9, y: 0.9)
        }, completion: { _ in
            completion()
        })
    }
}

// MARK: - Achievement Display Manager

class AchievementDisplayManager {
    static let shared = AchievementDisplayManager()
    
    private var displayQueue: [AchievementType] = []
    private var currentDisplay: AchievementDisplayView?
    private var isDisplaying = false
    private weak var parentView: UIView?
    
    private init() {
        // Listen for achievement notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAchievementUnlocked(_:)),
            name: Notification.Name("AchievementUnlocked"),
            object: nil
        )
    }
    
    func setParentView(_ view: UIView) {
        parentView = view
    }
    
    @objc private func handleAchievementUnlocked(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let achievementType = userInfo["type"] as? String,
              let achievement = AchievementType(rawValue: achievementType),
              let points = userInfo["points"] as? Int else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.showAchievement(achievement, points: points)
        }
    }
    
    private func showAchievement(_ achievement: AchievementType, points: Int) {
        guard let parentView = parentView else { return }
        
        if isDisplaying {
            // Queue the achievement if one is currently showing
            displayQueue.append(achievement)
            return
        }
        
        isDisplaying = true
        
        // Create achievement view
        let achievementView = AchievementDisplayView()
        achievementView.configure(with: achievement, points: points)
        achievementView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(achievementView)
        currentDisplay = achievementView
        
        // Position at top of screen
        NSLayoutConstraint.activate([
            achievementView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor, constant: 20),
            achievementView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20),
            achievementView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20),
            achievementView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // Animate in
        achievementView.animateIn()
        
        // Create particle effects
        createAchievementParticles(around: achievementView, color: achievement.color)
        
        // Auto-dismiss after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.dismissCurrentAchievement()
        }
    }
    
    private func createAchievementParticles(around view: UIView, color: UIColor) {
        guard let parentView = parentView else { return }
        
        // Create particle burst at achievement location
        let centerPoint = CGPoint(
            x: view.frame.midX,
            y: view.frame.midY
        )
        
        // Use ViewControllerParticleSystem for celebration
        ViewControllerParticleSystem.createCelebrationBurst(
            in: parentView,
            at: centerPoint,
            color: color
        )
    }
    
    private func dismissCurrentAchievement() {
        guard let currentDisplay = currentDisplay else { return }
        
        currentDisplay.animateOut { [weak self] in
            currentDisplay.removeFromSuperview()
            self?.currentDisplay = nil
            self?.isDisplaying = false
            
            // Show next achievement in queue
            if !(self?.displayQueue.isEmpty ?? true),
               let nextAchievement = self?.displayQueue.removeFirst() {
                self?.showAchievement(nextAchievement, points: nextAchievement.points)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - ViewControllerParticleSystem Extension

extension ViewControllerParticleSystem {
    static func createCelebrationBurst(in view: UIView, at point: CGPoint, color: UIColor) {
        // Create multiple small bursts around the achievement
        for i in 0..<8 {
            let angle = Double(i) * .pi / 4
            let offset = CGPoint(
                x: point.x + cos(angle) * 30,
                y: point.y + sin(angle) * 30
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                createSingleBurst(in: view, at: offset, color: color)
            }
        }
    }
    
    private static func createSingleBurst(in view: UIView, at point: CGPoint, color: UIColor) {
        // Create 15 particles in a burst
        for _ in 0..<15 {
            let particle = UIView()
            particle.backgroundColor = color
            particle.frame = CGRect(x: point.x, y: point.y, width: 4, height: 4)
            particle.layer.cornerRadius = 2
            particle.alpha = 1.0
            view.addSubview(particle)
            
            // Random direction and speed
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = Double.random(in: 50...100)
            let endX = point.x + cos(angle) * speed
            let endY = point.y + sin(angle) * speed
            
            // Animate particle
            UIView.animate(withDuration: 0.8, delay: 0, options: [.curveEaseOut], animations: {
                particle.center = CGPoint(x: endX, y: endY)
                particle.alpha = 0
                particle.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }, completion: { _ in
                particle.removeFromSuperview()
            })
        }
    }
}