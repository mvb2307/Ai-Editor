//
//  ChatViewModel.swift
//  Velocity
//
//  ViewModel for AI chat interactions (MVVM)
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""
    @Published var isLoading = false
    @Published var isOllamaConnected = false

    private let ollamaService: OllamaService
    private var cancellables = Set<AnyCancellable>()

    init(ollamaService: OllamaService = OllamaService()) {
        self.ollamaService = ollamaService
        setupBindings()
        checkConnection()
        addWelcomeMessage()
    }

    // MARK: - Setup
    private func setupBindings() {
        // Observe Ollama service state
        ollamaService.$isProcessing
            .assign(to: &$isLoading)

        ollamaService.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.addSystemMessage("Error: \(error)")
            }
            .store(in: &cancellables)
    }

    // MARK: - Connection
    func checkConnection() {
        Task {
            let connected = await ollamaService.checkConnection()
            await MainActor.run {
                isOllamaConnected = connected
                if !connected {
                    addSystemMessage("⚠️ Ollama not detected. Run 'ollama serve' in terminal.")
                }
            }
        }
    }

    // MARK: - Messages
    private func addWelcomeMessage() {
        let welcome = ChatMessage(
            content: "Velocity ready! Try J-K-L shuttle controls (press L multiple times for 2x, 4x, 8x speed). Drag clips to timeline or ask me for help.",
            isUser: false
        )
        messages.append(welcome)
    }

    func addUserMessage(_ text: String) {
        let message = ChatMessage(content: text, isUser: true)
        messages.append(message)
    }

    func addAIMessage(_ text: String, actions: [String] = []) {
        let message = ChatMessage(content: text, isUser: false, actions: actions)
        messages.append(message)
    }

    private func addSystemMessage(_ text: String) {
        let message = ChatMessage(content: text, isUser: false)
        messages.append(message)
    }

    // MARK: - Send Message
    func sendMessage() {
        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }

        // Add user message
        addUserMessage(trimmedInput)

        // Check for quick responses first
        if let quickResponse = getQuickResponse(for: trimmedInput) {
            inputText = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.addAIMessage(quickResponse.content, actions: quickResponse.actions)
            }
            return
        }

        // Clear input
        let query = trimmedInput
        inputText = ""

        // Send to Ollama
        Task {
            let response = await ollamaService.sendMessage(query)

            await MainActor.run {
                addAIMessage(response, actions: ["Apply", "More Info"])
            }
        }
    }

    // MARK: - Quick Responses
    private func getQuickResponse(for input: String) -> (content: String, actions: [String])? {
        let lower = input.lowercased()

        if lower.contains("proxy") || lower.contains("proxies") {
            return (
                "Creating 1080p H.264 proxies for all 4K+ clips reduces file size by 95% and speeds up editing 60-70% while preserving quality on export. Your timeline will play much smoother!",
                ["Create Now", "Settings"]
            )
        }

        if lower.contains("jkl") || lower.contains("shuttle") {
            return (
                "J-K-L shuttle: Press L for forward (2x 4x 8x with multiple taps), J for reverse (2x 4x 8x). Hold K and tap J/L for frame-by-frame. This is the industry standard for precise playback control!",
                ["Show Demo", "Practice"]
            )
        }

        if lower.contains("ripple") || lower.contains("trim") || lower.contains("edit") {
            return (
                "Edit tools: Ripple (B) - trim and auto-close gaps. Roll (N) - adjust cut point between clips. Slip (Y) - change clip content without moving position. Slide (U) - reposition clip, adjusts neighbors.",
                ["Try It", "Video Tutorial"]
            )
        }

        if lower.contains("color") || lower.contains("grade") {
            return (
                "AI color grading can apply cinematic LUTs, match colors between shots, and enhance your footage. I can lift blacks, add warm tones, and boost contrast for a professional look.",
                ["Apply Color Grade", "Custom Settings"]
            )
        }

        if lower.contains("sync") || lower.contains("multicam") {
            return (
                "I can sync multicam footage by analyzing audio waveforms for frame-accurate alignment. This works even if cameras started at different times!",
                ["Sync Now", "Advanced Options"]
            )
        }

        return nil
    }

    // MARK: - Feature Actions
    func handleFeatureAction(_ feature: AIFeature) {
        let responses: [AIFeature: (content: String, actions: [String])] = [
            .proxy: (
                "Creating 1080p proxies for 4K/8K clips...\n\nProxies created! Playback 60% faster. Export uses full resolution.",
                ["Preview", "Apply"]
            ),
            .autoCut: (
                "Analyzing waveforms for optimal cut points...\n\nFound 12 optimal cut points based on silence detection and rhythm analysis. Review and apply?",
                ["Preview Cuts", "Apply", "Adjust Sensitivity"]
            ),
            .sync: (
                "Syncing multicam by audio waveform...\n\nMulticam synced! All angles aligned to frame accuracy.",
                ["Preview Sync", "Apply"]
            ),
            .color: (
                "Applying cinematic LUT with lifted blacks...\n\nColor grade applied! Warm tones, +0.5 contrast, lifted blacks for a professional cinematic look.",
                ["Preview", "Apply", "Customize"]
            )
        ]

        if let response = responses[feature] {
            addSystemMessage(response.content)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.addAIMessage(response.content, actions: response.actions)
            }
        }
    }

    // MARK: - Context-Aware Help
    func getContextualHelp(for context: EditingContext) {
        Task {
            let response = await ollamaService.getEditingAdvice(context: context)
            await MainActor.run {
                addAIMessage(response, actions: ["Learn More", "Try It"])
            }
        }
    }
}
