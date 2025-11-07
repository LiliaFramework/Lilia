# Hooks

Hooks provided by the Community Commands module for managing community URL commands.

---

Overview

The Community Commands module provides an extensible system for community-related chat commands that open URLs, share workshop content, and access documentation. It supports configurable command names with localization, custom URL management, and seamless integration with Steam Workshop and community resources. The module includes comprehensive hook integration for tracking command usage and customizing URL opening behavior.

---

### CommunityURLOpened

#### 📋 Purpose
Called when a player opens a community URL through a command.

#### ⏰ When Called
After the URL is opened, either in the browser or in-game (if supported).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `commandName` | **string** | The name of the command that was used |
| `url` | **string** | The URL that was opened |
| `openIngame` | **boolean** | Whether the URL was opened in-game or externally |

#### ↩️ Returns
nil 

#### 🌐 Realm
Client

---

### CommunityURLRequest

#### 📋 Purpose
Called when a player requests to open a community URL.

#### ⏰ When Called
When the server receives a request to open a community URL command.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player requesting the URL |
| `command` | **string** | The command name that was used |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

