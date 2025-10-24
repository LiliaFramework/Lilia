# Workshop Library

Steam Workshop addon downloading, mounting, and management system for the Lilia framework.

---

## Overview

The workshop library provides comprehensive functionality for managing Steam Workshop addons

in the Lilia framework. It handles automatic downloading, mounting, and management of

workshop content required by the gamemode and its modules. The library operates on both

server and client sides, with the server gathering workshop IDs from modules and mounted

addons, while the client handles downloading and mounting of required content. It includes

user interface elements for download progress tracking and addon information display.

The library ensures that all required workshop content is available before gameplay begins.

---

### addWorkshop

**Purpose**

Adds a workshop addon ID to the server's required workshop content list

**When Called**

Called when modules or addons need specific workshop content

---

### gather

**Purpose**

Gathers all workshop IDs from mounted addons and module configurations

**When Called**

Called during module initialization to collect all required workshop content

---

### send

**Purpose**

Sends the cached workshop IDs to a specific player to initiate download

**When Called**

Called when a player requests workshop content or during initial spawn

---

### hasContentToDownload

**Purpose**

Checks if there are any workshop addons that need to be downloaded

**When Called**

Called to determine if the client needs to download workshop content

---

### mountContent

**Purpose**

Initiates the mounting process for required workshop content with user confirmation

**When Called**

Called when the client needs to download and mount workshop addons

---

