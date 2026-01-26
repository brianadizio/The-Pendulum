// IntegrationView.swift
// The Pendulum 2.0
// Placeholder for cross-solution connections

import SwiftUI

struct IntegrationView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            IntegrationHeader()

            ScrollView {
                VStack(spacing: 24) {
                    // Golden Solutions Section
                    GoldenSolutionsSection()

                    Divider().padding(.horizontal, 16)

                    // External Services Section
                    ExternalServicesSection()

                    Divider().padding(.horizontal, 16)

                    // The Hypergraph Link
                    HypergraphSection()
                }
                .padding(.vertical, 16)
            }
        }
    }
}

// MARK: - Integration Header
struct IntegrationHeader: View {
    var body: some View {
        HStack {
            Text("Integration")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemBackground))
    }
}

// MARK: - Golden Solutions Section
struct GoldenSolutionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GOLDEN SOLUTIONS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                IntegrationCard(
                    title: "The Maze",
                    description: "Connect balance patterns to maze navigation",
                    iconName: "square.grid.3x3",
                    isConnected: false
                )

                IntegrationCard(
                    title: "Focus Calendar",
                    description: "Sync focus sessions with balance training",
                    iconName: "calendar",
                    isConnected: false
                )

                IntegrationCard(
                    title: "Immersive Topology",
                    description: "Visualize phase space in 3D",
                    iconName: "cube",
                    isConnected: false
                )
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - External Services Section
struct ExternalServicesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EXTERNAL SERVICES")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            VStack(spacing: 8) {
                IntegrationCard(
                    title: "Apple Health",
                    description: "Track balance training as mindfulness activity",
                    iconName: "heart.fill",
                    iconColor: .red,
                    isConnected: false
                )

                IntegrationCard(
                    title: "Firebase Cloud",
                    description: "Sync data across devices for research",
                    iconName: "cloud",
                    iconColor: .orange,
                    isConnected: false,
                    comingSoon: true
                )
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Hypergraph Section
struct HypergraphSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("THE HYPERGRAPH")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            Button(action: {
                if let url = URL(string: "https://www.golden-enterprises.net") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "globe")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.accentColor)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Visit The Hypergraph")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)

                        Text("golden-enterprises.net")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Integration Card
struct IntegrationCard: View {
    let title: String
    let description: String
    let iconName: String
    var iconColor: Color = .accentColor
    var isConnected: Bool = false
    var comingSoon: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 24))
                .foregroundStyle(iconColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)

                    if comingSoon {
                        Text("Coming Soon")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.orange))
                    }
                }

                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            if isConnected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .opacity(comingSoon ? 0.6 : 1.0)
    }
}

// MARK: - Preview
#Preview {
    IntegrationView()
}
