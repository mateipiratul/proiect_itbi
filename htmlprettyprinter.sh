#!/bin/bash

# Function to format an HTML file and display as a tree
format_html_tree() {
    input_file="$1"
    output_file="format_tree.txt"

    # Debug: Print the file path received
    echo "File path received: '$input_file'"

    # Check if the file exists and is readable
    if [ ! -f "$input_file" ]; then
        echo "Error: File cannot be opened or does not exist."
        exit 1
    fi

    # Read the file and remove newlines/whitespace between tags
    text=$(tr -d '\n' < "$input_file" | sed 's/> *</></g')

    # Remove comments (e.g., <!-- some comment -->)
    text=$(echo "$text" | sed -E 's/<!--.*?-->//g')

    # Remove the first line if it contains <!DOCTYPE>
    if echo "$text" | grep -iqE '^<!DOCTYPE[^>]*>'; then
        text=$(echo "$text" | sed 's/^<!DOCTYPE[^>]*>//')
    fi

    # Simplify tags while keeping < and >
    text=$(echo "$text" | sed -E 's/<([a-zA-Z0-9]+)[^>]*?>/<\1>/g')

    # Define self-closing tags
    self_closing_tags=("area" "base" "br" "col" "embed" "hr" "img" "input" "link" "meta" "param" "source" "track" "wbr" "frame" "command" "keygen" "menuitem")
    self_closing_tags+=("!DOCTYPE")

    # Initialize variables
    indent_level=0
    formatted_lines=()
    indent_stack=()

    # Extract all tags
    tags=$(echo "$text" | grep -oP '<[^>]*?>')

    # Process each tag
    for tag in $tags; do
        tag=$(echo "$tag" | xargs) # Trim spaces

        # Check if the tag is self-closing
        is_self_closing=false
        for self_tag in "${self_closing_tags[@]}"; do
            if echo "$tag" | grep -iqE "^<${self_tag}(/?>)?$"; then
                is_self_closing=true
                break
            fi
        done

        # Check if the tag is a closing tag
        if echo "$tag" | grep -qE "^</[^>]+>$"; then
            indent_level=$((indent_level - 1))
            indent_stack[$indent_level]=0
        fi

        # Determine the appropriate tree symbols
        tree_prefix=""
        for ((i = 0; i < indent_level; i++)); do
            if [[ "${indent_stack[$i]}" -eq 1 ]]; then
                tree_prefix+="│   "
            else
                tree_prefix+="    "
            fi
        done

        if [[ "$is_self_closing" == true ]]; then
            tree_prefix+="├── "
        elif echo "$tag" | grep -qE "^</[^>]+>$"; then
            tree_prefix+="└── "
        else
            if [[ $indent_level -gt 0 ]]; then
                tree_prefix+="├── "
            else
                tree_prefix+="└── "
            fi
        fi

        # Add the tag to formatted lines
        formatted_lines+=("${tree_prefix}${tag}")

        # If the tag is an opening tag, increase indent
        if echo "$tag" | grep -qE "^<[^/][^>]*>$" && [[ "$is_self_closing" == false ]]; then
            indent_stack[$indent_level]=1
            indent_level=$((indent_level + 1))
        fi
    done

    # Write the formatted content to the output file
    printf "%s\n" "${formatted_lines[@]}" > "$output_file"
    echo "HTML tree formatted and written to: $output_file"
}

# Main script execution
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <absolute_path_to_html_file>"
    exit 1
fi

# Get the absolute path from the first argument
input_file="$1"

# Trim any leading or trailing spaces
input_file=$(echo "$input_file" | xargs)

# Debug: Confirm the input file exists
if [ ! -e "$input_file" ]; then
    echo "Debug: File does not exist at the path provided: $input_file"
    exit 1
fi

# Pass the input to the function
format_html_tree "$input_file"
exit 0