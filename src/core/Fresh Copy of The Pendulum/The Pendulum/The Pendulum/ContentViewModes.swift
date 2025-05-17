import SwiftUI

// MARK: - Perturbation Mode Selection

struct ContentViewModes: View {
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack(spacing: 12) {
                Image("PendulumLogo-removebg-preview")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                
                Text("Perturbation Modes")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(UIColor.goldenPrimary))
            }
            .padding(.top, 20)
            
            // Description
            Text("Select a perturbation mode to modify how external forces affect the pendulum")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 10)
            
            // Main modes grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                // Standard mode buttons
                PerturbationModeButton(title: "Mode 1", subtitle: "Joshua Tree", iconName: "mountain.2", action: {
                    NotificationCenter.default.post(name: Notification.Name("ActivatePerturbationMode"), object: 1)
                })
                
                PerturbationModeButton(title: "Mode 2", subtitle: "Zero-G Space", iconName: "sparkles", action: {
                    NotificationCenter.default.post(name: Notification.Name("ActivatePerturbationMode"), object: 2)
                })
                
                PerturbationModeButton(title: "Experiment", subtitle: "Data-Driven", iconName: "waveform.path", action: {
                    NotificationCenter.default.post(name: Notification.Name("ActivatePerturbationMode"), object: 0)
                })
                
                PerturbationModeButton(title: "No Perturbation", subtitle: "Gravity Only", iconName: "arrow.down", action: {
                    NotificationCenter.default.post(name: Notification.Name("DeactivatePerturbation"), object: nil)
                })
            }
            .padding()
            
            Divider()
                .padding(.vertical, 5)
            
            // Special perturbation types
            Text("Special Perturbation Types")
                .font(.headline)
                .padding(.top, 10)
            
            // Special perturbation buttons
            VStack(spacing: 15) {
                SpecialPerturbationButton(title: "Random Impulses", description: "Random forces applied at unpredictable intervals", action: {
                    NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "impulse")
                })
                
                SpecialPerturbationButton(title: "Sine Wave", description: "Smooth oscillating forces with adjustable frequency", action: {
                    NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "sine")
                })
                
                SpecialPerturbationButton(title: "Data-Driven", description: "Forces from external datasets or recordings", action: {
                    NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "data")
                })
                
                SpecialPerturbationButton(title: "Compound", description: "Complex combination of multiple perturbation types", action: {
                    NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "compound")
                })
            }
            .padding()
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
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

struct SpecialPerturbationButton: View {
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Title and description
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Indicator
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
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