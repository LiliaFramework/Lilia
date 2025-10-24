# Network Library

Network communication and data streaming system for the Lilia framework.

---

## Overview

The network library provides comprehensive functionality for managing network communication

in the Lilia framework. It handles both simple message passing and complex data streaming

between server and client. The library includes support for registering network message

handlers, sending messages to specific targets or broadcasting to all clients, and managing

large data transfers through chunked streaming. It also provides global variable synchronization

across the network, allowing server-side variables to be automatically synchronized with

clients. The library operates on both server and client sides, with server handling message

broadcasting and client handling message reception and acknowledgment.

---

### register

**Purpose**

Registers a network message handler for receiving messages sent via lia.net.send

**When Called**

During initialization or when setting up network message handlers

**Parameters**

* `name` (*string*): The name identifier for the network message
* `callback` (*function*): Function to call when this message is received

---

### send

**Purpose**

Sends a network message to specified targets or broadcasts to all clients

**When Called**

When you need to send data from server to client(s) or client to server

**Parameters**

* `name` (*string*): The registered message name to send
* `target` (*Player/table/nil*): Target player(s) - nil broadcasts to all, table sends to multiple players

---

### readBigTable

**Purpose**

Sets up a receiver for large table data that is sent in chunks via lia.net.writeBigTable

**When Called**

During initialization to set up handlers for receiving large data transfers

**Parameters**

* `netStr` (*string*): The network string identifier for the message
* `callback` (*function*): Function to call when all chunks are received and data is reconstructed

---

### writeBigTable

**Purpose**

Sends large table data to clients in chunks to avoid network limits

**When Called**

When you need to send large amounts of data that exceed normal network limits

**Parameters**

* `targets` (*Player/table/nil*): Target player(s) - nil sends to all players
* `netStr` (*string*): The network string identifier for the message
* `tbl` (*table*): The table data to send
* `chunkSize` (*number, optional*): Size of each chunk in bytes (default: 2048, 512 during reload)

---

### lia.checkBadType

**Purpose**

Sends large table data to clients in chunks to avoid network limits

**When Called**

When you need to send large amounts of data that exceed normal network limits

**Parameters**

* `targets` (*Player/table/nil*): Target player(s) - nil sends to all players
* `netStr` (*string*): The network string identifier for the message
* `tbl` (*table*): The table data to send
* `chunkSize` (*number, optional*): Size of each chunk in bytes (default: 2048, 512 during reload)

---

### lia.setNetVar

**Purpose**

Sets a global network variable value and synchronizes it to clients

**When Called**

When you need to update a global variable that should be synchronized across the network

**Parameters**

* `key` (*string*): The name/key of the global variable to set
* `value` (*any*): The value to set for the global variable
* `receiver` (*Player, optional*): Specific player to send the update to, nil broadcasts to all

---

### lia.getNetVar

**Purpose**

Retrieves a global network variable value with optional default fallback

**When Called**

When you need to access a global variable that is synchronized across the network

**Parameters**

* `key` (*string*): The name/key of the global variable to retrieve
* `default` (*any, optional*): Default value to return if the variable doesn't exist

---

### lia.getNetVar

**Purpose**

Retrieves a global network variable value with optional default fallback (client-side)

**When Called**

When you need to access a global variable that is synchronized from the server

**Parameters**

* `key` (*string*): The name/key of the global variable to retrieve
* `default` (*any, optional*): Default value to return if the variable doesn't exist

---

