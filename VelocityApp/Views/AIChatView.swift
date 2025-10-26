//
//  AIChatView.swift
//  Velocity
//
//  AI chat panel with Ollama integration
//

import SwiftUI

struct AIChatView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            // AI Header
            AIHeaderView()

            // AI Features
            AIFeaturesView()

            // Chat messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatViewModel.messages) { message in
                            ChatMessageView(message: message)
                                .id(message.id)
                        }

                        if chatViewModel.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "5b8dee")))
                                Text("AI is thinking...")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(hex: "8a8a8a"))
                            }
                            .padding()
                        }
                    }
                    .padding(16)
                }
                .onChange(of: chatViewModel.messages.count) { _ in
                    if let lastMessage = chatViewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Input area
            ChatInputView(
                inputText: $chatViewModel.inputText,
                isLoading: chatViewModel.isLoading,
                onSend: chatViewModel.sendMessage
            )
        }
        .background(Color(hex: "141414"))
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 1),
            alignment: .leading
        )
    }
}

// MARK: - AI Header
struct AIHeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(hex: "5b8dee"))
                    .frame(width: 36, height: 36)

                Text("🤖")
                    .font(.system(size: 18))
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text("AI Assistant")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)

                Text("Velocity Engine v2.0")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "8a8a8a"))
            }

            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "5b8dee").opacity(0.14),
                    Color(hex: "5b8dee").opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - AI Features
struct AIFeaturesView: View {
    @State private var selectedFeature: AIFeature?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI TOOLS")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(Color(hex: "555"))
                .tracking(0.9)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(AIFeature.allCases, id: \.self) { feature in
                    AIFeatureButton(feature: feature)
                }
            }
        }
        .padding(16)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

struct AIFeatureButton: View {
    let feature: AIFeature
    @State private var isHovered = false

    var body: some View {
        Button(action: {
            // Handle feature action
        }) {
            VStack(spacing: 5) {
                Image(systemName: feature.icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)

                Text(feature.rawValue)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isHovered ? Color(hex: "5b8dee").opacity(0.1) : Color.white.opacity(0.025))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(isHovered ? Color(hex: "5b8dee").opacity(0.4) : Color.white.opacity(0.06), lineWidth: 1)
            )
            .cornerRadius(7)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovered ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Chat Message
struct ChatMessageView: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            if !message.isUser {
                // AI Avatar
                Circle()
                    .fill(Color(hex: "5b8dee"))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("🤖")
                            .font(.system(size: 12))
                    )
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 7) {
                // Message bubble
                Text(message.content)
                    .font(.system(size: 11))
                    .foregroundColor(.white)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 9)
                    .background(message.isUser ? Color(hex: "5b8dee") : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(message.isUser ? Color.clear : Color.white.opacity(0.04), lineWidth: 1)
                    )
                    .cornerRadius(13)
                    .frame(maxWidth: message.isUser ? .infinity : .infinity, alignment: message.isUser ? .trailing : .leading)

                // Actions
                if !message.actions.isEmpty && !message.isUser {
                    HStack(spacing: 5) {
                        ForEach(message.actions, id: \.self) { action in
                            ActionButton(title: action)
                        }
                    }
                }
            }

            if message.isUser {
                // User Avatar
                Circle()
                    .fill(Color(hex: "252525"))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("👤")
                            .font(.system(size: 12))
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
    }
}

struct ActionButton: View {
    let title: String
    @State private var isHovered = false

    var body: some View {
        Button(action: {}) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color(hex: "5b8dee"))
                .padding(.horizontal, 11)
                .padding(.vertical, 5)
                .background(isHovered ? Color(hex: "5b8dee").opacity(0.22) : Color(hex: "5b8dee").opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "5b8dee").opacity(0.26), lineWidth: 1)
                )
                .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovered ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Chat Input
struct ChatInputView: View {
    @Binding var inputText: String
    let isLoading: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 9) {
            TextField("Type command or ask AI...", text: $inputText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 11))
                .foregroundColor(.white)
                .onSubmit(onSend)

            Button(action: onSend) {
                Image(systemName: "arrow.right")
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Color(hex: "5b8dee"))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            .opacity(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading ? 0.35 : 1.0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Color.white.opacity(0.028))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .cornerRadius(18)
        .padding(16)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1),
            alignment: .top
        )
    }
}
