//
//  ViewerSection.swift
//  Velocity
//
//  Source and Program viewers with playback controls
//

import SwiftUI

struct ViewerSection: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @Binding var notification: String?
    @State private var showSingleViewer = false

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            ToolbarView(showSingleViewer: $showSingleViewer, notification: $notification)
                .frame(height: 34)

            // Viewers
            GeometryReader { geometry in
                if showSingleViewer {
                    SingleViewerLayout(notification: $notification)
                } else {
                    DualViewerLayout(notification: $notification, width: geometry.size.width)
                }
            }
        }
        .background(Color(hex: "0a0a0a"))
    }
}

// MARK: - Toolbar
struct ToolbarView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @Binding var showSingleViewer: Bool
    @Binding var notification: String?

    var body: some View {
        HStack(spacing: 6) {
            // Tool group
            HStack(spacing: 3) {
                ForEach(EditTool.allCases, id: \.self) { tool in
                    ToolButton(
                        tool: tool,
                        isActive: mainViewModel.currentTool == tool,
                        notification: $notification
                    )
                }
            }
            .padding(4)
            .background(Color.white.opacity(0.02))
            .cornerRadius(6)

            Spacer()

            // Mode switch
            HStack(spacing: 3) {
                ModeButton(title: "Source/Program", isActive: !showSingleViewer) {
                    showSingleViewer = false
                }
                ModeButton(title: "Single", isActive: showSingleViewer) {
                    showSingleViewer = true
                }
            }
            .padding(3)
            .background(Color(hex: "1c1c1c"))
            .cornerRadius(7)

            Spacer()

            // Shortcuts button
            Button(action: {
                // Show shortcuts
            }) {
                Image(systemName: "keyboard")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "8a8a8a"))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 12)
        .background(Color(hex: "141414"))
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

struct ToolButton: View {
    let tool: EditTool
    let isActive: Bool
    @Binding var notification: String?
    @EnvironmentObject var mainViewModel: MainViewModel
    @State private var isHovered = false

    var body: some View {
        Button(action: {
            mainViewModel.currentTool = tool
            notification = "\(tool.rawValue) (\(tool.shortcut)) activated"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                notification = nil
            }
        }) {
            Image(systemName: tool.icon)
                .font(.system(size: 14))
                .foregroundColor(isActive ? Color(hex: "5b8dee") : (isHovered ? Color(hex: "e8e8e8") : Color(hex: "8a8a8a")))
                .frame(width: 28, height: 28)
                .background(isActive ? Color(hex: "5b8dee").opacity(0.16) : Color.clear)
                .cornerRadius(5)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct ModeButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(isActive ? Color(hex: "e8e8e8") : Color(hex: "8a8a8a"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isActive ? Color(hex: "252525") : Color.clear)
                .cornerRadius(5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Dual Viewer Layout
struct DualViewerLayout: View {
    @Binding var notification: String?
    let width: CGFloat

    var body: some View {
        HStack(spacing: 18) {
            ViewerWindow(title: "SOURCE", notification: $notification)
            ViewerWindow(title: "PROGRAM", notification: $notification)
        }
        .padding(18)
    }
}

// MARK: - Single Viewer Layout
struct SingleViewerLayout: View {
    @Binding var notification: String?

    var body: some View {
        ViewerWindow(title: "PROGRAM", notification: $notification)
            .padding(18)
    }
}

// MARK: - Viewer Window
struct ViewerWindow: View {
    let title: String
    @Binding var notification: String?
    @EnvironmentObject var mainViewModel: MainViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Black background
                Rectangle()
                    .fill(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )

                // Placeholder icon
                VStack {
                    Text("⏯")
                        .font(.system(size: 48))
                        .opacity(0.25)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Label
                Text(title)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.5))
                    .tracking(0.6)
                    .padding(8)

                // Controls
                ViewerControls(isProgram: title == "PROGRAM", notification: $notification)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 30)
            }
        }
        .aspectRatio(16/9, contentMode: .fit)
        .cornerRadius(4)
    }
}

struct ViewerControls: View {
    let isProgram: Bool
    @Binding var notification: String?
    @EnvironmentObject var mainViewModel: MainViewModel

    var body: some View {
        HStack(spacing: 8) {
            PlaybackButton(icon: "backward.end.fill")
            PlaybackButton(icon: "backward.fill")
            MainPlayButton(isPlaying: $mainViewModel.isPlaying, notification: $notification)
            PlaybackButton(icon: "forward.fill")
            PlaybackButton(icon: "forward.end.fill")

            if isProgram {
                Text(formatTimecode(mainViewModel.playheadPosition))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .fontDesign(.monospaced)
                    .padding(.horizontal, 10)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.88))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
    }

    func formatTimecode(_ position: CGFloat) -> String {
        let seconds = Int(position / AppConstants.pixelsPerSecond)
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:00:00", mins, secs)
    }
}

struct PlaybackButton: View {
    let icon: String
    @State private var isHovered = false

    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(isHovered ? Color.white.opacity(0.12) : Color.clear)
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct MainPlayButton: View {
    @Binding var isPlaying: Bool
    @Binding var notification: String?
    @State private var isHovered = false

    var body: some View {
        Button(action: {
            isPlaying.toggle()
            notification = isPlaying ? "▶ Playing" : "⏸ Paused"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                notification = nil
            }
        }) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 15))
                .foregroundColor(.white)
                .frame(width: 38, height: 38)
                .background(isHovered ? Color(hex: "4a7cd9") : Color(hex: "5b8dee"))
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
