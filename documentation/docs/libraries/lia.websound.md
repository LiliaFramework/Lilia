# WebSound Library

Web-based audio content downloading, caching, and playback system for the Lilia framework.

---

## Overview

The websound library provides comprehensive functionality for managing web-based audio content

in the Lilia framework. It handles downloading, caching, validation, and playback of sound files

from HTTP/HTTPS URLs, with automatic local storage and retrieval. The library operates on both

server and client sides, providing seamless integration with Garry's Mod's sound system through

enhanced versions of sound.PlayFile, sound.PlayURL, and surface.PlaySound functions. It includes

robust URL validation, file format verification, caching mechanisms, and statistics tracking.

The library ensures optimal performance by avoiding redundant downloads and providing fallback

mechanisms for failed downloads while maintaining compatibility with existing sound APIs.

---

### download

**Purpose**

Downloads a sound file from a URL and caches it locally for future use

**When Called**

When a sound needs to be downloaded from a web URL, either directly or through other websound functions

**Parameters**

* `name` (*string*): The name/path for the sound file (will be normalized)
* `url` (*string, optional*): The HTTP/HTTPS URL to download from (uses stored URL if not provided)
* `cb` (*function, optional*): Callback function called with (path, fromCache, error) parameters

---

### register

**Purpose**

Registers a sound file URL for future use and immediately downloads it

**When Called**

When registering a new sound file that should be available for playback

**Parameters**

* `name` (*string*): The name/path for the sound file (will be normalized)
* `url` (*string*): The HTTP/HTTPS URL to download from
* `cb` (*function, optional*): Callback function called with (path, fromCache, error) parameters

---

### get

**Purpose**

Retrieves the local file path of a cached sound file

**When Called**

When checking if a sound file is available locally or getting its path for playback

**Parameters**

* `name` (*string*): The name/path of the sound file to retrieve (will be normalized)

---

### lia.sound.PlayFile

**Purpose**

Retrieves the local file path of a cached sound file

**When Called**

When checking if a sound file is available locally or getting its path for playback

**Parameters**

* `name` (*string*): The name/path of the sound file to retrieve (will be normalized)

---

### lia.sound.PlayURL

**Purpose**

Retrieves the local file path of a cached sound file

**When Called**

When checking if a sound file is available locally or getting its path for playback

**Parameters**

* `name` (*string*): The name/path of the sound file to retrieve (will be normalized)

---

### lia.surface.PlaySound

**Purpose**

Retrieves the local file path of a cached sound file

**When Called**

When checking if a sound file is available locally or getting its path for playback

**Parameters**

* `name` (*string*): The name/path of the sound file to retrieve (will be normalized)

---

### getStats

**Purpose**

Retrieves statistics about downloaded and stored sound files

**When Called**

When monitoring websound library performance or displaying usage statistics

---

### playButtonSound

**Purpose**

Plays a button click sound with automatic fallback to default button_click.wav

**When Called**

When a button is clicked and needs to play a sound

**Parameters**

* `customSound` (*string, optional*): Custom sound to play instead of default
* `callback` (*function, optional*): Callback function called with (success) parameter
* `handleButtonClick("secondary")` (*unknown*): - Will use default

---

