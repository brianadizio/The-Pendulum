// DocumentationViews.swift
// The Pendulum 2.0
// In-app documentation for the physics model and dashboard metrics

import SwiftUI

// MARK: - Science Documentation View

struct ScienceDocumentationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: Introduction
                DocSection(title: "THE INVERTED PENDULUM") {
                    Text("The Pendulum simulates a rigid inverted pendulum — one of the most studied problems in control theory. Unlike a regular pendulum that hangs down, an inverted pendulum balances upright at an unstable equilibrium. Any small disturbance will cause it to fall unless corrective forces are applied.")

                    Text("This is the same fundamental challenge faced by rocket guidance systems, self-balancing robots, and the human body's postural control system. When you play, you are solving the same control problem your vestibular system solves every time you stand upright.")
                }

                // MARK: Equation of Motion
                DocSection(title: "EQUATION OF MOTION") {
                    Text("The pendulum's motion is governed by a second-order ordinary differential equation (ODE):")

                    // Equation block
                    VStack(alignment: .leading, spacing: 8) {
                        Text("θ\" = -ka · sin(θ) + ks · θ - kb · ω + F(t)")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundStyle(PendulumColors.gold)

                        Text("where:")
                            .font(.system(size: 13))
                            .foregroundStyle(PendulumColors.textSecondary)

                        VStack(alignment: .leading, spacing: 4) {
                            EquationTerm(symbol: "ka", definition: "= mLg / (mL² + I)", meaning: "gravity coefficient")
                            EquationTerm(symbol: "ks", definition: "= k / (mL² + I)", meaning: "spring coefficient")
                            EquationTerm(symbol: "kb", definition: "= b / (mL² + I)", meaning: "damping coefficient")
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(PendulumColors.backgroundSecondary)
                    )

                    Text("Each term plays a distinct physical role:")

                    DocBullet(icon: "arrow.down", color: .red, text: "Gravity torque (-ka · sin θ) — pulls the pendulum toward the ground. This is the destabilizing force you fight against.")
                    DocBullet(icon: "arrow.up", color: .green, text: "Spring restoring (ks · θ) — a small centering bias near upright that makes the game playable. Without it, balancing would require superhuman precision.")
                    DocBullet(icon: "wind", color: .blue, text: "Damping (-kb · ω) — friction that slows the swing. Higher damping makes the pendulum more forgiving.")
                    DocBullet(icon: "hand.raised", color: PendulumColors.gold, text: "Applied force F(t) — your push input, plus any perturbations from the game mode.")
                }

                // MARK: Parameters
                DocSection(title: "PARAMETERS") {
                    Text("The physics simulation uses six configurable parameters. Different game modes adjust these to change difficulty.")

                    VStack(spacing: 6) {
                        ParameterRow(symbol: "m", name: "Mass", unit: "kg", role: "Weight at the end of the rod. Heavier = more momentum, harder to reverse.")
                        ParameterRow(symbol: "L", name: "Length", unit: "m", role: "Rod length. Longer = slower oscillation but harder to stabilize.")
                        ParameterRow(symbol: "g", name: "Gravity", unit: "m/s²", role: "Gravitational acceleration. Default 9.81 (Earth). Higher = faster falls.")
                        ParameterRow(symbol: "b", name: "Damping", unit: "—", role: "Friction coefficient. Higher = more forgiving, slower swings.")
                        ParameterRow(symbol: "k", name: "Spring", unit: "—", role: "Small centering force for playability. Keeps micro-corrections manageable.")
                        ParameterRow(symbol: "I", name: "Moment of Inertia", unit: "kg·m²", role: "Resistance to angular change. Higher = more stable but slower to respond.")
                    }
                }

                // MARK: State Variables
                DocSection(title: "STATE VARIABLES") {
                    Text("The pendulum's state at any moment is described by two variables:")

                    VStack(spacing: 6) {
                        StateRow(symbol: "θ", name: "Theta (angle)", description: "Angle from vertical in radians. θ = 0 is perfectly upright. θ = π/2 is horizontal.")
                        StateRow(symbol: "ω", name: "Omega (angular velocity)", description: "Rate of angle change in rad/s. Positive = swinging one way, negative = the other.")
                    }

                    Text("Together, (θ, ω) defines a point in phase space — the state space the Dashboard's phase portrait visualizes.")
                        .font(.system(size: 13))
                        .foregroundStyle(PendulumColors.textSecondary)
                }

                // MARK: The Solver
                DocSection(title: "THE SOLVER") {
                    Text("The simulation uses a 4th-order Runge-Kutta (RK4) numerical integrator — the gold standard for ODE simulation. RK4 evaluates the equation four times per timestep to achieve high accuracy.")

                    Text("The simulation runs at 60 steps per second, matching the display refresh rate. This means 60 full RK4 evaluations per second, each computing the pendulum's next state from its current state.")
                        .font(.system(size: 13))
                        .foregroundStyle(PendulumColors.textSecondary)
                }

                // MARK: Scientific Context
                DocSection(title: "SCIENTIFIC CONTEXT") {
                    Text("The inverted pendulum is deeply connected to two fields of active research:")

                    Text("Human Balance & Spatial Orientation")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(PendulumColors.text)

                    Text("Researchers at the Ashton Graybiel Spatial Orientation Laboratory at Brandeis University use inverted pendulum devices to study human vestibular balance. Blindfolded subjects stabilize themselves in a device programmed to behave as an inverted pendulum, revealing how the brain integrates sensory information for balance control.")

                    Text("Topological Signal Processing")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(PendulumColors.text)

                    Text("The topology metrics in this app are inspired by techniques from topological data analysis (TDA), which uses mathematical structures like Betti numbers and persistent homology to characterize the shape of data. These methods reveal qualitative features of your control strategy that traditional statistics miss.")
                }

                // MARK: References
                DocSection(title: "REFERENCES") {
                    ReferenceLink(
                        text: "Robinson, M. (2014). Topological Signal Processing. Mathematical Engineering. Springer.",
                        url: "https://doi.org/10.1007/978-3-642-36104-3"
                    )

                    ReferenceLink(
                        text: "Ashton Graybiel Spatial Orientation Laboratory, Brandeis University.",
                        url: "https://www.brandeis.edu/graybiel/"
                    )

                    ReferenceLink(
                        text: "Lackner JR, DiZio P. Multisensory, cognitive, and motor influences on human spatial orientation in weightlessness. J Vestibular Research, 3(3):361-372, 1993.",
                        url: nil
                    )

                    ReferenceLink(
                        text: "Vimal VP, DiZio P, Lackner JR. Learning dynamic balancing in the roll plane with and without gravitational cues. Exp Brain Res, 240(1):123-133, 2022.",
                        url: nil
                    )
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
        .background(PendulumColors.background)
        .navigationTitle("The Science")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Metrics Documentation View

struct MetricsDocumentationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("The Dashboard tracks your performance across six categories, from basic gameplay stats to research-grade topological analysis.")
                    .font(.system(size: 14))
                    .foregroundStyle(PendulumColors.textSecondary)
                    .padding(.horizontal, 16)

                // MARK: Basic Metrics
                MetricCategorySection(title: "BASIC METRICS", icon: "chart.bar", description: "Core performance indicators visible at the top of your Dashboard.") {
                    MetricExplanation(name: "Stability Score", explanation: "Percentage of time the pendulum stays within the balanced zone (green). Higher is better.")
                    MetricExplanation(name: "Efficiency Rating", explanation: "How much stability you achieve per unit of force applied. Rewards precise, minimal corrections over brute-force pushing.")
                    MetricExplanation(name: "Total Session Time", explanation: "Cumulative time spent playing across all sessions in the selected time range.")
                    MetricExplanation(name: "Total Pushes", explanation: "Total number of directional pushes applied across all sessions.")
                    MetricExplanation(name: "Max Level Reached", explanation: "Highest level completed in any session.")
                    MetricExplanation(name: "Sessions Played", explanation: "Number of sessions in the selected time range.")
                }

                // MARK: Advanced Metrics
                MetricCategorySection(title: "ADVANCED METRICS", icon: "gauge.with.dots.needle.33percent", description: "Deeper analysis of your control strategy and reflexes.") {
                    MetricExplanation(name: "Directional Bias", explanation: "Whether you push left or right more often. Neutral (0) means balanced. Positive = right bias, negative = left bias.")
                    MetricExplanation(name: "Overcorrection Rate", explanation: "Percentage of pushes followed by an opposite push within 0.5 seconds. Lower is better — high overcorrection means you're oscillating around the target.")
                    MetricExplanation(name: "Avg Reaction Time", explanation: "How quickly you respond when the pendulum drifts beyond the stability threshold. Measured in seconds from instability detection to your corrective push.")
                }

                // MARK: Scientific Metrics
                MetricCategorySection(title: "SCIENTIFIC METRICS", icon: "atom", description: "Metrics from dynamical systems theory that characterize your control behavior.") {
                    MetricExplanation(name: "Phase Space Coverage", explanation: "What percentage of the (θ, ω) state space your trajectory visits. High coverage means varied, exploratory behavior. Low coverage means tight, controlled balancing.")
                    MetricExplanation(name: "Energy Management", explanation: "How consistently you maintain the pendulum's total energy. Based on the variance of kinetic + potential energy over time. Higher = more consistent.")
                    MetricExplanation(name: "Lyapunov Exponent", explanation: "A measure of chaos in your control. Positive values indicate chaotic, unpredictable motion. Near-zero or negative values indicate stable, predictable control.")
                    MetricExplanation(name: "Angular Deviation σ", explanation: "Standard deviation of your angle from upright, in degrees. Lower means tighter balance around the equilibrium point.")
                }

                // MARK: Topology Metrics
                MetricCategorySection(title: "TOPOLOGY METRICS", icon: "circle.hexagongrid", description: "Topological invariants that capture the qualitative shape of your trajectory, inspired by Robinson's Topological Signal Processing.") {
                    MetricExplanation(name: "Winding Number", explanation: "Total number of full rotations your pendulum makes around the equilibrium. High winding numbers indicate large, sweeping oscillations.")
                    MetricExplanation(name: "Basin Stability", explanation: "Percentage of time spent within the stable attraction region (within ~30 degrees of upright). Higher = more time in the safe zone.")
                    MetricExplanation(name: "Periodic Orbits", explanation: "Number of distinct closed loops detected in your phase space trajectory. Indicates repeating, rhythmic control patterns.")
                    MetricExplanation(name: "Betti Numbers [β₀, β₁]", explanation: "Topological invariants: β₀ counts connected components (trajectory segments), β₁ counts holes (enclosed loops) in the phase space. These reveal the qualitative structure of your control strategy.")
                    MetricExplanation(name: "Separatrix Crossings", explanation: "Number of transitions between the stable and unstable energy regions. Each crossing represents a moment where the pendulum's fate hung in the balance.")
                }

                // MARK: Educational Metrics
                MetricCategorySection(title: "EDUCATIONAL METRICS", icon: "graduationcap", description: "Track your learning and improvement over time.") {
                    MetricExplanation(name: "Learning Curve Slope", explanation: "Your percentage improvement per session, computed via linear regression across recent sessions. Positive = improving, negative = declining.")
                    MetricExplanation(name: "Skill Retention", explanation: "How consistent your performance is across sessions. 100% means every session is equally good. Lower values indicate high variance between sessions.")
                }

                // MARK: AI Metrics
                MetricCategorySection(title: "AI METRICS", icon: "sparkles", description: "Visible when AI assistance is active. Tracks how much help the AI provides.") {
                    MetricExplanation(name: "Assistance %", explanation: "Percentage of time the AI assistant was actively applying corrective forces.")
                    MetricExplanation(name: "Avg AI Force", explanation: "Average magnitude of the AI's corrective forces. Higher means more aggressive assistance.")
                    MetricExplanation(name: "AI Interventions", explanation: "Total number of times the AI applied a non-zero corrective force during the session.")
                }

                // Reference note
                VStack(alignment: .leading, spacing: 8) {
                    Text("Further Reading")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(PendulumColors.textTertiary)

                    ReferenceLink(
                        text: "Robinson, M. (2014). Topological Signal Processing. Springer.",
                        url: "https://doi.org/10.1007/978-3-642-36104-3"
                    )
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
        .background(PendulumColors.background)
        .navigationTitle("Metrics Guide")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Reusable Documentation Components

private struct DocSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(PendulumColors.textTertiary)

            content()
                .font(.system(size: 14))
                .foregroundStyle(PendulumColors.text)
        }
    }
}

private struct DocBullet: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
                .frame(width: 20, alignment: .center)
                .padding(.top, 2)

            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(PendulumColors.text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct EquationTerm: View {
    let symbol: String
    let definition: String
    let meaning: String

    var body: some View {
        HStack(spacing: 6) {
            Text(symbol)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundStyle(PendulumColors.gold)
                .frame(width: 24, alignment: .trailing)

            Text(definition)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(PendulumColors.text)

            Text("(\(meaning))")
                .font(.system(size: 11))
                .foregroundStyle(PendulumColors.textTertiary)
        }
    }
}

private struct ParameterRow: View {
    let symbol: String
    let name: String
    let unit: String
    let role: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(symbol)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(PendulumColors.gold)
                .frame(width: 20, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(PendulumColors.text)

                    Text("(\(unit))")
                        .font(.system(size: 11))
                        .foregroundStyle(PendulumColors.textTertiary)
                }

                Text(role)
                    .font(.system(size: 12))
                    .foregroundStyle(PendulumColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(PendulumColors.backgroundSecondary)
        )
    }
}

private struct StateRow: View {
    let symbol: String
    let name: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(symbol)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(PendulumColors.gold)
                .frame(width: 20, alignment: .center)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PendulumColors.text)

                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(PendulumColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(PendulumColors.backgroundSecondary)
        )
    }
}

private struct ReferenceLink: View {
    let text: String
    let url: String?

    var body: some View {
        if let urlString = url, let link = URL(string: urlString) {
            Button(action: {
                UIApplication.shared.open(link)
            }) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 12))
                        .foregroundStyle(PendulumColors.gold)
                        .frame(width: 16)
                        .padding(.top, 2)

                    Text(text)
                        .font(.system(size: 12))
                        .foregroundStyle(PendulumColors.gold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "doc.text")
                    .font(.system(size: 12))
                    .foregroundStyle(PendulumColors.bronze)
                    .frame(width: 16)
                    .padding(.top, 2)

                Text(text)
                    .font(.system(size: 12))
                    .foregroundStyle(PendulumColors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Metrics Guide Components

private struct MetricCategorySection<Content: View>: View {
    let title: String
    let icon: String
    let description: String
    @ViewBuilder let content: () -> Content
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(PendulumColors.bronze)
                        .frame(width: 24)

                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(PendulumColors.textTertiary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(PendulumColors.bronze)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)

            // Description always visible
            Text(description)
                .font(.system(size: 13))
                .foregroundStyle(PendulumColors.textSecondary)
                .padding(.horizontal, 16)

            // Expanded content
            if isExpanded {
                VStack(spacing: 6) {
                    content()
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct MetricExplanation: View {
    let name: String
    let explanation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(PendulumColors.text)

            Text(explanation)
                .font(.system(size: 12))
                .foregroundStyle(PendulumColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(PendulumColors.backgroundSecondary)
        )
    }
}

// MARK: - Previews

#Preview("Science") {
    NavigationStack {
        ScienceDocumentationView()
    }
}

#Preview("Metrics") {
    NavigationStack {
        MetricsDocumentationView()
    }
}
