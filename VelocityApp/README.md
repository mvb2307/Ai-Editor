# Velocity - Professional NLE with AI

A professional-grade video editing application built with SwiftUI featuring AI-powered editing assistance through Ollama integration.

## Features

- **Professional Timeline**: Multi-track video and audio timeline with drag-and-drop support
- **J-K-L Shuttle Controls**: Industry-standard playback controls with variable speed (2x, 4x, 8x)
- **Professional Edit Tools**:
  - Select Tool (V)
  - Ripple Edit (B)
  - Roll Edit (N)
  - Slip Edit (Y)
  - Slide Edit (U)
  - Blade Tool (C)
- **AI Assistant**: Powered by Ollama (llama3.2:3b) for intelligent editing suggestions
- **Proxy Workflow**: Automatic proxy generation for 4K/8K footage
- **Responsive Design**: Adapts to any screen size from iPad to 5K displays
- **Source/Program Monitors**: Dual viewer layout for professional editing
- **MVVM Architecture**: Clean, maintainable code structure

## Requirements

- macOS 13.0+ or iOS 16.0+
- Xcode 15.0+
- Ollama installed and running

## Setup Instructions

### 1. Install Ollama

```bash
# macOS
brew install ollama

# Or download from https://ollama.ai
```

### 2. Pull the AI Model

```bash
ollama pull llama3.2:3b
```

### 3. Start Ollama Service

```bash
ollama serve
```

Keep this running in a terminal window while using Velocity.

### 4. Build the App

1. Open Xcode
2. Create a new macOS or iOS App project named "Velocity"
3. Copy all files from `VelocityApp/` to your project:
   - `VelocityApp.swift` (replace the default App file)
   - `Models/` folder
   - `Views/` folder
   - `ViewModels/` folder
   - `Services/` folder
   - `Info.plist`

4. Add the files to your project in Xcode
5. Set the minimum deployment target:
   - macOS: 13.0
   - iOS: 16.0

6. Build and run (⌘R)

## Project Structure

```
VelocityApp/
├── VelocityApp.swift          # Main app entry point
├── Models/
│   └── Models.swift            # Data models (MediaItem, Track, Clip, etc.)
├── ViewModels/
│   ├── MainViewModel.swift     # Main app state management
│   └── ChatViewModel.swift     # AI chat management
├── Services/
│   └── OllamaService.swift     # Ollama API integration
├── Views/
│   ├── ContentView.swift       # Main layout
│   ├── MediaBinView.swift      # Media library panel
│   ├── ViewerSection.swift     # Source/Program viewers
│   ├── AIChatView.swift        # AI assistant panel
│   ├── TimelineView.swift      # Timeline editor
│   └── ShortcutsView.swift     # Keyboard shortcuts modal
└── Info.plist                  # App configuration
```

## Architecture: MVVM

The app follows the Model-View-ViewModel pattern:

- **Models**: Pure data structures (MediaItem, Track, Clip)
- **ViewModels**: Business logic and state management
  - `MainViewModel`: Manages overall app state, playback, timeline
  - `ChatViewModel`: Handles AI chat interactions
- **Views**: SwiftUI views that observe ViewModels
- **Services**: External integrations (OllamaService)

## Keyboard Shortcuts

### J-K-L Shuttle Controls
- **L**: Play forward (press multiple times for 2x, 4x, 8x)
- **J**: Play reverse (press multiple times for 2x, 4x, 8x)
- **K**: Pause
- **K+L**: Step forward one frame
- **K+J**: Step backward one frame

### Basic Controls
- **Space**: Play/Pause
- **I**: Mark In
- **O**: Mark Out

### Edit Tools
- **V**: Select Tool
- **B**: Ripple Edit
- **N**: Roll Edit
- **Y**: Slip Edit
- **U**: Slide Edit
- **C**: Blade Tool

### Workflow
- **⌘Z**: Undo
- **⌘⇧Z**: Redo
- **⌘⇧P**: Toggle Proxies
- **?**: Show Shortcuts

## Using the AI Assistant

The AI assistant can help with:

1. **Proxy Workflows**: Ask about creating proxies for better performance
2. **Edit Tools**: Get explanations of Ripple, Roll, Slip, and Slide
3. **Color Grading**: Request AI-powered color correction
4. **Multicam Sync**: Sync multiple camera angles automatically
5. **General Questions**: Ask anything about video editing

Example queries:
- "How do I use J-K-L shuttle controls?"
- "Create proxies for my 4K footage"
- "What's the difference between ripple and roll?"
- "Apply a cinematic color grade"

## Responsive Design

The app adapts to different screen sizes:

- **Panels resize dynamically** based on available space
- **Minimum size**: 1024x768
- **Optimized for**: MacBook Pro, iMac, iPad Pro
- **Adaptive layouts** using GeometryReader

Panel size ratios:
- Media Bin: 15% of screen width (min 200px)
- Center Viewers: Flexible
- AI Panel: 20% of screen width (min 280px)
- Timeline: 40% of screen height (max 360px)

## Development

### Adding New Features

1. **New Model**: Add to `Models.swift`
2. **New ViewModel**: Create in `ViewModels/` folder
3. **New View**: Create in `Views/` folder
4. **Inject Dependencies**: Pass ViewModels through `@EnvironmentObject` or `@ObservedObject`

### Extending AI Capabilities

Edit `OllamaService.swift` to:
- Add new context types
- Modify the system prompt
- Adjust temperature and parameters
- Add new AI-powered features

## Troubleshooting

### Ollama Connection Failed

**Problem**: "⚠️ Ollama not detected"

**Solution**:
1. Check if Ollama is running: `ps aux | grep ollama`
2. Start Ollama: `ollama serve`
3. Verify the model: `ollama list`
4. If the model is missing: `ollama pull llama3.2:3b`

### App Won't Build

**Problem**: Build errors in Xcode

**Solution**:
1. Clean build folder: Product → Clean Build Folder (⌘⇧K)
2. Verify minimum deployment target is set correctly
3. Check all files are added to the target
4. Restart Xcode

### Drag and Drop Not Working

**Problem**: Can't drag clips to timeline

**Solution**:
1. Ensure you're dragging from the Media Bin
2. Drop onto the track lane area (not the track header)
3. Check console for any error messages

## Performance Tips

1. **Enable Proxies**: Toggle proxies for 4K/8K footage
2. **Use Lower Resolution**: Edit with proxies, export with originals
3. **Optimize Timeline**: Remove unused clips
4. **Close Other Apps**: Free up system resources

## License

Copyright © 2025. All rights reserved.

## Support

For issues or questions, please consult:
- Ollama documentation: https://ollama.ai/docs
- SwiftUI documentation: https://developer.apple.com/swiftui/
- Video editing best practices

---

Built with ❤️ using SwiftUI and Ollama
