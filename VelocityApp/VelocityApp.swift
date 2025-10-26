//
//  VelocityApp.swift
//  Velocity - Professional NLE
//
//  AI-powered video editing application
//

import SwiftUI

@main
struct VelocityApp: App {
    @StateObject private var mainViewModel = MainViewModel()
    @StateObject private var chatViewModel = ChatViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mainViewModel)
                .environmentObject(chatViewModel)
                .frame(minWidth: 1024, minHeight: 768)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            VelocityCommands()
        }
    }
}

// ViewModels are now in separate files

// MARK: - Commands
struct VelocityCommands: Commands {
    var body: some Commands {
        CommandMenu("Edit") {
            Button("Undo") {
                // Undo action
            }
            .keyboardShortcut("z", modifiers: .command)

            Button("Redo") {
                // Redo action
            }
            .keyboardShortcut("z", modifiers: [.command, .shift])
        }

        CommandMenu("View") {
            Button("Toggle Proxies") {
                // Toggle proxies
            }
            .keyboardShortcut("p", modifiers: [.command, .shift])
        }
    }
}
