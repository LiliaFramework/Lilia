# Installation Guide

This page provides a comprehensive guide for installing the Lilia framework on your Garry's Mod server using Steam Workshop.

---

## Overview

Lilia is a versatile roleplay framework for Garry's Mod that provides the foundation for creating immersive roleplaying experiences. This installation guide walks you through the complete setup process, from initial prerequisites to server launch verification.

> **Important Note**
>
> Lilia runs beneath a roleplay schema. After installing Lilia, you must also install a schema and start your server using that schema's gamemode (for example, `+gamemode skeleton`).

---

## Prerequisites

Before proceeding with the installation, ensure you have the following requirements met:

### System Requirements

* **A Working Garry's Mod Server**: Ensure your server is properly configured and running without issues.

* **Basic Server Administration Knowledge**: Familiarity with managing a Garry's Mod server is recommended.

* **Command Line Proficiency**: Basic understanding of command-line operations is helpful for troubleshooting.

### Administration Tools

* **Admin Menu**: Lilia includes a built-in admin menu for logging, tickets, and teleport tools. [SAM](https://www.gmodstore.com/market/view/sam) is also compatible. **ULX is not supported because its CAMI library is outdated.**

### Development Tools (Optional)

* **Code Editor**: For customization and development work, consider using one of these editors:

  1. [Visual Studio Code](https://code.visualstudio.com/) - Free, highly extensible with excellent Lua support
  2. [Notepad++](https://notepad-plus-plus.org/) - Lightweight and fast for quick edits
  3. [Sublime Text](https://www.sublimetext.com/) - Fast and customizable editor
  4. [ZeroBrane Studio](https://studio.zerobrane.com/) - Specialized Lua IDE with debugging support

---

## Installation Steps

### Step 1: Server Preparation

**Purpose**

Prepare your Garry's Mod server environment for Lilia framework installation.

**Requirements**

* Ensure your Garry's Mod server is properly installed and operational
* Verify server connectivity and basic functionality
* Confirm you have administrative access to server configuration

**Setting Up a Local Server**

For a comprehensive guide on setting up a local Garry's Mod server, refer to this excellent tutorial:

* **[How to host a Garry's Mod Server](https://steamcommunity.com/sharedfiles/filedetails/?id=179569412)** - Complete guide covering SteamCMD installation, configuration, and workshop addons

**Creating a Startup Script**

Create a `start.bat` file in your server directory with the following content for easy server launching:

```batch
@echo off
:srcds
echo [%time%] srcds started.
start /wait srcds.exe -console -game garrysmod +map gm_flatgrass +gamemode skeleton +maxplayers 16
echo [%time%] WARNING: srcds closed or crashed.
timeout /t 1 /nobreak >nul
goto srcds
```

> **Note**: Replace `gm_flatgrass` with your preferred map and adjust `+maxplayers 16` as needed. The script will automatically restart the server if it crashes.

---

### Step 2: Installing Lilia Framework via Steam Workshop

**Purpose**

Install the Lilia framework using Steam Workshop for automatic updates and dependency management.

**Procedure**

1. **Access Lilia Framework on Steam Workshop:**

    Visit the official Lilia Framework Workshop page: [https://steamcommunity.com/sharedfiles/filedetails/?id=3527535922](https://steamcommunity.com/sharedfiles/filedetails/?id=3527535922)

2. **Subscribe to Lilia:**

    * Click the "Subscribe" button on the Workshop page
    * The addon will automatically download to your Garry's Mod installation
    * Workshop ID: `3527535922`
---

### Step 3: Configuring Server Workshop Integration

**Purpose**

Configure your server to download and use the Lilia framework from Steam Workshop.

**Configuration Steps**

1. **Server Workshop Setup:**

    Since Lilia is installed via Workshop on your local Garry's Mod client, you need to configure your server to download and use Workshop addons.

2. **Configure Server Workshop Collection:**

    Create or use a Steam Workshop collection that includes the Lilia Framework. Note the Workshop Collection ID.

3. **Update Server Startup Options:**

    You need to modify your server's startup parameters (also called command-line arguments or launch options). These are typically set in your server hosting control panel or startup script.

    **Option 1: Using a Workshop Collection (Recommended)**

    ```plaintext
    +host_workshop_collection <YourCollectionID>
    ```

    **Option 2: Using Individual Workshop Items**

    ```plaintext
    +workshop_start_enabled 1
    +workshop_items 3527535922
    ```

    > **Important:** These are command-line parameters that must be added to your server's startup options, not to `server.cfg`. For Option 1, replace `<YourCollectionID>` with your Workshop collection ID. For Option 2, the Lilia Framework Workshop ID is `3527535922`.

4. **Verify Installation:**

    The server will automatically download and extract the Lilia framework when it starts, placing it in the correct `garrysmod/gamemodes/lilia` directory.

---

### Step 4: Installing a Roleplay Schema

**Purpose**

Install and configure a roleplay schema to provide gameplay content and mechanics for your Lilia-powered server.

**Schema Selection**

Select a schema that fits your server theme:

* **Skeleton Schema**
  * [GitHub Repository](https://github.com/LiliaFramework/Skeleton)
  * [Direct Download](https://github.com/LiliaFramework/Skeleton/releases/download/release/skeleton.zip)

---

**Installation Procedure**

1. **Download the Schema:**

    Visit the schema's GitHub repository or use the direct download link, and download the ZIP file or clone the repository.

2. **Extract and Upload:**

    Extract the schema files locally, then upload the extracted folder to your server:

    ```plaintext
    garrysmod/gamemodes/<SchemaName>
    ```

3. **Configure the Schema:**

    Customize the following directories as needed for your server's gameplay:

    ```plaintext
    Factions:  garrysmod/gamemodes/<SchemaName>/schema/factions/
    Classes:   garrysmod/gamemodes/<SchemaName>/schema/classes/
    Items:     garrysmod/gamemodes/<SchemaName>/schema/items/
    Modules:   garrysmod/gamemodes/<SchemaName>/modules/
    Preload:   garrysmod/gamemodes/<SchemaName>/preload/
    ```

---

### Step 5: Launching Your Server

**Purpose**

Configure and launch your server with the installed Lilia framework and schema.

**Launch Configuration**

1. **Set the Startup Gamemode:**

    Edit your server's startup parameters so the server boots directly into your chosen schema:

    ```plaintext
    +gamemode <SchemaName>
    ```

    **Example:**
    ```plaintext
    +gamemode skeleton
    ```

2. **Start the Server:**

    Launch or restart your Garry's Mod server. Lilia will load as the framework beneath the schema.

3. **Verify the Installation:**

    Watch the console for a line such as:

    ```plaintext
    [Lilia] [Bootstrap] Loaded successfully after X seconds.
    ```

    If no errors appear and the schema loads, you're ready to play.

---

## Troubleshooting

This section provides solutions for common installation and configuration issues.

### Common Issues and Solutions

**Issue: "Gamemode 'skeleton' is missing"**

* **Solution**: Ensure your schema is properly installed in `garrysmod/gamemodes/`. Check that the folder name matches exactly (case-sensitive).

**Issue: Workshop items not downloading on server**

* **Solution**: Verify that your server has internet access and that the Workshop parameters are correctly set in your startup options, not in `server.cfg`.

**Issue: "Lilia framework not found"**

* **Solution**: Make sure you've subscribed to the Lilia Workshop addon on your Steam account and that the server has downloaded it. Check server console for Workshop download messages.

**Issue: Server won't start with new gamemode**

* **Solution**: Ensure the `+gamemode <SchemaName>` parameter is correctly set in your server startup options.

**Issue: Missing dependencies or Lua errors**

* **Solution**: Check that all required addons are installed and that you're using compatible versions of Garry's Mod and any required dependencies.

### Getting Help

If you encounter issues not covered here:

1. **Check Server Console**: Review detailed error messages in your server console
2. **Community Support**: Visit the [Lilia Discord](https://discord.gg/esCRH5ckbQ) for community assistance
3. **GitHub Issues**: Review the [GitHub Issues](https://github.com/LiliaFramework/Lilia/issues) for known problems and solutions
