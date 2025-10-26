//
//  ShortcutsView.swift
//  Velocity
//
//  Keyboard shortcuts reference modal
//

import SwiftUI

struct ShortcutsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Keyboard Shortcuts")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "8a8a8a"))
                        .frame(width: 30, height: 30)
                        .background(Color.white.opacity(0.05))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(28)
            .padding(.bottom, 0)

            // Shortcuts list
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ShortcutSection(
                        title: "J-K-L Shuttle Controls",
                        shortcuts: [
                            ("Play Forward", "L (2x 3x 4x)"),
                            ("Play Reverse", "J (2x 3x 4x)"),
                            ("Pause", "K"),
                            ("Frame Forward", "K+L"),
                            ("Frame Reverse", "K+J")
                        ]
                    )

                    ShortcutSection(
                        title: "Basic",
                        shortcuts: [
                            ("Play/Pause", "Space"),
                            ("Mark In", "I"),
                            ("Mark Out", "O")
                        ]
                    )

                    ShortcutSection(
                        title: "Tools",
                        shortcuts: [
                            ("Select Tool", "V"),
                            ("Ripple Edit", "B"),
                            ("Roll Edit", "N"),
                            ("Slip Edit", "Y"),
                            ("Slide Edit", "U"),
                            ("Blade Tool", "C")
                        ]
                    )

                    ShortcutSection(
                        title: "Workflow",
                        shortcuts: [
                            ("Toggle Proxies", "Cmd+Shift+P"),
                            ("Undo", "Cmd+Z"),
                            ("Redo", "Cmd+Shift+Z"),
                            ("Zoom In", "+"),
                            ("Zoom Out", "-")
                        ]
                    )
                }
                .padding(28)
            }
        }
        .frame(width: 620, height: 600)
        .background(Color(hex: "141414"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.8), radius: 30, x: 0, y: 20)
    }
}

struct ShortcutSection: View {
    let title: String
    let shortcuts: [(String, String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: "555"))
                .tracking(0.9)
                .textCase(.uppercase)

            VStack(spacing: 0) {
                ForEach(Array(shortcuts.enumerated()), id: \.offset) { index, shortcut in
                    ShortcutRow(action: shortcut.0, key: shortcut.1)

                    if index < shortcuts.count - 1 {
                        Divider()
                            .background(Color.white.opacity(0.06))
                    }
                }
            }
        }
    }
}

struct ShortcutRow: View {
    let action: String
    let key: String

    var body: some View {
        HStack {
            Text(action)
                .font(.system(size: 12))
                .foregroundColor(.white)

            Spacer()

            Text(key)
                .font(.system(size: 11, weight: .semibold))
                .fontDesign(.monospaced)
                .foregroundColor(Color(hex: "5b8dee"))
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Color(hex: "252525"))
                .cornerRadius(5)
        }
        .padding(.vertical, 10)
    }
}
