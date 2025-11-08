# Configuration

Configuration options for the Word Filter module.

---

Overview

The Word Filter module blocks inappropriate words from chat messages. Any message containing a blacklisted word will be completely blocked and not shown to other players.

---

### WordBlackList

#### 📋 Description
A list of words that will be blocked from chat. Messages containing these words won't be displayed.

#### ⚙️ Type
Table

#### 💾 Default Value
{"nigger", "faggot", "chink", "kike", "spic", "gook", "wetback", "dyke", "tranny", "retard", "coon", "raghead", "nip", "honky", "gyp", "beaner", "paki", "slant", "slope", "jap"}

#### 🌐 Realm
Server

#### 💡 Usage Notes
- The filter is case-insensitive (catches "Word", "WORD", and "word")
- To add words, add them to the list: `"new", "inappropriate", "word"`
- To remove words, delete them from the list
- Customize this list to match your server's rules

