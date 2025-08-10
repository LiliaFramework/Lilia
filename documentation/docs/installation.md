# Installation Tutorial

Lilia is a versatile roleplay framework for Garry's Mod. This tutorial guides you through installing Lilia on your server so you can create a stable roleplaying environment.

> **Note**

> Lilia runs beneath a roleplay schema. After installing Lilia, you must also install a schema and start your server using that schema's gamemode (for example, `+gamemode skeleton`).

---

## Prerequisites

Before you begin, make sure you have the following:

- **A Working Garry's Mod Server:**

Make sure your server is set up and running without issues.

- **Basic Knowledge of Server Administration:**

Familiarity with managing a Garry's Mod server is helpful.

- **Command Line Proficiency:**

You should be comfortable using the command line.

- **Admin Menu:**

Lilia includes a built-in admin menu for logging, tickets and teleport tools. [SAM](https://www.gmodstore.com/market/view/sam) is also compatible. **ULX is not supported because its CAMI library is outdated.**

- **Code Editor (optional):**

If you don't already have one, a code editor makes development easier. Recommended editors include:

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

## Step 5: Installing a Roleplay Schema

Enhance your roleplaying experience by installing a compatible roleplay schema for the Lilia framework. Follow the steps below:

### 1. Choose a Schema

Select a schema that fits your server theme:

- **Skeleton Schema**

    - [GitHub Repository](https://github.com/LiliaFramework/Skeleton)

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
Preload:   garrysmod/gamemodes/<SchemaName>/preload/
```

---

## Step 6: Launching the Server with Your Schema

1. **Set the Startup Gamemode**

    Edit your server's startup parameters so the server boots directly into your chosen schema:

    ```plaintext

    +gamemode <SchemaName>

    ```

    Example usage:

    ```plaintext

    +gamemode skeleton

    ```

2. **Start the Server**

    Launch or restart your Garry's Mod server. Lilia will load as the framework beneath the schema.

3. **Verify the Installation**

    Watch the console for a line such as:

    ```plaintext

    [Lilia] [Bootstrap] Loaded successfully after X seconds.

    ```

    If no errors appear and the schema loads, you're ready to play.
