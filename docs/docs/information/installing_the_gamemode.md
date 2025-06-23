## Installation Tutorial

Lilia is a versatile roleplaying framework for Garry's Mod. This tutorial will guide you through installing Lilia on your Garry's Mod server, ensuring a smooth setup for your roleplaying environment.

---

## Prerequisites

Before you begin, ensure you have the following:

- **A Working Garry's Mod Server:** Ensure your server is properly set up and running without issues.
- **Basic Knowledge of Server Administration:** Familiarity with managing a Garry's Mod server is beneficial.
- **Command Line Proficiency:** Understanding the command line is necessary for certain installation steps.
- **Admin Menu:** We recommend using [SAM](https://www.gmodstore.com/market/view/sam) for enhanced administrative capabilities.
- **Code Editor (optional):**

  If you do not already have one, it is highly recommended to use a code editor to develop your scripts. Recommended editors include:
  
  1. [Visual Studio Code](https://code.visualstudio.com/)
  2. [Notepad++](https://notepad-plus-plus.org/)
  3. [Sublime Text](https://www.sublimetext.com/)
  4. [Atom](https://atom.io/)

---

## Step 1: Setting Up Your Garry's Mod Server

If you haven't already, set up your Garry's Mod server and ensure it is running smoothly before proceeding with the installation of Lilia.

---

## Step 2: Downloading Lilia

1. **Visit the Lilia GitHub Repository:**

    Navigate to the [Lilia GitHub Repository](https://github.com/LiliaFramework/Lilia).

2. **Download the ZIP File:**  
    - Download the latest release directly from [here](https://github.com/LiliaFramework/Lilia/releases/download/release/lilia.zip).  
    - Save the ZIP file to a convenient location on your computer.

---

## Step 3: Extracting Lilia

1. **Locate the Downloaded ZIP File:**

    Find the `Lilia.zip` file you downloaded.

2. **Extract the Contents:**

    - Right-click the ZIP file and select "Extract All."
    - Choose a temporary folder for extraction.

3. **Organize the Extracted Files:**

    - After extraction, you should see a folder named `lilia`.
    - Move the `lilia` folder to a separate location for easy access during the upload process.

---

## Step 4: Uploading Lilia to Your Server

1. **Connect to Your Server:**

    Use an FTP or SFTP client (e.g., [FileZilla](https://filezilla-project.org/) or [WinSCP](https://winscp.net/eng/index.php)) to connect to your Garry's Mod server.

2. **Navigate to the Gamemodes Directory:**

    Go to `garrysmod/gamemodes` within your server's file structure.

3. **Upload the Lilia Folder:**

    Upload the `lilia` folder you extracted earlier into the `gamemodes` directory.

    ```plaintext
    Server Directory Path:
    garrysmod/gamemodes/lilia
    ```

---

## Step 5: Starting Lilia on Your Server

1. **Start Your Garry's Mod Server:**

    Once you have uploaded Lilia and completed the configuration, start your Garry's Mod server.

2. **Verify Lilia is Running:**

    - Monitor the **server console** for any error messages related to Lilia during startup.
    - Look for a confirmation message indicating that Lilia has loaded successfully.
    - Ensure there are no errors and that the server is running smoothly with Lilia active.

    ```plaintext
    Example Console Output:
    [Lilia] [Bootstrap] Loaded successfully after X seconds.
    ```

---

## Step 7: Installing Roleplay Schemas

Enhance your roleplaying experience by installing a compatible roleplay schema for the Lilia framework. Follow the steps below:

### 1. Choose a Schema

Select a schema that fits your server theme:

- **Skeleton Schema**
    - [GitHub Repository](https://github.com/LiliaFramework/Skeleton)
    - [Direct Download](https://github.com/LiliaFramework/SCPRP/releases/download/release/scprp.zip)

- **SCPRP Schema**
    - [GitHub Repository](https://github.com/LiliaFramework/SCPRP)
    - [Direct Download](https://github.com/LiliaFramework/Skeleton/releases/download/release/skeleton.zip)

---

### 2. Download the Schema

Visit the schema's GitHub repository or use the direct download link, and download the ZIP file or clone the repository.

---

### 3. Extract and Upload

Extract the schema files locally, then upload the extracted folder to your server:

```plaintext
garrysmod/gamemodes/<SchemaName>
```

---

### 4. Configure the Schema

Customize the following directories as needed for your server’s gameplay:

```plaintext
Factions:  garrysmod/gamemodes/<SchemaName>/schema/factions/
Classes:   garrysmod/gamemodes/<SchemaName>/schema/classes/
Items:     garrysmod/gamemodes/<SchemaName>/schema/items/
Modules:   garrysmod/gamemodes/<SchemaName>/modules/
```

---

### 5. Set the Startup Gamemode

Edit your server's startup parameters to set the gamemode:

```plaintext
+gamemode <SchemaName>
```

Example Usage:

```plaintext
+gamemode scprp
```

---

### 6. Restart the Server

Restart your Garry's Mod server and verify that the schema loads correctly with all configurations applied.