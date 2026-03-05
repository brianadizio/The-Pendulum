// MarkdownText.swift
// Golden Enterprises Theme System
// Lightweight markdown renderer for chat messages

import SwiftUI

/// Renders markdown text with headings, code blocks, bold, italic, and inline code
public struct MarkdownText: View {
    let content: String

    @Environment(\.goldenTheme) var theme

    public init(_ content: String) {
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            let blocks = parseBlocks(content)
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                switch block {
                case .heading(let level, let text):
                    headingView(level: level, text: text)
                case .codeBlock(let code):
                    codeBlockView(code)
                case .paragraph(let text):
                    inlineMarkdownView(text)
                }
            }
        }
    }

    // MARK: - Block Types

    enum Block {
        case heading(Int, String)
        case codeBlock(String)
        case paragraph(String)
    }

    // MARK: - Parser

    func parseBlocks(_ text: String) -> [Block] {
        var blocks: [Block] = []
        let lines = text.components(separatedBy: "\n")
        var i = 0
        var paragraphLines: [String] = []

        func flushParagraph() {
            let joined = paragraphLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            if !joined.isEmpty {
                blocks.append(.paragraph(joined))
            }
            paragraphLines = []
        }

        while i < lines.count {
            let line = lines[i]

            // Fenced code block
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                flushParagraph()
                var codeLines: [String] = []
                i += 1
                while i < lines.count && !lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    codeLines.append(lines[i])
                    i += 1
                }
                blocks.append(.codeBlock(codeLines.joined(separator: "\n")))
                i += 1 // skip closing ```
                continue
            }

            // Headings
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("### ") {
                flushParagraph()
                blocks.append(.heading(3, String(trimmed.dropFirst(4))))
            } else if trimmed.hasPrefix("## ") {
                flushParagraph()
                blocks.append(.heading(2, String(trimmed.dropFirst(3))))
            } else if trimmed.hasPrefix("# ") {
                flushParagraph()
                blocks.append(.heading(1, String(trimmed.dropFirst(2))))
            } else {
                paragraphLines.append(line)
            }

            i += 1
        }

        flushParagraph()
        return blocks
    }

    // MARK: - Block Views

    @ViewBuilder
    private func headingView(level: Int, text: String) -> some View {
        switch level {
        case 1:
            Text(text)
                .font(.title2.bold())
                .foregroundStyle(theme.text)
                .padding(.top, 4)
        case 2:
            Text(text)
                .font(.golden(.headline))
                .foregroundStyle(theme.text)
                .padding(.top, 2)
        default:
            Text(text)
                .font(.golden(.body))
                .bold()
                .foregroundStyle(theme.text)
        }
    }

    private func codeBlockView(_ code: String) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(code)
                .font(.system(.callout, design: .monospaced))
                .foregroundStyle(theme.text)
                .padding(GoldenTheme.spacing.small)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GoldenGeometry.cornerSmall, style: .continuous)
                .fill(theme.backgroundSecondary)
        )
    }

    @ViewBuilder
    private func inlineMarkdownView(_ text: String) -> some View {
        if let attributed = try? AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)) {
            Text(attributed)
                .font(.golden(.body))
                .foregroundStyle(theme.text)
        } else {
            Text(text)
                .font(.golden(.body))
                .foregroundStyle(theme.text)
        }
    }
}
