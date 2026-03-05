// GoldenLoading.swift
// Golden Enterprises Theme System
// Loading indicators including logo morphing video support

import SwiftUI
import AVKit

// MARK: - Shimmer Loading Effect

/// Shimmer effect that sweeps across content (like Claude/ChatGPT)
public struct ShimmerEffect: View {
    @State private var phase: CGFloat = -1

    @Environment(\.goldenTheme) var theme

    public init() {}

    public var body: some View {
        LinearGradient(
            colors: [
                .clear,
                theme.accent.opacity(0.3),
                theme.accent.opacity(0.5),
                theme.accent.opacity(0.3),
                .clear
            ],
            startPoint: .init(x: phase - 0.5, y: 0.5),
            endPoint: .init(x: phase + 0.5, y: 0.5)
        )
        .onAppear {
            withAnimation(
                .linear(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                phase = 2
            }
        }
    }
}

// MARK: - Text Shimmer (Claude-style loading text)

/// Shimmer highlight that sweeps through text while loading
public struct ShimmerText: View {
    let text: String
    let isLoading: Bool

    @State private var phase: CGFloat = 0
    @Environment(\.goldenTheme) var theme

    public init(_ text: String, isLoading: Bool = false) {
        self.text = text
        self.isLoading = isLoading
    }

    public var body: some View {
        Text(text)
            .font(.golden(.body))
            .foregroundStyle(theme.text)
            .overlay(
                GeometryReader { geometry in
                    if isLoading {
                        LinearGradient(
                            colors: [
                                .clear,
                                theme.accent.opacity(0.6),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 60)
                        .offset(x: phase * geometry.size.width - 30)
                        .mask(Text(text).font(.golden(.body)))
                    }
                }
            )
            .onAppear {
                if isLoading {
                    withAnimation(
                        .linear(duration: 1.2)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
            }
            .onChange(of: isLoading) { _, newValue in
                if newValue {
                    phase = 0
                    withAnimation(
                        .linear(duration: 1.2)
                        .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
            }
    }
}

// MARK: - Logo Video Loading

/// Loading view that plays a morphing logo video
public struct LogoVideoLoading: View {
    let videoName: String
    let videoExtension: String

    @State private var player: AVPlayer?
    @Environment(\.goldenTheme) var theme

    public init(videoName: String, extension ext: String = "mp4") {
        self.videoName = videoName
        self.videoExtension = ext
    }

    public var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                // Fallback to simple spinner
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.accent))
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            loadVideo()
        }
    }

    private func loadVideo() {
        guard let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) else {
            return
        }

        let avPlayer = AVPlayer(url: url)
        avPlayer.actionAtItemEnd = .none

        // Loop the video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: avPlayer.currentItem,
            queue: .main
        ) { _ in
            avPlayer.seek(to: .zero)
            avPlayer.play()
        }

        player = avPlayer
    }
}

// MARK: - Simple Spinner

/// Simple golden-themed spinner
public struct GoldenSpinner: View {
    @State private var isRotating = false
    @Environment(\.goldenTheme) var theme

    public init() {}

    public var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                AngularGradient(
                    colors: [theme.accent, theme.accent.opacity(0.1)],
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .frame(width: 40, height: 40)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .onAppear {
                withAnimation(
                    .linear(duration: 1)
                    .repeatForever(autoreverses: false)
                ) {
                    isRotating = true
                }
            }
    }
}

// MARK: - Pulsing Dot Loading

/// Three dots that pulse in sequence
public struct PulsingDotsLoading: View {
    @State private var phase = 0
    @Environment(\.goldenTheme) var theme

    private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    public init() {}

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(theme.accent)
                    .frame(width: 10, height: 10)
                    .scaleEffect(phase == index ? 1.3 : 1.0)
                    .opacity(phase == index ? 1.0 : 0.5)
                    .animation(.goldenSpringQuick, value: phase)
            }
        }
        .onReceive(timer) { _ in
            phase = (phase + 1) % 3
        }
    }
}

// MARK: - Full Screen Loading Overlay

/// Full-screen loading overlay with optional logo video
public struct GoldenLoadingOverlay: View {
    let message: String?
    let videoName: String?
    let isVisible: Bool

    @Environment(\.goldenTheme) var theme

    public init(
        isVisible: Bool,
        message: String? = nil,
        videoName: String? = nil
    ) {
        self.isVisible = isVisible
        self.message = message
        self.videoName = videoName
    }

    public var body: some View {
        Group {
            if isVisible {
                ZStack {
                    // Dimmed background
                    theme.background.opacity(0.9)
                        .ignoresSafeArea()

                    VStack(spacing: GoldenTheme.spacing.large) {
                        // Loading indicator
                        if let videoName = videoName {
                            LogoVideoLoading(videoName: videoName)
                        } else {
                            GoldenSpinner()
                        }

                        // Optional message with shimmer
                        if let message = message {
                            ShimmerText(message, isLoading: true)
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
}

// MARK: - Skeleton Loading

/// Skeleton placeholder for content loading
public struct SkeletonView: View {
    let width: CGFloat?
    let height: CGFloat

    @Environment(\.goldenTheme) var theme

    public init(width: CGFloat? = nil, height: CGFloat = 20) {
        self.width = width
        self.height = height
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: height / 4, style: .continuous)
            .fill(theme.backgroundSecondary)
            .frame(width: width, height: height)
            .overlay(ShimmerEffect())
            .clipShape(RoundedRectangle(cornerRadius: height / 4, style: .continuous))
    }
}

/// Card-shaped skeleton for loading cards
public struct SkeletonCard: View {
    @Environment(\.goldenTheme) var theme

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: GoldenTheme.spacing.medium) {
            SkeletonView(height: 24)
            SkeletonView(width: 200, height: 16)
            SkeletonView(width: 150, height: 16)
        }
        .padding(GoldenTheme.spacing.medium)
        .background(theme.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous))
    }
}
