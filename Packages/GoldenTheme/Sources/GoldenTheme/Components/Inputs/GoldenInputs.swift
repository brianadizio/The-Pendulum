// GoldenInputs.swift
// Golden Enterprises Theme System
// Normalized, canonical form inputs - sliders, text fields, pickers

import SwiftUI

// MARK: - Text Field

/// Golden themed text field
public struct GoldenTextField: View {
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType

    @Environment(\.goldenTheme) var theme
    @FocusState private var isFocused: Bool

    public init(
        _ placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) {
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
    }

    public var body: some View {
        SwiftUI.TextField(placeholder, text: $text)
            .font(.golden(.body))
            .foregroundStyle(theme.text)
            .keyboardType(keyboardType)
            .focused($isFocused)
            .padding(.horizontal, GoldenTheme.spacing.medium)
            .padding(.vertical, GoldenTheme.spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous)
                    .fill(theme.backgroundTertiary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous)
                    .stroke(isFocused ? theme.accent : theme.backgroundSecondary, lineWidth: isFocused ? 2 : 1)
            )
            .animation(.goldenSpringQuick, value: isFocused)
    }
}

// MARK: - Slider

/// Golden themed slider with value display
public struct GoldenSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double?
    let valueFormatter: (Double) -> String

    @Environment(\.goldenTheme) var theme

    public init(
        _ title: String,
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double? = nil,
        format: @escaping (Double) -> String = { String(format: "%.1f", $0) }
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.valueFormatter = format
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: GoldenTheme.spacing.small) {
            HStack {
                Text(title)
                    .font(.golden(.body))
                    .foregroundStyle(theme.text)

                Spacer()

                Text(valueFormatter(value))
                    .font(.goldenMono(size: GoldenTypography.bodySize))
                    .foregroundStyle(theme.accent)
            }

            Group {
                if let step = step {
                    SwiftUI.Slider(value: $value, in: range, step: step)
                } else {
                    SwiftUI.Slider(value: $value, in: range)
                }
            }
            .tint(theme.accent)
        }
        .padding(.horizontal, GoldenTheme.spacing.medium)
        .padding(.vertical, GoldenTheme.spacing.medium)
        .background(theme.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous))
        .onChange(of: value) { _, _ in
            HapticManager.shared.play(.selection)
        }
    }
}

// MARK: - Stepper

/// Golden themed stepper
public struct GoldenStepper: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    @Environment(\.goldenTheme) var theme

    public init(_ title: String, value: Binding<Int>, in range: ClosedRange<Int>) {
        self.title = title
        self._value = value
        self.range = range
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(.golden(.body))
                .foregroundStyle(theme.text)

            Spacer()

            Text("\(value)")
                .font(.goldenMono(size: GoldenTypography.bodySize))
                .foregroundStyle(theme.accent)
                .frame(minWidth: 30)

            Stepper("", value: $value, in: range)
                .labelsHidden()
        }
        .padding(.horizontal, GoldenTheme.spacing.medium)
        .padding(.vertical, GoldenTheme.spacing.medium)
        .background(theme.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous))
        .onChange(of: value) { _, _ in
            HapticManager.shared.play(.selection)
        }
    }
}

// MARK: - Picker (Segmented)

/// Golden themed segmented picker
public struct GoldenSegmentedPicker<T: Hashable>: View {
    let title: String?
    @Binding var selection: T
    let options: [T]
    let labelProvider: (T) -> String

    @Environment(\.goldenTheme) var theme

    public init(
        _ title: String? = nil,
        selection: Binding<T>,
        options: [T],
        label: @escaping (T) -> String
    ) {
        self.title = title
        self._selection = selection
        self.options = options
        self.labelProvider = label
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: GoldenTheme.spacing.small) {
            if let title = title {
                Text(title)
                    .font(.golden(.caption))
                    .foregroundStyle(theme.textSecondary)
            }

            HStack(spacing: 2) {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        withAnimation(.goldenSpringQuick) {
                            selection = option
                        }
                        HapticManager.shared.play(.selection)
                    }) {
                        Text(labelProvider(option))
                            .font(.golden(.caption))
                            .fontWeight(selection == option ? .semibold : .regular)
                            .foregroundStyle(selection == option ? theme.text : theme.textSecondary)
                            .padding(.horizontal, GoldenTheme.spacing.medium)
                            .padding(.vertical, GoldenTheme.spacing.small)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: GoldenGeometry.cornerSmall, style: .continuous)
                                    .fill(selection == option ? theme.backgroundTertiary : Color.clear)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous)
                    .fill(theme.backgroundSecondary)
            )
        }
    }
}

// MARK: - Search Field

/// Golden themed search field
public struct GoldenSearchField: View {
    @Binding var text: String
    let placeholder: String

    @Environment(\.goldenTheme) var theme
    @FocusState private var isFocused: Bool

    public init(_ placeholder: String = "Search", text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        HStack(spacing: GoldenTheme.spacing.small) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(theme.textTertiary)

            SwiftUI.TextField(placeholder, text: $text)
                .font(.golden(.body))
                .foregroundStyle(theme.text)
                .focused($isFocused)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                    HapticManager.shared.play(.light)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(theme.textTertiary)
                }
            }
        }
        .padding(.horizontal, GoldenTheme.spacing.medium)
        .padding(.vertical, GoldenTheme.spacing.small + 2)
        .background(
            RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous)
                .fill(theme.backgroundSecondary)
        )
    }
}

// MARK: - Date Picker Row

/// Golden themed date picker in settings style
public struct GoldenDatePickerRow: View {
    let title: String
    @Binding var date: Date

    @Environment(\.goldenTheme) var theme

    public init(_ title: String, selection: Binding<Date>) {
        self.title = title
        self._date = selection
    }

    public var body: some View {
        HStack {
            Text(title)
                .font(.golden(.body))
                .foregroundStyle(theme.text)

            Spacer()

            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .tint(theme.accent)
        }
        .padding(.horizontal, GoldenTheme.spacing.medium)
        .padding(.vertical, GoldenTheme.spacing.small)
        .background(theme.backgroundTertiary)
        .clipShape(RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous))
    }
}

// MARK: - Multi-line Text Editor

/// Golden themed text editor for longer input
public struct GoldenTextEditor: View {
    let placeholder: String
    @Binding var text: String
    let minHeight: CGFloat

    @Environment(\.goldenTheme) var theme
    @FocusState private var isFocused: Bool

    public init(_ placeholder: String, text: Binding<String>, minHeight: CGFloat = 100) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.golden(.body))
                    .foregroundStyle(theme.textTertiary)
                    .padding(.horizontal, GoldenTheme.spacing.medium)
                    .padding(.vertical, GoldenTheme.spacing.medium)
            }

            TextEditor(text: $text)
                .font(.golden(.body))
                .foregroundStyle(theme.text)
                .focused($isFocused)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, GoldenTheme.spacing.small)
                .padding(.vertical, GoldenTheme.spacing.small)
        }
        .frame(minHeight: minHeight)
        .background(
            RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous)
                .fill(theme.backgroundTertiary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: GoldenGeometry.cornerMedium, style: .continuous)
                .stroke(isFocused ? theme.accent : theme.backgroundSecondary, lineWidth: isFocused ? 2 : 1)
        )
    }
}
