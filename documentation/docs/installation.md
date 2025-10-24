# Installation Guide

Install the Lilia framework on your Garry's Mod server using Steam Workshop.

> **Important**: Lilia is a framework that runs beneath a roleplay schema. After installing Lilia, you must also install a schema and start your server using that schema's gamemode (e.g., `+gamemode skeleton`).

## Prerequisites

* A working Garry's Mod server
* Basic server administration knowledge
* Internet connection for Workshop downloads

**Admin Tools**: Lilia includes a built-in admin menu. [SAM](https://www.gmodstore.com/market/view/sam) is also compatible. ULX is not supported.

---

## Installation Steps

### Step 1: Subscribe to Lilia

1. Visit the [Lilia Framework Workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=3527535922)
2. Click "Subscribe" to download Lilia to your Garry's Mod installation
3. Workshop ID: `3527535922`

### Step 2: Configure Server Workshop

1. Create a Steam Workshop collection that includes the Lilia Framework
2. Add this parameter to your server startup options:

   ```plaintext
   +host_workshop_collection <YourCollectionID>
   ```

   > **Note**: Replace `<YourCollectionID>` with your Workshop collection ID. Add this to your server's startup parameters, not `server.cfg`.

3. The server will automatically download Lilia when it starts

   > **Warning**: Workshop errors will prevent Lilia from loading. Ensure your server has stable internet connectivity and monitor the console for errors during startup.

### Step 3: Install a Schema

1. Download a schema (e.g., [Skeleton Schema](https://github.com/LiliaFramework/Skeleton))
2. Extract and upload to `garrysmod/gamemodes/<SchemaName>/`
3. Add this to your server startup options:

   ```plaintext
   +gamemode <SchemaName>
   ```

   Example: `+gamemode skeleton`

### Step 4: Start Your Server

Launch your server and watch the console for:

```plaintext
[Lilia] [Bootstrap] Loaded successfully after X seconds.
```

If you see this message and no errors, Lilia is working correctly.

## Troubleshooting

**"Gamemode 'skeleton' is missing"** - Check that your schema is installed in `garrysmod/gamemodes/` with the correct folder name

**Workshop items not downloading** - Verify internet connection and Workshop parameters in startup options (not `server.cfg`)

**"Lilia framework not found"** - Ensure you're subscribed to the Lilia Workshop addon and check console for download messages

**Server won't start with new gamemode** - Verify `+gamemode <SchemaName>` is set in your server startup options

**Need more help?** - Check server console for error messages - Visit [Lilia Discord](https://discord.gg/esCRH5ckbQ) for community support - Review [GitHub Issues](https://github.com/LiliaFramework/Lilia/issues) for known problems
