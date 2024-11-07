# Whisperstone

[![Build](https://github.com/Pixel-Pilgrims/game-off-2024/actions/workflows/build.yml/badge.svg)](https://github.com/Pixel-Pilgrims/game-off-2024/actions/workflows/build.yml)

A roguelike deck-builder where players discover magical scrolls that grant power through cards. Every card is initially unreadable, forcing players to choose between decoding their mysteries or wielding their raw, unpredictable power.

## 🎮 Key Features

- **Bold Uncertainty**: Every unread card is a complete mystery, including its cost and effect
- **Knowledge vs. Power**: Unread cards have higher potential but are unpredictable
- **Progressive Discovery**: Each run contributes to understanding your cards and the world
- **Strategic Depth**: Balance risk and knowledge across multiple game layers
- **Narrative Mystery**: Uncover the ancient civilization's secrets through gameplay

## 🚀 Getting Started

### Prerequisites

- [Godot 4.3](https://godotengine.org/download) or later
- Git (for version control)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Pixel-Pilgrims/game-off-2024.git
cd game-off-2024
```

2. Open Godot Engine
3. Click "Import" and select the `project.godot` file from the cloned repository
4. Click "Import & Edit"

### Development Setup

The project uses a structured organization:

```
project/
├── scenes/          # Scene files (.tscn)
├── scripts/         # GDScript files (.gd)
│   ├── autoload/   # Autoloaded singleton scripts
│   ├── data/       # Data structure definitions
│   ├── managers/   # System managers
│   ├── scenes/     # Scene-specific scripts
│   ├── systems/    # Core game systems
│   └── utils/      # Utility scripts
├── resources/       # Resource files (.tres)
└── assets/         # Art, audio, and other assets
```

## 🎯 Core Systems

### Card System
- Cards can be in three states: Unread, Partially Decoded, or Fully Decoded
- Decoding reveals different aspects: cost, type, effect numbers, and descriptions
- Strategic balance between using unknown cards and investing in decoding

### Combat System
- Turn-based combat with energy management
- Enemies with unique behaviors and patterns
- Block and damage mechanics

### Adventure System
- Node-based map progression
- Multiple encounter types: Combat, Events, and Story
- Branching paths with hidden routes

## 🛠 Building

### Web Export
```bash
# Using GitHub Actions (automatic on push to main)
git push origin main

# Manual export from Godot
1. Project > Export
2. Select "Web"
3. Click "Export Project"
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Style Guidelines

- Use PascalCase for node names and classes
- Use snake_case for functions and variables
- Add comments for complex logic
- Follow the existing project structure

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

See [ATTRIBUTION.md](ATTRIBUTION.md) for a complete list of assets and tools used in this project.

## 🎮 Game Off 2024

This game is being developed as part of the [GitHub Game Off 2024](https://itch.io/jam/game-off-2024) game jam, with the theme "SECRETS".
