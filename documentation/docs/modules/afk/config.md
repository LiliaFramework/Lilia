# Configuration

Configuration options for the AFK Protection module.

---

Overview

The AFK Protection module automatically detects when players are away and protects them from being tied up, arrested, or exploited. You can set how long players must be inactive before being marked as AFK, and whether protection is enabled.

---

### AFKTime

#### 📋 Description
How many seconds a player must be inactive before being marked as AFK.

#### ⚙️ Type
Int

#### 💾 Default Value
180

#### 📊 Range
Minimum: 30
Maximum: 600

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Short durations (30-60 seconds) detect AFK quickly but may mark players during slow roleplay
- Medium durations (180-300 seconds) work well for most servers
- Long durations (300+ seconds) only mark players after extended inactivity

---

### AFKProtectionEnabled

#### 📋 Description
Turns AFK protection on or off. When enabled, AFK players cannot be tied up or arrested.

#### ⚙️ Type
Boolean

#### 💾 Default Value
true

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Enabled (true) is recommended - protects players who step away
- Disabled (false) still marks players as AFK but doesn't protect them

