# 🌟 LittleSpark — A Magical Gamified Kids Learning App

LittleSpark is a premium, feature-rich Flutter learning application designed to make education a fun, interactive, and gamified experience for kids. Through beautiful animations, rich sounds, haptic feedback, voice practice, mini-games, and a progressive learning adventure, LittleSpark nurtures curiosity and fuels early childhood education.

---

## 🎨 App Screenshots & Visual Design
LittleSpark is built with a custom dark-mode aesthetic that is gentle on young eyes, layered with neon gradients, glowing cards, ambient particle systems, floating clouds, butterflies, and animated stars.

---

## 🚀 Core Features & Learning Modules

### 1. 🔤 A to Z Learning Module
* Interactive alphabet discovery from A to Z.
* Association with realistic visuals and words.
* Rich text-to-speech pronunciation support.

### 2. 🔢 Count 1 to 100
* Vibrant number grid that introduces counting visually.
* Pronunciation guide for every individual number.
* Tracks counting progress reactively.

### 3. 🎨 Colors & Shapes
* Introduces shapes (Circle, Square, Triangle, etc.) and primary/secondary colors.
* Interactive visual animations to reinforce shape recognition.

### 4. 🐾 Animal Kingdom & 🍎 Fruits & Veggies
* Educational flashcards displaying wildlife, domestic animals, fruits, and vegetables.
* Interactive audio service to play pronunciation sounds and details.

### 5. 🎤 Say It! (Voice Practice)
* Speech-to-text integration that allows children to practice pronouncing letters and words.
* Real-time audio analysis and feedback to encourage correct pronunciations.

### 6. 🎵 Interactive Rhymes
* A dedicated dashboard hosting classic and interactive nursery rhymes.
* Built-in media player for educational video stream synchronization.

### 7. 🔍 Mini-Games & Quizzes
* **Find Alphabet & Find Numbers**: Time-bound, stage-by-stage guessing puzzles that test shape and value recognition.
* **Memory Match**: A card-flipping memory matching puzzle game designed to sharpen concentration and cognitive capabilities.

### 8. 🗺️ Learning Adventure Mode
* An interactive multi-stage roadmap that gamifies the path of learning.
* Progression path with milestones, stage completions, and reward collections.

---

## 🏆 Gamification & Rewards Engine

LittleSpark uses game mechanics to keep children engaged and form regular learning habits:

* **Level & XP (Experience Points)**: Every time a child completes a learning card, reads a letter, or passes a game, they earn XP. Gaining XP automatically levels up their profile!
* **Star & Coin Rewards**: Visual feedback with particle explosions and confetti. Stars and coins are saved to buy custom icons/avatars.
* **Daily Streaks**: A streak counter that encourages kids to log in every day to keep their flame alive.
* **Badges & Achievements**: Milestones unlock unique digital trophies and badges (e.g. *Alphabet Explorer*, *Pronunciation Champion*, *Streak Master*) with celebration alerts.
* **Profile & Custom Avatars**: Let kids customize their digital presence by choosing from avatars like Astronauts 🧑‍🚀, Superheroes, and cute animals.

---

## 🛠️ Technology Stack

LittleSpark is built on top of high-performance modern Flutter frameworks and packages:

| Category | Package / Tool | Purpose |
|---|---|---|
| **State Management** | `get` (GetX) | Reactive state management, dependency injection, and clean routing. |
| **Local Storage** | `hive` & `hive_flutter` | Fast, lightweight NoSQL database to store streaks, XP, level, unlocked badges, and settings offline. |
| **Audio Services** | `just_audio` & `audio_session` | Plays background music, celebration sounds, and audio feedback. |
| **Text-to-Speech** | `flutter_tts` | Dynamic speech synthesis for pronouncing letters, numbers, and words. |
| **Speech-to-Text** | `speech_to_text` | Real-time speech recognition for interactive voice practice. |
| **Animations** | `lottie`, `flutter_animate`, `animate_do` | High-quality micro-animations, particle systems, floating decorations, and confetti. |
| **Telemetry & Cloud** | `firebase_core`, `firebase_analytics`, `firebase_messaging` | Push notifications for daily challenges and event tracking. |

---

## 📂 Project Architecture

The codebase follows clean architecture principles optimized for GetX:

```text
lib/
├── main.dart                  # Entry point, initializes Hive, Firebase, and global services
├── app.dart                   # GetMaterialApp configuration and route definitions
├── core/
│   ├── constants/             # Global strings, assets path, and route names
│   ├── theme/                 # Dark theme configuration, color gradients, and typography
│   └── utils/                 # Haptic engines, formatters, and animation utilities
├── data/                      # Data models and structures (if needed)
├── services/                  # Persistent global services (Audio, TTS, Progress, Notifications, Analytics)
└── presentation/              # UI screens, controllers, and feature widgets
    ├── home/                  # Dashboard containing modules grid, daily challenge, and stats header
    ├── alphabet/              # Alphabet visual learning
    ├── voice/                 # Speech-to-text pronunciation trainer
    ├── mini_games/            # Memory match, find puzzle gates
    ├── learning_adventure/    # Multi-stage gamified adventure map
    └── profile/               # Avatar customization and badges tracker
```

---

## ⚙️ Getting Started & Local Setup

### Prerequisites
* Flutter SDK (version `>=3.13.0`)
* Dart SDK (version `>=3.0.0 <4.0.0`)
* Cocopods (for iOS builds)

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ShubhamNarula/LittleSpark.git
   cd LittleSpark
   ```

2. **Retrieve Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration Setup:**
   * This project is pre-configured with Firebase Analytics and Messaging.
   * Add your `google-services.json` (for Android) to `android/app/` and `GoogleService-Info.plist` (for iOS) to `ios/Runner/` if building with custom Firebase project scopes.

4. **Run Code Generation (if needed):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the App:**
   * Run in debug mode:
     ```bash
     flutter run
     ```
   * Or build for production:
     ```bash
     flutter build apk --release # Android
     flutter build ipa           # iOS
     ```

---

## 📝 License & Contributions
This project is created for educational and learning purposes. Feel free to explore the code, report issues, or suggest improvements!
