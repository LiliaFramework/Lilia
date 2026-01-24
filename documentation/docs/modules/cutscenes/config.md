# Configuration

Configuration options for the Cutscenes module.

---

Overview

The Cutscenes module lets you create cinematic scenes with images, sounds, and text. Perfect for server introductions, event announcements, or storytelling.

---

### fadeDelay

#### 📋 Description
How many seconds it takes to fade between cutscene scenes.

#### ⚙️ Type
Number

#### 💾 Default Value
2

#### 🌐 Realm
Shared

#### 💡 Usage Notes
- Short delays (0.5-1 second) create quick transitions
- Medium delays (2-3 seconds) work well for most cutscenes
- Long delays (4+ seconds) create slow, dramatic transitions

---

### cutscenes

#### 📋 Description
Defines your cutscenes. Each cutscene can have multiple scenes with images, sounds, and subtitles.

#### ⚙️ Type
Table

#### 💾 Default Value
Example cutscenes including "Mistery Info", "Battle Intro", and "Victory Celebration".

#### 📊 Structure
Each cutscene contains scenes with:
- `image` (string) - Image URL or file path
- `sound` (string) - Sound file path (optional)
- `subtitles` (table) - Array of subtitle entries with:
  - `text` (string) - The subtitle text
  - `font` (string) - Font name like "liaSubtitleFont"
  - `duration` (number) - How long to show it in seconds
  - `color` (Color) - Text color (optional)
- `songFade` (boolean) - Fade out music at end (optional)

#### 🌐 Realm
Shared

#### 💡 Usage Notes
- Use web URLs (like Imgur) for images or local file paths
- Subtitle duration: allow about 1 second per 3-4 words
- Use `"liaSubtitleFont"` for regular text or `"liaTitleFont"` for emphasis
- Keep cutscenes short so players don't skip them

