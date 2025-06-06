import SwiftUI

// MARK: - Perturbation Mode Selection

struct ContentViewModes: View {
    var body: some View {
        print("ContentViewModes loaded - showing GRID layout with rounded square buttons")
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
                    
                    // Grid layout for active modes
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        // Primary Modes
                        RoundedSquareModeButton(title: "Primary", iconName: "pendulumModesPrimary", isAssetImage: true, action: {
                            NotificationCenter.default.post(name: Notification.Name("ActivatePrimaryMode"), object: nil)
                        })
                        
                        RoundedSquareModeButton(title: "Progressive", iconName: "pendulumModesProgressive", isAssetImage: true, action: {
                            NotificationCenter.default.post(name: Notification.Name("ActivateProgressiveMode"), object: nil)
                        })
                        
                        // Perturbation Modes
                        RoundedSquareModeButton(title: "Random", iconName: "pendulumModesRandomImpulses", isAssetImage: true, action: {
                            NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "impulse")
                        })
                        
                        RoundedSquareModeButton(title: "Sine Wave", iconName: "pendulumModesSine", isAssetImage: true, action: {
                            NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "sine")
                        })
                        
                        RoundedSquareModeButton(title: "Data Driven", iconName: "pendulumModesDataDriven1", isAssetImage: true, action: {
                            NotificationCenter.default.post(name: Notification.Name("ActivateSpecialPerturbation"), object: "data")
                        })
                        
                        RoundedSquareModeButton(title: "Compound", iconName: "pendulumModesCompound", isAssetImage: true, action: {
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
                    
                    // Grid layout for coming soon modes
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        RoundedSquareComingSoonButton(title: "Real Lab", iconName: "pendulumModesRealExperiment", isAssetImage: true)
                        RoundedSquareComingSoonButton(title: "Calendar", iconName: "pendulumModesFocusCalendar", isAssetImage: true)
                        RoundedSquareComingSoonButton(title: "Zero G", iconName: "pendulumModesZeroGravity", isAssetImage: true)
                        RoundedSquareComingSoonButton(title: "Rotating", iconName: "pendulumModesRotatingRoom", isAssetImage: true)
                        RoundedSquareComingSoonButton(title: "The Maze", iconName: "pendulumModesTheMaze", isAssetImage: true)
                        RoundedSquareComingSoonButton(title: "Nature", iconName: "pendulumModesNaturesEssence", isAssetImage: true)
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
                    
                    // Single button centered
                    HStack {
                        Spacer()
                        RoundedSquareModeButton(title: "Physics", iconName: "doc.text", isAssetImage: false, action: {
                            NotificationCenter.default.post(name: Notification.Name("ShowPendulumPhysics"), object: nil)
                        })
                        .frame(width: 160)
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

// MARK: - Rounded Square Mode Button Styles

struct RoundedSquareModeButton: View {
    let title: String
    let iconName: String
    var isAssetImage: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Icon
                if isAssetImage {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: iconName)
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(Color(FocusCalendarTheme.accentGold))
                        .frame(width: 60, height: 60)
                }
                
                // Title
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(FocusCalendarTheme.primaryTextColor))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(FocusCalendarTheme.lightBorderColor), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct RoundedSquareComingSoonButton: View {
    let title: String
    let iconName: String
    var isAssetImage: Bool = false
    
    var body: some View {
        Button(action: showComingSoonAlert) {
            ZStack {
                VStack(spacing: 8) {
                    // Icon
                    if isAssetImage {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .opacity(0.4)
                    } else {
                        Image(systemName: iconName)
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(Color.gray.opacity(0.5))
                            .frame(width: 60, height: 60)
                    }
                    
                    // Title
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(FocusCalendarTheme.primaryTextColor).opacity(0.5))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 4)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                
                // Coming Soon badge
                Text("SOON")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange)
                    .cornerRadius(4)
                    .offset(x: 25, y: -45)
            }
            .background(Color(UIColor.secondarySystemBackground).opacity(0.6))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(FocusCalendarTheme.lightBorderColor).opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func showComingSoonAlert() {
        NotificationCenter.default.post(name: Notification.Name("ShowComingSoonAlert"), object: nil)
    }
}

// Custom button style for scale animation on press
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
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