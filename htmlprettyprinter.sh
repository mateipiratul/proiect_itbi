#!/bin/bash

# Function to format an HTML file
format_html() {
    input_file="$1"
    output_file="${input_file%.html}_formatted.html"

    # Check if the file exists and is readable
    if [[ ! -r "$input_file" ]]; then
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
    formatted_lines=""

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
            formatted_lines+="$(printf '%*s%s\n' $((indent_level * 4)) '' "$tag")"
            continue
        fi

        # Check if the tag is a closing tag
        if echo "$tag" | grep -qE "^</[^>]+>$"; then
            indent_level=$((indent_level - 1))
        fi

        # Add the tag with indentation
        formatted_lines+="$(printf '%*s%s\n' $((indent_level * 4)) '' "$tag")"

        # Check if the tag is an opening tag
        if echo "$tag" | grep -qE "^<[^/][^>]*>$"; then
            indent_level=$((indent_level + 1))
        fi
    done

    # Write the formatted content to the output file
    echo "$formatted_lines" > "$output_file"
    echo "HTML formatted and written to: $output_file"
}

# Main script execution
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <absolute-path-to-html-file>"
    exit 1
fi

format_html "$1"
