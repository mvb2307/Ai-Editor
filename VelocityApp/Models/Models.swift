//
//  Models.swift
//  Velocity
//
//  Data models for the video editor
//

import Foundation
import SwiftUI

// MARK: - Media Item
struct MediaItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var timecode: String
    var type: MediaType
    var icon: String
    var hasProxy: Bool
}

// MARK: - Track
struct Track: Identifiable, Codable {
    let id: String
    var name: String
    var type: MediaType
    var icon: String
    var isLocked: Bool = false
    var isMuted: Bool = false
}

// MARK: - Clip
struct Clip: Identifiable, Codable {
    let id: UUID
    var name: String
    var trackId: String
    var startPosition: CGFloat
    var duration: CGFloat
    var type: MediaType
    var inPoint: CGFloat = 0
    var outPoint: CGFloat = 0
}

// MARK: - Media Type
enum MediaType: String, Codable {
    case video
    case audio
}

// MARK: - Edit Tool
enum EditTool: String, CaseIterable {
    case select = "Select"
    case ripple = "Ripple"
    case roll = "Roll"
    case slip = "Slip"
    case slide = "Slide"
    case blade = "Blade"

    var icon: String {
        switch self {
        case .select: return "arrow.up.left"
        case .ripple: return "arrow.left.and.right"
        case .roll: return "arrow.left.arrow.right"
        case .slip: return "arrow.up.and.down"
        case .slide: return "arrow.left.and.right.square"
        case .blade: return "scissors"
        }
    }

    var shortcut: String {
        switch self {
        case .select: return "V"
        case .ripple: return "B"
        case .roll: return "N"
        case .slip: return "Y"
        case .slide: return "U"
        case .blade: return "C"
        }
    }
}

// MARK: - Chat Message
struct ChatMessage: Identifiable {
    let id = UUID()
    var content: String
    var isUser: Bool
    var actions: [String] = []
    var timestamp = Date()
}

// MARK: - AI Feature
enum AIFeature: String, CaseIterable {
    case proxy = "Proxy"
    case autoCut = "Auto Cut"
    case sync = "Sync"
    case color = "Color"

    var icon: String {
        switch self {
        case .proxy: return "gearshape"
        case .autoCut: return "scissors"
        case .sync: return "arrow.triangle.2.circlepath"
        case .color: return "paintpalette"
        }
    }
}

// MARK: - Constants
struct AppConstants {
    static let timelineHeight: CGFloat = 360
    static let trackHeight: CGFloat = 64
    static let rulerHeight: CGFloat = 28
    static let minZoom: Double = 0.5
    static let maxZoom: Double = 4.0
    static let pixelsPerSecond: CGFloat = 20
    static let framerate: Double = 30.0
}
