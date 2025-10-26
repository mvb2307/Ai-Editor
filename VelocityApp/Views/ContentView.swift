//
//  ContentView.swift
//  Velocity
//
//  Main application view with adaptive layout
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var showShortcuts = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                HeaderView(showShortcuts: $showShortcuts)
                    .frame(height: 40)

                // Main content
                HStack(spacing: 0) {
                    // Media Bin (left panel)
                    MediaBinView()
                        .frame(width: max(200, geometry.size.width * 0.15))

                    // Center viewer section
                    ViewerSection()
                        .frame(maxWidth: .infinity)

                    // AI Panel (right panel)
                    AIChatView()
                        .frame(width: max(280, geometry.size.width * 0.2))
                }

                // Timeline
                TimelineView()
                    .frame(height: min(AppConstants.timelineHeight, geometry.size.height * 0.4))
            }
            .background(Color(hex: "0a0a0a"))
        }
        .sheet(isPresented: $showShortcuts) {
            ShortcutsView()
        }
        .overlay(alignment: .bottom) {
            if let notification = mainViewModel.notification {
                NotificationBanner(text: notification)
                    .padding(.bottom, AppConstants.timelineHeight + 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            chatViewModel.checkConnection()
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @Binding var showShortcuts: Bool

    var body: some View {
        HStack(spacing: 24) {
            // Logo
            HStack(spacing: 8) {
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "5b8dee"), Color(hex: "764ba2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 20, height: 20)
                    .cornerRadius(5)

                    Text("⚡")
                        .font(.system(size: 11))
                }

                Text("Velocity")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }

            // Menu
            HStack(spacing: 18) {
                MenuButton(title: "File")
                MenuButton(title: "Edit")
                MenuButton(title: "Clip")
                MenuButton(title: "Mark")
                MenuButton(title: "View")
            }
            .font(.system(size: 12))

            Spacer()

            // Status indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: "4ade80"))
                    .frame(width: 5, height: 5)
                    .opacity(0.8)
                    .animation(.easeInOut(duration: 2).repeatForever(), value: true)

                Text("Auto-Save On")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(hex: "4ade80"))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(hex: "4ade80").opacity(0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 11)
                    .stroke(Color(hex: "4ade80").opacity(0.25), lineWidth: 1)
            )
            .cornerRadius(11)
        }
        .padding(.horizontal, 16)
        .background(Color(hex: "141414"))
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

struct MenuButton: View {
    let title: String
    @State private var isHovered = false

    var body: some View {
        Text(title)
            .foregroundColor(isHovered ? Color(hex: "e8e8e8") : Color(hex: "8a8a8a"))
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - Notification Banner
struct NotificationBanner: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.93))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.6), radius: 16, x: 0, y: 8)
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: text)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
