#!/bin/bash

# Hardcoded folder path
folder_path="/workspaces/Lilia/lilia/modules"

# Log file to keep track of changes
log_file="change_registry.txt"

# List of attributes to search for
attributes=("AttributesCore" "BodygrouperCore" "LiliaStorage" "InventoryCore" "PermaKillCore"
            "RaisedWeaponCore" "RealisticDamageCore" "RecognitionCore" "SalaryCore"
            "VendorCore" "AdvDupeCompatibility" "AdvDupe2Compatibility" "MLogsCompatibility"
            "PACCompatibility" "PermaPropsCompatibility" "PlayXCompatibility" "ProneModCompatibility"
            "SAMCompatibility" "SGCompatibility" "SimfphysCompatibility" "SittingCompatibility"
            "Stormfox2Compatibility" "StreamRadiosCompatibility" "ULXCompatibility" "VCModCompatibility"
            "VJBaseCompatibility" "EntityPerfomanceCore" "PlayerPerfomanceCore" "PerfomanceCore"
            "NoClipCore" "PhysGunCore" "PropertiesCore" "SpawningCore" "ToolGunCore"
            "PermissionCore" "AntiGMODExploitsCore" "AntiPlayerExploitsCore" "AntiExploitsCore"
            "AntiFamilySharingCore" "AntiHackingCore" "APSCore" "CharacterAnalysisCore"
            "ProtectionCore" "SpawnsCore" "TeamsCore" "VoiceCore" "ChatboxCore" "CrashScreenCore"
            "CreditsCore" "F1MenuCore" "FrameworkHUD" "PIM" "CharacterSelectionCore" "MainMenu"
            "ScoreboardCore" "WSCore" "AFKKickerCore" "AmmoSaveCore" "DoorsCore" "FlashlightCore"
            "SaveItemsCore" "LoggerCore" "PersistanceCore" "Realistic1stPersonViewCore" "STCore"
            "ThirdPersonCore" "TypingCore" "EasyWeaponsCore" "WhitelistCore" "WorkshoperCore")

# Initialize or create the log file
echo "Change Registry:" > "$log_file"
echo "----------------" >> "$log_file"

# Iterate through all files in the folder and its subdirectories
find "$folder_path" -type f ! -name "module.lua" -print0 | while IFS= read -r -d $'\0' file; do
    # Iterate through each attribute and perform replacements
    for attribute in "${attributes[@]}"; do
        # Perform replacements and append to the log file
        sed_output=$(sed -i "s/${attribute}\./MODULE\./g; s/${attribute}:/MODULE:/g" "$file" 2>&1)
        if [ -n "$sed_output" ]; then
            echo "File: $file, Attribute: $attribute - $sed_output" >> "$log_file"
        fi
    done
    echo "File $file updated."
done

echo "Processing complete. Check $log_file for details."
