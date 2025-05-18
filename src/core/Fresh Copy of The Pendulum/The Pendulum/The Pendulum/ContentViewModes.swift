import SwiftUI

// MARK: - Perturbation Mode Selection

struct ContentViewModes: View {
    var body: some View {
        print("ContentViewModes loaded - showing new layout")
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
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        // Primary Modes
                        PerturbationModeButton(title: "Primary", subtitle: "Basic Pendulum", iconName: "circle.dashed", action: {
                            NotificationCenter.default.post(name: Notification.Name("ActivatePrimaryMode"), object: nil)
                        })
                        
                        PerturbationModeButton(title: "Progressive", subtitle: "Increasing Difficulty", iconName: "chart.line.uptrend.xyaxis", action: {
                            NotificationCenter.default.post(name: Notification.Name("ActivateProgressiveMode"), object: nil)
                        })
                        
                        // Perturbation Modes
                        PerturbationModeButton(title: "No Perturbation", subtitle: "Gravity Only", iconName: "arrow.down", action: {
                            NotificationCenter.default.post(name: Notification.Name("DeactivatePerturbation"), object: nil)
                        })
                        
                        PerturbationModeButton(title: "Random Impulses", subtitle: "Sudden Forces", iconName: "bolt.circle", action: {
                            NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "impulse")
                        })
                        
                        PerturbationModeButton(title: "Sine Wave", subtitle: "Periodic Force", iconName: "waveform", action: {
                            NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "sine")
                        })
                        
                        PerturbationModeButton(title: "Data Driven", subtitle: "CSV Based", iconName: "doc.chart", action: {
                            NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "data")
                        })
                        
                        PerturbationModeButton(title: "Compound", subtitle: "Multi-Effect", iconName: "square.stack.3d.forward.dottedline", action: {
                            NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "compound")
                        })
                    }
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
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ComingSoonButton(title: "Real Experiment", subtitle: "Lab Data", iconName: "testtube.2")
                        ComingSoonButton(title: "The Focus Calendar", subtitle: "Productivity Mode", iconName: "calendar")
                        ComingSoonButton(title: "Zero Gravity", subtitle: "Space Station", iconName: "star")
                        ComingSoonButton(title: "Rotating Room", subtitle: "Spinning Chamber", iconName: "arrow.triangle.2.circlepath")
                        ComingSoonButton(title: "The Maze", subtitle: "Navigate Puzzles", iconName: "square.grid.3x3")
                        ComingSoonButton(title: "Nature's Essence", subtitle: "Natural Forces", iconName: "leaf")
                    }
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
                    
                    HStack {
                        Spacer()
                        PerturbationModeButton(title: "Inverted Pendulum", subtitle: "Physics & Algorithms", iconName: "doc.text", action: {
                            NotificationCenter.default.post(name: Notification.Name("ShowPendulumPhysics"), object: nil)
                        })
                        .frame(maxWidth: 300)
                        Spacer()
                    }
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
            VStack(spacing: 10) {
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.blue.opacity(0.8))
                    .clipShape(Circle())
                
                // Title
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Subtitle
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
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
                VStack(spacing: 10) {
                    // Icon
                    Image(systemName: iconName)
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 50, height: 50)
                        .background(Color.gray.opacity(0.5))
                        .clipShape(Circle())
                    
                    // Title
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary.opacity(0.6))
                    
                    // Subtitle
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                
                // Coming Soon overlay
                Text("COMING SOON")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(6)
                    .offset(x: 35, y: -35)
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