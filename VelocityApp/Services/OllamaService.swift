//
//  OllamaService.swift
//  Velocity
//
//  Ollama API integration for AI chat
//

import Foundation

class OllamaService: ObservableObject {
    @Published var isProcessing = false
    @Published var errorMessage: String?

    private let baseURL = "http://localhost:11434"
    private let model = "llama3.2:3b"

    func sendMessage(_ message: String) async -> String {
        isProcessing = true
        errorMessage = nil

        defer {
            DispatchQueue.main.async {
                self.isProcessing = false
            }
        }

        do {
            let response = try await generateResponse(prompt: message)
            return response
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            return "Error: \(error.localizedDescription)"
        }
    }

    private func generateResponse(prompt: String) async throws -> String {
        let url = URL(string: "\(baseURL)/api/generate")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let systemPrompt = """
        You are an AI assistant for Velocity, a professional video editing application.
        Help users with video editing tasks, explain features, and provide guidance on:
        - J-K-L shuttle controls for playback
        - Professional editing tools (Ripple, Roll, Slip, Slide, Blade)
        - Proxy workflows for better performance
        - Color grading and effects
        - Timeline management

        Keep responses concise and actionable. Use video editing terminology.
        """

        let requestBody: [String: Any] = [
            "model": model,
            "prompt": "\(systemPrompt)\n\nUser: \(prompt)\n\nAssistant:",
            "stream": false,
            "options": [
                "temperature": 0.7,
                "num_predict": 200
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OllamaError.invalidResponse
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let responseText = json["response"] as? String else {
            throw OllamaError.invalidData
        }

        return responseText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Check if Ollama is running
    func checkConnection() async -> Bool {
        guard let url = URL(string: "\(baseURL)/api/tags") else { return false }

        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else { return false }
            return httpResponse.statusCode == 200
        } catch {
            return false
        }
    }

    // Get context-aware responses for video editing
    func getEditingAdvice(context: EditingContext) async -> String {
        let prompt: String

        switch context {
        case .proxy:
            prompt = "User wants to know about proxy workflows in video editing. Explain briefly."
        case .shuttle:
            prompt = "Explain J-K-L shuttle controls for video playback."
        case .trimming:
            prompt = "Explain the difference between Ripple, Roll, Slip, and Slide editing tools."
        case .general(let question):
            prompt = question
        }

        return await sendMessage(prompt)
    }
}

enum EditingContext {
    case proxy
    case shuttle
    case trimming
    case general(String)
}

enum OllamaError: LocalizedError {
    case invalidResponse
    case invalidData
    case connectionFailed

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from Ollama. Make sure Ollama is running."
        case .invalidData:
            return "Could not parse response data."
        case .connectionFailed:
            return "Could not connect to Ollama. Run 'ollama serve' in terminal."
        }
    }
}
