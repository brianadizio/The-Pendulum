import SwiftUI

// MARK: - Perturbation Mode Selection

struct ContentViewModes: View {
    var body: some View {
        print("ContentViewModes loaded - showing new HORIZONTAL layout v2")
        return ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack(spacing: 12) {
                    Image("PendulumLogo-removebg-preview")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    
                    Text("Game Modes")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(FocusCalendarTheme.primaryTextColor))
                }
                .padding(.top, 20)
                
                // Active Modes Section (Primary & Perturbation combined)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Modes")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(FocusCalendarTheme.primaryTextColor))
                        .padding(.horizontal)
                    
                    // Primary Modes
                    PerturbationModeButton(title: "Primary", subtitle: "Basic Pendulum", iconName: "circle.dashed", action: {
                        NotificationCenter.default.post(name: Notification.Name("ActivatePrimaryMode"), object: nil)
                    })
                    .padding(.horizontal)
                    
                    PerturbationModeButton(title: "Progressive", subtitle: "Increasing Difficulty", iconName: "chart.line.uptrend.xyaxis", action: {
                        NotificationCenter.default.post(name: Notification.Name("ActivateProgressiveMode"), object: nil)
                    })
                    .padding(.horizontal)
                    
                    // Perturbation Modes
                    PerturbationModeButton(title: "No Perturbation", subtitle: "Gravity Only", iconName: "arrow.down", action: {
                        NotificationCenter.default.post(name: Notification.Name("DeactivatePerturbation"), object: nil)
                    })
                    .padding(.horizontal)
                    
                    PerturbationModeButton(title: "Random Impulses", subtitle: "Sudden Forces", iconName: "bolt.circle", action: {
                        NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "impulse")
                    })
                    .padding(.horizontal)
                    
                    PerturbationModeButton(title: "Sine Wave", subtitle: "Periodic Force", iconName: "waveform", action: {
                        NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "sine")
                    })
                    .padding(.horizontal)
                    
                    PerturbationModeButton(title: "Data Driven", subtitle: "CSV Based", iconName: "doc.chart", action: {
                        NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "data")
                    })
                    .padding(.horizontal)
                    
                    PerturbationModeButton(title: "Compound", subtitle: "Multi-Effect", iconName: "square.stack.3d.forward.dottedline", action: {
                        NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "compound")
                    })
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.horizontal)
                
                // Coming Soon Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Coming Soon")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(FocusCalendarTheme.primaryTextColor))
                        .padding(.horizontal)
                    
                    ComingSoonButton(title: "Real Experiment", subtitle: "Lab Data", iconName: "testtube.2")
                        .padding(.horizontal)
                    ComingSoonButton(title: "The Focus Calendar", subtitle: "Productivity Mode", iconName: "calendar")
                        .padding(.horizontal)
                    ComingSoonButton(title: "Zero Gravity", subtitle: "Space Station", iconName: "star")
                        .padding(.horizontal)
                    ComingSoonButton(title: "Rotating Room", subtitle: "Spinning Chamber", iconName: "arrow.triangle.2.circlepath")
                        .padding(.horizontal)
                    ComingSoonButton(title: "The Maze", subtitle: "Navigate Puzzles", iconName: "square.grid.3x3")
                        .padding(.horizontal)
                    ComingSoonButton(title: "Nature's Essence", subtitle: "Natural Forces", iconName: "leaf")
                        .padding(.horizontal)
                }
                
                Divider()
                    .padding(.horizontal)
                
                // Additional Information Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Additional Information")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(FocusCalendarTheme.primaryTextColor))
                        .padding(.horizontal)
                    
                    PerturbationModeButton(title: "Inverted Pendulum", subtitle: "Physics & Algorithms", iconName: "doc.text", action: {
                        NotificationCenter.default.post(name: Notification.Name("ShowPendulumPhysics"), object: nil)
                    })
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private func showComingSoonAlert() {
        // This will be handled by the view controller
        NotificationCenter.default.post(name: Notification.Name("ShowComingSoonAlert"), object: nil)
    }
}

// MARK: - Mode Button Styles

struct PerturbationModeButton: View {
    let title: String
    let subtitle: String
    let iconName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.blue.opacity(0.8))
                    .clipShape(Circle())
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Subtitle
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.1)) // DEBUG: Red background to see actual width
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ComingSoonButton: View {
    let title: String
    let subtitle: String
    let iconName: String
    
    var body: some View {
        Button(action: showComingSoonAlert) {
            ZStack {
                HStack(spacing: 15) {
                    // Icon
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 44, height: 44)
                        .background(Color.gray.opacity(0.5))
                        .clipShape(Circle())
                    
                    // Text content
                    VStack(alignment: .leading, spacing: 4) {
                        // Title
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary.opacity(0.6))
                            .lineLimit(1)
                        
                        // Subtitle
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary.opacity(0.6))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Chevron (disabled look)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary.opacity(0.4))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                
                // Coming Soon overlay
                Text("COMING SOON")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(6)
                    .offset(x: -20, y: 0)
            }
            .background(Color(UIColor.secondarySystemBackground).opacity(0.7))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func showComingSoonAlert() {
        NotificationCenter.default.post(name: Notification.Name("ShowComingSoonAlert"), object: nil)
    }
}


// UIKit Wrapper for compatibility with existing codebase
struct ModeButton: UIViewRepresentable {
    let title: String
    let action: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: ModeButton
        
        init(_ modeButton: ModeButton) {
            self.parent = modeButton
            super.init()
        }
        
        @objc func doAction(_ sender: Any) {
            self.parent.action()
        }
    }
    
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        
        // Configure button appearance
        button.setTitle(title, for: .normal)
        button.addTarget(context.coordinator, action: #selector(Coordinator.doAction(_:)), for: .touchUpInside)
        button.backgroundColor = UIColor.systemBackground
        button.setTitleColor(UIColor.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {
        uiView.setTitle(title, for: .normal)
    }
}