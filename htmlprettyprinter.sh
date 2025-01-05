#!/bin/bash

# Function to format an HTML file
format_html() {
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

    # Remove attributes from tags
    text=$(echo "$text" | sed -E 's/<([a-zA-Z0-9]+)[^>]*>/\<\1>/g')

    # Define self-closing tags
    self_closing_tags=("area" "base" "br" "col" "embed" "hr" "img" "input" "link" "meta" "param" "source" "track" "wbr" "frame" "command" "keygen" "menuitem")
    
    # Add <!DOCTYPE> to self-closing tag handling
    self_closing_tags+=("!DOCTYPE")

    # Initialize variables
    indent_level=0
    formatted_lines=()

    # Extract all tags
    tags=$(echo "$text" | grep -oP '<[^>]*?>')

    for tag in $tags; do
        # Trim spaces
        tag=$(echo "$tag" | xargs)

        # Check if the tag is self-closing
        is_self_closing=false
        for self_tag in "${self_closing_tags[@]}"; do
            if echo "$tag" | grep -iqE "^<${self_tag}(/?>)?$"; then
                is_self_closing=true
                break
            fi
        done

        if $is_self_closing; then
            formatted_lines+=("$(printf '%*s%s' $((indent_level * 4)) '' "$tag")")
            continue
        fi

        # Check if the tag is a closing tag
        if echo "$tag" | grep -qE "^</[^>]+>$"; then
            indent_level=$((indent_level - 1))
        fi

        # Add the tag with proper indentation
        formatted_lines+=("$(printf '%*s%s' $((indent_level * 4)) '' "$tag")")

        # Check if the tag is an opening tag
        if echo "$tag" | grep -qE "^<[^/][^>]*>$"; then
            indent_level=$((indent_level + 1))
        fi
    done

    # Ensure the output file exists
    touch "$output_file"

    # Write the formatted content to the output file, joining lines with newline characters
    printf "%s\n" "${formatted_lines[@]}" > "$output_file"
    echo "HTML formatted and written to: $output_file"
}

# Main script execution
echo "Enter the absolute path to the HTML file:"
read -r input_file

# Trim any leading or trailing spaces
input_file=$(echo "$input_file" | xargs)

# Debug: Confirm the input file exists
if [ ! -e "$input_file" ]; then
    echo "Debug: File does not exist at the path provided: $input_file"
    exit 1
fi

# Pass the input to the function
format_html "$input_file"
exit 0
