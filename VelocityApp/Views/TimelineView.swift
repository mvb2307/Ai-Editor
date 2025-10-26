//
//  TimelineView.swift
//  Velocity
//
//  Timeline with tracks, clips, and playhead
//

import SwiftUI
import UniformTypeIdentifiers

struct TimelineView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @Binding var notification: String?

    var body: some View {
        VStack(spacing: 0) {
            // Timeline header with controls
            TimelineHeaderView(notification: $notification)

            // Ruler
            TimelineRulerView()

            // Tracks
            ScrollView([.horizontal, .vertical]) {
                ZStack(alignment: .topLeading) {
                    // Tracks content
                    VStack(spacing: 0) {
                        ForEach(mainViewModel.tracks) { track in
                            TrackView(track: track, notification: $notification)
                        }
                    }

                    // Playhead
                    PlayheadView()
                        .offset(x: mainViewModel.playheadPosition)
                }
            }
        }
        .background(Color(hex: "141414"))
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1),
            alignment: .top
        )
    }
}

// MARK: - Timeline Header
struct TimelineHeaderView: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    @Binding var notification: String?

    var body: some View {
        HStack(spacing: 7) {
            ToggleButton(title: "Snap", isActive: $mainViewModel.snapEnabled, notification: $notification)
            ToggleButton(title: "Waveforms", isActive: $mainViewModel.waveformsEnabled, notification: $notification)
            ToggleButton(title: "Magnetic", isActive: $mainViewModel.magneticEnabled, notification: $notification)

            // Proxy indicator
            HStack(spacing: 6) {
                Image(systemName: "gearshape")
                    .font(.system(size: 9))
                Text("Proxies: ON")
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundColor(Color(hex: "fb923c"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(hex: "fb923c").opacity(0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "fb923c").opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(10)

            Spacer()

            // Zoom controls
            HStack(spacing: 7) {
                ZoomButton(icon: "minus") {
                    adjustZoom(-0.25)
                }

                Text(String(format: "%.1fx", mainViewModel.zoomLevel))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(Color(hex: "8a8a8a"))
                    .fontDesign(.monospaced)
                    .frame(minWidth: 48)

                ZoomButton(icon: "plus") {
                    adjustZoom(0.25)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Color(hex: "141414"))
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private func adjustZoom(_ delta: Double) {
        mainViewModel.zoomLevel = max(AppConstants.minZoom, min(AppConstants.maxZoom, mainViewModel.zoomLevel + delta))
        notification = String(format: "Zoom: %.1fx", mainViewModel.zoomLevel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            notification = nil
        }
    }
}

struct ToggleButton: View {
    let title: String
    @Binding var isActive: Bool
    @Binding var notification: String?
    @State private var isHovered = false

    var body: some View {
        Button(action: {
            isActive.toggle()
            notification = "\(title) \(isActive ? "ON" : "OFF")"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                notification = nil
            }
        }) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(isActive ? Color(hex: "5b8dee") : Color(hex: "8a8a8a"))
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(isActive ? Color(hex: "5b8dee").opacity(0.14) : (isHovered ? Color.white.opacity(0.045) : Color.white.opacity(0.025)))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isActive ? Color(hex: "5b8dee").opacity(0.35) : Color.white.opacity(0.06), lineWidth: 1)
                )
                .cornerRadius(5)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct ZoomButton: View {
    let icon: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(isHovered ? Color(hex: "e8e8e8") : Color(hex: "8a8a8a"))
                .frame(width: 24, height: 24)
                .background(isHovered ? Color.white.opacity(0.05) : Color.white.opacity(0.025))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .cornerRadius(5)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Timeline Ruler
struct TimelineRulerView: View {
    @EnvironmentObject var mainViewModel: MainViewModel

    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 0) {
                ForEach(0..<120, id: \.self) { i in
                    if i % 10 == 0 {
                        Text(formatTimecode(i))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(Color(hex: "555"))
                            .fontDesign(.monospaced)
                            .frame(width: 75, alignment: .leading)
                    }
                }
            }
            .padding(.leading, 12)
        }
        .frame(height: AppConstants.rulerHeight)
        .background(Color(hex: "1c1c1c"))
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private func formatTimecode(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

// MARK: - Track View
struct TrackView: View {
    let track: Track
    @Binding var notification: String?
    @EnvironmentObject var mainViewModel: MainViewModel

    var body: some View {
        HStack(spacing: 0) {
            // Track header
            VStack(spacing: 4) {
                Text(track.icon)
                    .font(.system(size: 15))

                Text(track.name)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Color(hex: "555"))
                    .tracking(0.5)
            }
            .frame(width: 75)
            .frame(height: AppConstants.trackHeight)
            .background(Color(hex: "1c1c1c"))
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 1),
                alignment: .trailing
            )

            // Track lane
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(minWidth: 2800, maxWidth: .infinity)
                    .frame(height: AppConstants.trackHeight)
                    .onDrop(of: [UTType.text], delegate: TrackDropDelegate(
                        track: track,
                        mainViewModel: mainViewModel,
                        notification: $notification
                    ))

                // Clips
                ForEach(mainViewModel.clips[track.id] ?? [], id: \.id) { clip in
                    ClipView(clip: clip)
                }
            }
        }
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

// MARK: - Clip View
struct ClipView: View {
    let clip: Clip
    @State private var isHovered = false
    @State private var isDragging = false
    @EnvironmentObject var mainViewModel: MainViewModel

    var body: some View {
        ZStack(alignment: .leading) {
            // Clip background
            LinearGradient(
                colors: clip.type == .video ?
                    [Color(hex: "3d5a80"), Color(hex: "2c4563")] :
                    [Color(hex: "98c1d9"), Color(hex: "7ba8c2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        mainViewModel.selectedClip?.id == clip.id ? Color(hex: "5b8dee") :
                            (isHovered ? Color(hex: "5b8dee") : Color.white.opacity(0.12)),
                        lineWidth: mainViewModel.selectedClip?.id == clip.id ? 2 : 1
                    )
            )
            .cornerRadius(4)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

            // Clip name
            Text(clip.name)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                .padding(.leading, 9)

            // Waveform for audio
            if clip.type == .audio {
                WaveformView()
                    .padding(.horizontal, 9)
                    .padding(.bottom, 4)
            }
        }
        .frame(width: clip.duration, height: clip.type == .video ? 48 : 30)
        .offset(x: clip.startPosition, y: 8)
        .opacity(isDragging ? 0.6 : 1.0)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            mainViewModel.selectedClip = clip
        }
    }
}

struct WaveformView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 1) {
            ForEach(0..<35, id: \.self) { _ in
                Rectangle()
                    .fill(Color.white.opacity(0.45))
                    .frame(width: 2, height: CGFloat.random(in: 4...15))
                    .cornerRadius(1)
            }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

// MARK: - Playhead
struct PlayheadView: View {
    @EnvironmentObject var mainViewModel: MainViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Triangle
            Path { path in
                path.move(to: CGPoint(x: 6, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 7))
                path.addLine(to: CGPoint(x: 12, y: 7))
                path.closeSubpath()
            }
            .fill(Color(hex: "5b8dee"))

            // Line
            Rectangle()
                .fill(Color(hex: "5b8dee"))
                .frame(width: 2)
                .shadow(color: Color(hex: "5b8dee").opacity(0.6), radius: 4, x: 0, y: 0)
        }
        .offset(x: -6) // Center the playhead
    }
}

// MARK: - Drop Delegate
struct TrackDropDelegate: DropDelegate {
    let track: Track
    let mainViewModel: MainViewModel
    @Binding var notification: String?

    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [UTType.text]).first else {
            return false
        }

        itemProvider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { data, error in
            guard let data = data as? Data,
                  let uuidString = String(data: data, encoding: .utf8),
                  let mediaId = UUID(uuidString: uuidString),
                  let media = mainViewModel.mediaItems.first(where: { $0.id == mediaId }) else {
                return
            }

            let location = info.location
            let position = max(0, location.x - 60)

            DispatchQueue.main.async {
                mainViewModel.addClip(mediaItem: media, toTrack: track.id, at: position)
                notification = "✓ \(media.name) → \(track.name)"

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    notification = nil
                }
            }
        }

        return true
    }
}
