# Web Image Library

Web-based image downloading, caching, and management system for the Lilia framework.

---

## Overview

The web image library provides comprehensive functionality for downloading, caching, and managing

web-based images in the Lilia framework. It handles automatic downloading of images from URLs,

local caching to improve performance, and seamless integration with Garry's Mod's material system.

The library operates on both server and client sides, with intelligent caching mechanisms that

prevent redundant downloads and ensure images are available offline after initial download.

It includes URL validation, file format detection, and automatic directory management for

organized storage. The library also provides hooks for download events and statistics tracking.

Images are stored in the data/lilia/webimages/ directory and can be accessed through various

path formats for maximum compatibility with existing code.

---

### download

**Purpose**

Downloads an image from a URL and caches it locally for future use

**When Called**

When you need to fetch an image from the internet and store it locally

**Parameters**

* `n` (*string*): Name/identifier for the image
* `u` (*string, optional*): URL to download from (uses stored URL if not provided)
* `cb` (*function, optional*): Callback function called when download completes
* `flags` (*string, optional*): Material flags for the downloaded image

---

### register

**Purpose**

Registers an image URL for future use and immediately downloads it

**When Called**

When you want to store an image URL and download it for later use

**Parameters**

* `n` (*string*): Name/identifier for the image
* `u` (*string*): URL to download from
* `cb` (*function, optional*): Callback function called when download completes
* `flags` (*string, optional*): Material flags for the downloaded image

---

### get

**Purpose**

Retrieves a cached material from a previously downloaded image

**When Called**

When you need to get a material that has already been downloaded and cached

**Parameters**

* `n` (*string*): Name/identifier of the image or URL
* `flags` (*string, optional*): Material flags to apply to the material
* `avatarPanel:SetImage("icon16/user.png")` (*unknown*): - fallback

---

### lia.Material

**Purpose**

Retrieves a cached material from a previously downloaded image

**When Called**

When you need to get a material that has already been downloaded and cached

**Parameters**

* `n` (*string*): Name/identifier of the image or URL
* `flags` (*string, optional*): Material flags to apply to the material
* `avatarPanel:SetImage("icon16/user.png")` (*unknown*): - fallback

---

### lia.dimage:SetImage

**Purpose**

Retrieves a cached material from a previously downloaded image

**When Called**

When you need to get a material that has already been downloaded and cached

**Parameters**

* `n` (*string*): Name/identifier of the image or URL
* `flags` (*string, optional*): Material flags to apply to the material
* `avatarPanel:SetImage("icon16/user.png")` (*unknown*): - fallback

---

### getStats

**Purpose**

Retrieves statistics about downloaded and stored web images

**When Called**

When you need to monitor the library's performance or get usage statistics

**Parameters**

* `createStatsDashboard()` (*unknown*): - Refresh

---

