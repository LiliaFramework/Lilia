#!/bin/bash

# Step 1: Download glualint
echo "Step 1: Downloading glualint..."
curl -L -o glualint.zip https://github.com/FPtje/GLuaFixer/releases/download/1.26.0/glualint-1.26.0-x86_64-linux.zip

# Step 2: Unzip glualint
echo "Step 2: Unzipping glualint..."
unzip glualint.zip -d glualint

# Step 3: Move glualint executable to the root directory
echo "Step 3: Moving glualint executable to the root directory..."
mv glualint/glualint glualint_executable

# Step 4: Run glualint pretty-print
echo "Step 4: Running glualint pretty-print..."
chmod +x glualint_executable
./glualint_executable pretty-print /workspaces/Lilia-Experimental/lilia/modularity/*
./glualint_executable pretty-print /workspaces/Lilia-Experimental/lilia/libraries/*
./glualint_executable pretty-print /workspaces/Lilia-Experimental/lilia/gamemode/*
 
# Step 5: Remove the glualint folder
echo "Step 5: Removing the glualint folder..."
sudo rm -r glualint

# Step 6: Delete the zip file
echo "Step 6: Deleting glualint.zip..."
sudo rm glualint.zip

# Step 7: Delete glualint_executable file
echo "Step 7: Deleting glualint_executable..."
sudo rm glualint_executable
echo "Script completed."
