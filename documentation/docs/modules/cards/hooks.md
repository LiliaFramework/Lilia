# Hooks

Hooks provided by the Cards module for card drawing functionality.

---

Overview

The Cards module implements a complete playing card system with a full 52-card deck that supports shuffling, drawing, and synchronized gameplay. It provides real-time card draw synchronization across all players for fair minigame mechanics and includes comprehensive hook integration for custom card game implementations, deck management, and game state tracking.

---

### CardDrawn

#### 📋 Purpose
Called when a player draws a card using the cards command.

#### ⏰ When Called
After a card has been randomly selected and displayed to the player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who drew the card |
| `card` | **string** | The card that was drawn (e.g., "Ace of Spades") |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### CardsCommandUsed

#### 📋 Purpose
Called when a player uses the cards command.

#### ⏰ When Called
Before checking if the player has a card deck and before drawing a card.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who used the cards command |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

