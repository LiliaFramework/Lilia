# Configuration

Configuration options for the Advertisements module.

---

Overview

The Advertisements module lets you set how much it costs to send server-wide messages and how long players must wait between messages. This helps prevent spam while allowing important announcements.

---

### AdvertPrice

#### 📋 Description
How much money players pay to send a server-wide advertisement message.

#### ⚙️ Type
Int

#### 💾 Default Value
10

#### 📊 Range
Minimum: 1
Maximum: 1000

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Lower values (1-5) make ads cheap but may cause spam
- Medium values (10-50) work well for most servers
- Higher values (100+) make ads expensive and rare

---

### AdvertCooldown

#### 📋 Description
How many seconds players must wait between sending advertisement messages.

#### ⚙️ Type
Int

#### 💾 Default Value
20

#### 📊 Range
Minimum: 1
Maximum: 3600

#### 🌐 Realm
Server

#### 💡 Usage Notes
- Short cooldowns (1-10 seconds) allow quick messages but don't prevent spam
- Medium cooldowns (20-60 seconds) are recommended for most servers
- Long cooldowns (300+ seconds) make advertisements rare and special

