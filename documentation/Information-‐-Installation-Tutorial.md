## Lilia Installation Tutorial

Lilia is a versatile roleplaying framework for the Garry's Mod game. This tutorial will guide you through the process of installing Lilia for your Garry's Mod server.

## Prerequisites

Before you begin, make sure you have the following:

- A working Garry's Mod server.
- Basic knowledge of Garry's Mod server administration.
- An understanding of how to use the command line.
- An Admin Menu (we recommend SAM).

## Step 1: Setting Up Your Garry's Mod Server

If you haven't already, set up your Garry's Mod server and ensure it's running without any issues.

## Step 2: Downloading Lilia

1. After downloading the ZIP file, visit the Lilia GitHub repository: [Lilia GitHub Repo](https://github.com/bleonheart/Lilia).
2. Pick the branch you wish to use; we recommend 2.0.
3. Click on the green "Code" button and select "Download ZIP."
4. Save the ZIP file to a location on your computer.

## Step 3: Extracting Lilia

1. After downloading, locate the ZIP file and extract its contents to a temporary folder on your computer.
2. You should now have a folder named something like "Lilia-master."

## Step 4: Uploading Lilia to Your Server

1. Connect to your server using a tool like FTP or SFTP.
2. Navigate to the `garrysmod/gamemodes` directory within your server.
3. Upload the "lilia" folder into the `gamemodes` directory.

## Step 5: Configuring Lilia

1. Before making any changes, consider making a backup of the default configuration.
2. Edit this [configuration](https://github.com/bleonheart/Lilia-Skeleton/blob/main/skeleton/schema/sh_config.lua) to override any default values you wish.
3. Copy the modified configuration to your schema folder.
4. Include it in your sh_schema using the [following line](https://github.com/bleonheart/Lilia-Skeleton/blob/main/skeleton/schema/sh_schema.lua#L8C1-L9C1).

## Step 6: Starting Lilia on Your Server

1. Restart your Garry's Mod server for the changes to take effect.
2. If you encounter any issues, refer to the troubleshooting tips in the documentation.

## Step 7: Installing Roleplay Schemas

To install a roleplay schema for your Lilia framework, follow these steps:

1. Download one of the available schemas from the repositories listed below, based on your server's theme:

- [Framework](https://github.com/Lilia-Framework/Lilia)
- [1942RP Schema](https://github.com/Lilia-Framework/Lilia-1942RP)
- [Skeleton Schema](https://github.com/Lilia-Framework/Lilia-Skeleton)
- [MafiaRP Schema](https://github.com/Lilia-Framework/Lilia-MafiaRP)
- [HL2RP Schema](https://github.com/Lilia-Framework/Lilia-HL2RP)
- [MetroRP Schema](https://github.com/Lilia-Framework/Lilia-MetroRP)
- [Public Modules](https://github.com/Lilia-Framework/Lilia-Modules)
- [Bozy's Modules](https://github.com/B0zy/Boz-Lilia-Modules)

2. Set up factions, items, and modules as required, following the specific schema's documentation or online resources.
3. Set the startup gamemode to the schema folder ID within your server's startup configuration.

That's it! You've successfully installed a roleplay schema using Lilia. Enjoy your customized roleplaying experience!

## Conclusion

Congratulations! You've successfully installed Lilia and set up your own roleplaying schema on your Garry's Mod server. Remember that Lilia offers a wide range of features and customization options, so be sure to explore its documentation and community resources to make the most out of your roleplaying experience.
