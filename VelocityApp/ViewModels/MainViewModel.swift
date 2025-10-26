//
//  MainViewModel.swift
//  Velocity
//
//  Main ViewModel for application state (MVVM)
//

import Foundation
import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    // Published properties
    @Published var mediaItems: [MediaItem] = []
    @Published var tracks: [Track] = []
    @Published var clips: [String: [Clip]] = [:]
    @Published var selectedClip: Clip?
    @Published var currentTool: EditTool = .select
    @Published var notification: String?

    // Playback state
    @Published var isPlaying = false
    @Published var playheadPosition: CGFloat = 160
    @Published var shuttleSpeed = 0 // -4 to 4

    // Timeline settings
    @Published var zoomLevel: Double = 1.0
    @Published var snapEnabled = true
    @Published var waveformsEnabled = true
    @Published var magneticEnabled = false
    @Published var proxyMode = true

    private var cancellables = Set<AnyCancellable>()
    private var playbackTimer: Timer?

    init() {
        loadDemoData()
        setupBindings()
    }

    // MARK: - Setup
    private func setupBindings() {
        // Auto-hide notifications
        $notification
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.notification = nil
            }
            .store(in: &cancellables)

        // Playback handling
        $isPlaying
            .sink { [weak self] playing in
                if playing {
                    self?.startPlayback()
                } else {
                    self?.stopPlayback()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Data Management
    func loadDemoData() {
        mediaItems = [
            MediaItem(id: UUID(), name: "A001_Interview.mp4", timecode: "00:02:34:12", type: .video, icon: "📹", hasProxy: true),
            MediaItem(id: UUID(), name: "B012_Broll_4K.mp4", timecode: "00:01:45:08", type: .video, icon: "📹", hasProxy: true),
            MediaItem(id: UUID(), name: "C004_Drone_8K.mp4", timecode: "00:00:58:22", type: .video, icon: "📹", hasProxy: true),
            MediaItem(id: UUID(), name: "Music_Track.wav", timecode: "00:04:20:00", type: .audio, icon: "🎵", hasProxy: false),
            MediaItem(id: UUID(), name: "VO_Main.wav", timecode: "00:02:15:10", type: .audio, icon: "🎵", hasProxy: false),
            MediaItem(id: UUID(), name: "SFX_Ambient.wav", timecode: "00:03:00:00", type: .audio, icon: "🔊", hasProxy: false)
        ]

        tracks = [
            Track(id: "v1", name: "V1", type: .video, icon: "🎬"),
            Track(id: "v2", name: "V2", type: .video, icon: "🎬"),
            Track(id: "a1", name: "A1", type: .audio, icon: "🎵"),
            Track(id: "a2", name: "A2", type: .audio, icon: "🎵")
        ]

        // Initialize empty clip arrays
        tracks.forEach { track in
            clips[track.id] = []
        }

        // Add demo clips
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.addDemoClips()
        }
    }

    private func addDemoClips() {
        if let videoMedia = mediaItems.first(where: { $0.name.contains("Interview") }) {
            addClip(mediaItem: videoMedia, toTrack: "v1", at: 20)
        }
        if let audioMedia = mediaItems.first(where: { $0.name.contains("Music") }) {
            addClip(mediaItem: audioMedia, toTrack: "a1", at: 20, duration: 450)
        }

        notification = "✓ Project loaded • Proxies enabled"
    }

    // MARK: - Clip Management
    func addClip(mediaItem: MediaItem, toTrack trackId: String, at position: CGFloat, duration: CGFloat = 220) {
        let clip = Clip(
            id: UUID(),
            name: mediaItem.name,
            trackId: trackId,
            startPosition: position,
            duration: duration,
            type: mediaItem.type
        )
        clips[trackId, default: []].append(clip)
    }

    func deleteClip(_ clip: Clip) {
        clips[clip.trackId]?.removeAll { $0.id == clip.id }
        if selectedClip?.id == clip.id {
            selectedClip = nil
        }
    }

    func moveClip(_ clip: Clip, toPosition position: CGFloat) {
        guard var trackClips = clips[clip.trackId],
              let index = trackClips.firstIndex(where: { $0.id == clip.id }) else {
            return
        }

        trackClips[index].startPosition = position
        clips[clip.trackId] = trackClips
    }

    // MARK: - Tool Management
    func selectTool(_ tool: EditTool) {
        currentTool = tool
        notification = "\(tool.rawValue) (\(tool.shortcut)) activated"
    }

    // MARK: - Playback
    private func startPlayback() {
        shuttleSpeed = 1
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            let speed = abs(self.shuttleSpeed)
            let direction: CGFloat = self.shuttleSpeed > 0 ? 1 : -1
            let speedMultiplier: CGFloat = [0, 1, 2, 4, 8][min(speed, 4)]

            self.playheadPosition += direction * speedMultiplier * 0.5

            // Stop at bounds
            if self.playheadPosition > 2800 || self.playheadPosition < 160 {
                self.isPlaying = false
                self.shuttleSpeed = 0
            }
        }
    }

    private func stopPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    func adjustShuttleSpeed(_ delta: Int) {
        shuttleSpeed = max(-4, min(4, shuttleSpeed + delta))
        notification = formatShuttleSpeed()
    }

    func stepFrame(_ direction: Int) {
        playheadPosition += CGFloat(direction) * 2
        notification = "\(direction > 0 ? "→" : "←") Frame"
    }

    private func formatShuttleSpeed() -> String {
        let speeds = ["<<<<", "<<<", "<<", "<", "||", ">", ">>", ">>>", ">>>>"]
        return speeds[shuttleSpeed + 4]
    }

    // MARK: - Timeline
    func adjustZoom(_ delta: Double) {
        zoomLevel = max(AppConstants.minZoom, min(AppConstants.maxZoom, zoomLevel + delta))
        notification = String(format: "Zoom: %.1fx", zoomLevel)
    }

    func toggleSetting(_ setting: TimelineSetting) {
        switch setting {
        case .snap:
            snapEnabled.toggle()
            notification = "Snap \(snapEnabled ? "ON" : "OFF")"
        case .waveforms:
            waveformsEnabled.toggle()
            notification = "Waveforms \(waveformsEnabled ? "ON" : "OFF")"
        case .magnetic:
            magneticEnabled.toggle()
            notification = "Magnetic \(magneticEnabled ? "ON" : "OFF")"
        case .proxy:
            proxyMode.toggle()
            notification = "Proxies \(proxyMode ? "ON" : "OFF")"
        }
    }

    // MARK: - Keyboard Shortcuts
    func handleKeyPress(_ key: String, modifiers: EventModifiers = []) {
        switch key.lowercased() {
        case " ":
            isPlaying.toggle()
        case "j":
            adjustShuttleSpeed(-1)
        case "l":
            adjustShuttleSpeed(1)
        case "k":
            shuttleSpeed = 0
            isPlaying = false
        case "i":
            notification = "◀ Mark In (I)"
        case "o":
            notification = "▶ Mark Out (O)"
        case "v":
            selectTool(.select)
        case "b":
            selectTool(.ripple)
        case "n":
            selectTool(.roll)
        case "y":
            selectTool(.slip)
        case "u":
            selectTool(.slide)
        case "c":
            selectTool(.blade)
        case "z" where modifiers.contains(.command):
            notification = modifiers.contains(.shift) ? "↷ Redo" : "↶ Undo"
        default:
            break
        }
    }

    deinit {
        playbackTimer?.invalidate()
    }
}

// MARK: - Timeline Setting
enum TimelineSetting {
    case snap
    case waveforms
    case magnetic
    case proxy
}
