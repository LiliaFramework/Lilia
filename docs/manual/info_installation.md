# Information - Installation Tutorial

Lilia is a versatile roleplaying framework for the Garry's Mod game. This tutorial will guide you through the process of installing Lilia for your Garry's Mod server.

## Prerequisites

Before you begin, make sure you have the following:

-   A working Garry's Mod server.

-   Basic knowledge of Garry's Mod server administration.

-   An understanding of how to use the command line.

-   An Admin Menu (we recommend [SAM](https://www.gmodstore.com/market/view/sam)).

## Step 1: Setting Up Your Garry's Mod Server

If you haven't already, set up your Garry's Mod server and ensure it's running without any issues.

## Step 2: Downloading Lilia

-   After downloading the ZIP file, visit the Lilia GitHub repository: [Lilia GitHub Repo](https://github.com/LiliaFramework/Lilia).

-   Click on the green "Code" button and select "Download ZIP."

-   Save the ZIP file to a location on your computer.

## Step 3: Extracting Lilia

-   After downloading, locate the ZIP file and extract its contents to a temporary folder on your computer.

-   You should now have a folder named something like "Lilia-main.zip."

-   Extract the contents inside to a folder within your desktop.

-   You will be faced with several files alongside with 2 folders: `docs` and `lilia`. Move `lilia` into a separate folder.

## Step 4: Uploading Lilia to Your Server

-   Connect to your server using a tool like FTP or SFTP.

-   Navigate to the `garrysmod/gamemodes` directory within your server.

-   Upload the previously mentioned "lilia" folder into the `gamemodes` directory.

## Step 5: Configuring Lilia

-   Before making any changes, consider making a backup of the default configuration.

-   Edit this [configuration](https://github.com/LiliaFramework/Lilia-Skeleton/blob/main/skeleton/schema/config/shared.lua) to override any default values you wish.

## Step 6: Starting Lilia on Your Server

-   Restart your Garry's Mod server for the changes to take effect.

-   If you encounter any issues, refer to the troubleshooting tips in the documentation.

## Step 7: Installing Roleplay Schemas

To install a roleplay schema for your Lilia framework, follow these steps:

-   Download one of the available schemas from the repositories listed below, based on your server's theme:
    -   [Framework](https://github.com/LiliaFramework/Lilia)

    -   [Skeleton Schema](https://github.com/LiliaFramework/Lilia-Skeleton)

    -   [MafiaRP Schema](https://github.com/LiliaFramework/Lilia-MafiaRP)

    -   [HL2RP Schema](https://github.com/LiliaFramework/Lilia-HL2RP)

    -   [MetroRP Schema](https://github.com/LiliaFramework/Lilia-MetroRP)

    -   [1942RP Schema](https://github.com/LiliaFramework/Lilia-1942RP)

    -   [Public Modules](https://github.com/LiliaFramework/Lilia-Modules)

    -   [Bozy's Modules](https://github.com/B0zy/Boz-Lilia-Modules)

-   Set up factions, items, and modules as required.

-   Set the startup gamemode to the schema folder ID within your server's startup configuration.

That's it! You've successfully installed a roleplay schema using Lilia. Enjoy your customized roleplaying experience!

## Conclusion

Congratulations! You've successfully installed Lilia and set up your own roleplaying schema on your Garry's Mod server. Remember that Lilia offers a wide range of features and customization options, so be sure to explore its documentation and community resources to make the most out of your roleplaying experience.