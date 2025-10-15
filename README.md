# 🎮 GameVerse

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.5.4-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5.4-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue)

**Your Ultimate Gaming Universe - 8 Games, Endless Fun!**

A beautifully crafted Flutter game collection featuring classic board games, brain teasers, word puzzles, and more - all in one app!

[Features](#-features) • [Games](#-games) • [Installation](#-installation) • [Screenshots](#-screenshots) • [Tech Stack](#-tech-stack)

</div>

---

## ✨ Features

- 🎯 **8+ Interactive Games** across 9 different categories
- 🎨 **Modern UI/UX** with smooth animations and transitions
- 🤖 **AI Opponents** for single-player challenges
- 👥 **Multiplayer Support** for competitive gameplay
- 🏆 **High Score Tracking** and statistics
- 🎵 **Sound Effects & Music** with customizable settings
- 📱 **Responsive Design** optimized for all screen sizes
- 🌙 **Theme Support** for comfortable gaming
- 💾 **Local Storage** for saving game progress
- 🎭 **Offline Play** - no internet required

---

## 🎮 Games

### 🔷 Classic Board Games (3 Games)
| Game | Description | Status |
|------|-------------|--------|
| **♟️ Chess** | Full chess implementation with AI, piece movement validation, and checkmate detection | ✅ Available |
| **❌ Tic Tac Toe** | Classic X and O game with AI opponents and multiplayer mode | ✅ Available |
| **🔴 Connect Four** | Strategic disc-dropping game with smooth animations | ✅ Available |

### 📝 Word Games (4 Games)
| Game | Description | Status |
|------|-------------|--------|
| **🎯 Hangman** | Word guessing with multiple categories and daily challenges | ✅ Available |
| **🔍 Word Search** | Find hidden words in letter grids | 🔜 Coming Soon |
| **📋 Crossword** | Classic crossword puzzles with various themes | 🔜 Coming Soon |
| **🔄 Anagrams** | Rearrange letters to form words | 🔜 Coming Soon |

### 🧠 Brain Training (1 Game)
| Game | Description | Status |
|------|-------------|--------|
| **🃏 Memory Match** | Card matching game to test your memory | ✅ Available |

### 🧩 Puzzle Games (1 Game)
| Game | Description | Status |
|------|-------------|--------|
| **🎲 Block Merge (2048)** | Merge numbered blocks to reach 2048 | ✅ Available |

### 🕹️ Quick Casual (1 Game)
| Game | Description | Status |
|------|-------------|--------|
| **🐦 Flappy Bird** | Classic one-touch arcade game | ✅ Available |

### ⚡ Reaction Games (1 Game)
| Game | Description | Status |
|------|-------------|--------|
| **🔨 Whack-A-Mole** | Test your reflexes by whacking moles | ✅ Available |

### 📚 Educational (1 Game)
| Game | Description | Status |
|------|-------------|--------|
| **❓ Quiz Master** | Multi-topic quiz game from science to history | ✅ Available |

### 🎪 More Categories
- **🎮 Arcade** - Coming Soon
- **🧭 Strategy** - Coming Soon

---

## 📸 Screenshots

> *Screenshots coming soon! The app features beautiful, modern UI with smooth animations.*

---

## 🚀 Installation

### Prerequisites
- Flutter SDK 3.5.4 or higher
- Dart SDK 3.5.4 or higher
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/gameverse.git
   cd gameverse
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build APK (Android)**
   ```bash
   flutter build apk --release
   ```

5. **Build IPA (iOS)**
   ```bash
   flutter build ios --release
   ```

---

## 🛠️ Tech Stack

### Core
- **Flutter** - UI Framework
- **Dart** - Programming Language
- **GetX** - State Management & Navigation

### Key Packages
| Package | Purpose |
|---------|---------|
| `get` | State management and routing |
| `get_storage` | Local data persistence |
| `shared_preferences` | Settings storage |
| `google_fonts` | Beautiful typography |
| `flutter_animate` | Smooth animations |
| `audioplayers` | Sound effects and music |
| `sensors_plus` | Gyroscope for tilt controls |
| `connectivity_plus` | Network status monitoring |
| `confetti` | Celebration animations |
| `lottie` | Advanced animations |
| `flutter_svg` | SVG graphics support |
| `cached_network_image` | Image caching |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── controllers/                 # GetX controllers
│   └── home_controller.dart    # Home screen logic
├── screens/                     # App screens
│   ├── home/                   # Home screen
│   └── category/               # Category screens
├── games/                       # Individual game modules
│   ├── classic_board/          # Chess, Tic Tac Toe, Connect Four
│   ├── word_games/             # Hangman, Word Search, etc.
│   ├── brain_training/         # Memory Match
│   ├── puzzle/                 # Block Merge (2048)
│   ├── quick_casual/           # Flappy Bird
│   ├── reaction/               # Whack-A-Mole
│   ├── educational/            # Quiz Master
│   └── arcade/                 # Future arcade games
├── models/                      # Data models
├── services/                    # API and services
├── theme/                       # App theming
└── widgets/                     # Reusable widgets
```

Each game module follows this structure:
```
game_name/
├── controllers/        # Game logic and state
├── models/            # Game data models
├── screens/           # Game UI screens
├── widgets/           # Game-specific widgets
├── services/          # Game services
└── theme/            # Game theming
```

---

## 🎯 Features by Game

### ♟️ Chess
- Full chess rule implementation
- AI opponent with difficulty levels
- Move validation and legal move highlighting
- Check and checkmate detection
- Piece capture animations
- Move history tracking
- Custom piece designs (SVG)

### ❌ Tic Tac Toe
- Single player vs AI
- Two-player local multiplayer
- Winning line animations
- Score tracking
- Difficulty levels

### 🔴 Connect Four
- Strategic gameplay
- Gravity-based disc dropping
- Win detection in all directions
- Smooth drop animations

### 🎯 Hangman
- Multiple word categories
- Daily challenges
- Progressive difficulty
- Hint system
- Lives tracking

### 🃏 Memory Match
- Multiple difficulty levels
- Card flip animations
- Score and time tracking
- Various card themes

### 🎲 Block Merge
- 2048 gameplay mechanics
- Swipe controls
- Score tracking
- Undo functionality
- Game saving

### 🐦 Flappy Bird
- One-touch controls
- Endless gameplay
- High score system
- Obstacle generation
- Smooth physics

### 🔨 Whack-A-Mole
- Reflex-based gameplay
- Multiple difficulty modes
- Score multipliers
- Time-based challenges

### ❓ Quiz Master
- Multiple categories (Science, History, etc.)
- Timed questions
- Score tracking
- Difficulty progression

---

## ⚙️ Configuration

### Sound Settings
All games include:
- 🔊 Sound effects toggle
- 🎵 Background music control
- 📳 Vibration feedback

### Game Settings
- Difficulty levels
- Display preferences
- Control customization

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Ideas for Contribution
- 🎮 Add new games
- 🐛 Fix bugs
- 🎨 Improve UI/UX
- 📝 Improve documentation
- 🌐 Add localization

---

## 🗺️ Roadmap

- [ ] Add online multiplayer support
- [ ] Implement leaderboards
- [ ] Add achievements system
- [ ] Add more games in each category
- [ ] Support for multiple languages
- [ ] Cloud save support
- [ ] Social sharing features
- [ ] Tournament mode
- [ ] Custom themes

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

Created with ❤️ using Flutter

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX for powerful state management
- All open-source package contributors
- Chess piece SVGs and game assets
- Flutter community for inspiration

---

## 📧 Contact

Have questions or suggestions? Feel free to reach out!

- 📫 Create an issue
- 🌟 Star this repository if you like it!

---

<div align="center">

**Made with Flutter 💙**

⭐ Star this repo if you find it useful! ⭐

</div>
