#!/bin/bash

# Checkout code
echo "Checking out code..."
git clone https://github.com/Lilia-Framework/Lilia.git lilia

# Setup Lua
echo "Setting up Lua..."
lua_version="5.2"
curl -L https://github.com/leafo/gh-actions-lua/releases/download/v8.0.0/setup_lua.sh | LUA_VERSION=${lua_version} bash

# Setup LuaRocks
echo "Setting up LuaRocks..."
curl -L https://github.com/leafo/gh-actions-luarocks/releases/download/v4.0.0/setup_luarocks.sh | bash

# Pull LDoc
echo "Pulling LDoc..."
git clone https://github.com/impulsh/LDoc.git ldoc

# Build LDoc
echo "Building LDoc..."
cd ldoc
luarocks make

# Build docs
echo "Building docs..."
cd ..
ldoc lilia --fatalwarnings

# Copy assets
echo "Copying assets..."
cp -v lilia/docs/css/* lilia/docs/html
cp -v lilia/docs/js/* lilia/docs/html

# Delete old files
echo "Deleting old files..."
rm -rf lilia/docs/*

echo "Done!"
