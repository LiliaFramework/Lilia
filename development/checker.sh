#!/bin/bash


# Execute the workflow
cd ..
ls
cd ..
ls
echo "Setting up Lua..."
sudo apt update && sudo apt install -y lua5.2 luarocks liblua5.2-dev

echo "Cloning and building gluacheck..."
git clone https://github.com/impulsh/gluacheck.git gluacheck
cd gluacheck || exit
sudo luarocks make
ls
cd ..
ls
echo "Running gluacheck..."
ls && cd "Lilia-Experimental/lilia" && luacheck . --no-redefined \
  --no-global --no-self \
  --no-max-line-length --no-max-code-line-length \
  --no-max-string-line-length --no-max-comment-line-length && cd .. && ls

echo "Cleaning up..."
cd ..
sudo rm -rf gluacheck

echo "Script completed successfully!"
