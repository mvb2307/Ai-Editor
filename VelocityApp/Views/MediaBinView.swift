//
//  MediaBinView.swift
//  Velocity
//
//  Media bin panel with draggable items
//

import SwiftUI

struct MediaBinView: View {
    @EnvironmentObject var mainViewModel: MainViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Title
            Text("MEDIA BIN")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color(hex: "555"))
                .tracking(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Color(hex: "1c1c1c"))
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 1),
                    alignment: .bottom
                )

            // Media items
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(mainViewModel.mediaItems) { item in
                        MediaBinItemView(item: item)
                    }
                }
            }
        }
        .background(Color(hex: "141414"))
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 1),
            alignment: .trailing
        )
    }
}

struct MediaBinItemView: View {
    let item: MediaItem
    @State private var isHovered = false
    @State private var isDragging = false

    var body: some View {
        HStack(spacing: 10) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: "252525"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )

                Text(item.icon)
                    .font(.system(size: 13))
            }
            .frame(width: 44, height: 25)

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(item.timecode)
                        .font(.system(size: 9))
                        .foregroundColor(Color(hex: "555"))
                        .fontDesign(.monospaced)

                    if item.hasProxy {
                        Text("•")
                            .foregroundColor(Color(hex: "555"))
                        Text("PROXY")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(Color(hex: "fb923c"))
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(isHovered ? Color.white.opacity(0.025) : Color.clear)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1),
            alignment: .bottom
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .onDrag {
            isDragging = true
            return NSItemProvider(object: item.id.uuidString as NSString)
        }
        .opacity(isDragging ? 0.5 : 1.0)
    }
}
