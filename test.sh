#!/bin/bash

# Define the output folder
output_folder="docs/modules"

# Create the output folder if it doesn't exist
mkdir -p "$output_folder"

# Function to create markdown files with given topics
create_markdown_file() {
    topic="$1"
    filename="$output_folder/$topic.md"
    echo "# $topic" > "$filename"
    echo "File '$filename' created."
}

# Generate markdown files for each topic
create_markdown_file "Attributes"
create_markdown_file "Bodygrouper"
create_markdown_file "Storage"
create_markdown_file "Inventory"

echo "Markdown files generated in '$output_folder' folder."
