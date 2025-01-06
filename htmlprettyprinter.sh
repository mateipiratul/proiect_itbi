#!/bin/bash

format_html_tree() {
    input_file="$1"
    output_file="format_tree.txt"

    echo "File path received: '$input_file'"

    if [ ! -f "$input_file" ]; then
        echo "Error: File cannot be opened or does not exist."
        exit 1
    fi

    # stergere newline/whitespace
    text=$(tr -d '\n' < "$input_file" | sed 's/> *</></g')

    # stergere comentarii
    text=$(echo "$text" | sed -E 's/<!--.*?-->//g')

    # sterge <!DOCTYPE>
    if echo "$text" | grep -iqE '^<!DOCTYPE[^>]*>'; then
        text=$(echo "$text" | sed -E 's/^<![dD][^>]*>//')
    fi

    # simplificare taguri
    text=$(echo "$text" | sed -E 's/<([a-zA-Z0-9]+)[^>]*?>/<\1>/g')

    # definire taguri self-closing
    self_closing_tags=("area" "base" "br" "col" "embed" "hr" "img" "input" "link" "meta" "param" "source" "track" "wbr" "frame" "command" "keygen" "menuitem" "!DOCTYPE")

    # init variabile
    indent_level=0
    formatted_lines=()
    indent_stack=()

    # extragere taguri
    tags=$(echo "$text" | grep -oP '<[^>]*?>')

    # procesarea tagurilor
    for tag in $tags; do
        tag=$(echo "$tag" | xargs) # strip spatii

        # taguri self-closing
        is_self_closing=false
        for self_tag in "${self_closing_tags[@]}"; do
            if echo "$tag" | grep -iqE "^<${self_tag}(/?>)?$"; then
                is_self_closing=true
                break
            fi
        done

        # closing tag
        if echo "$tag" | grep -qE "^</[^>]+>$"; then
            indent_level=$((indent_level - 1))
            indent_stack[$indent_level]=0
        fi

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

        formatted_lines+=("${tree_prefix}${tag}")

        # increase indent
        if echo "$tag" | grep -qE "^<[^/][^>]*>$" && [[ "$is_self_closing" == false ]]; then
            indent_stack[$indent_level]=1
            indent_level=$((indent_level + 1))
        fi
    done

    printf "%s\n" "${formatted_lines[@]}" > "$output_file"
    echo "HTML tree formatted and written to: $output_file"
}

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <absolute_path_to_html_file>"
    exit 1
fi

input_file="$1"

input_file=$(echo "$input_file" | xargs)

if [ ! -e "$input_file" ]; then
    echo "Debug: File does not exist at the path provided: $input_file"
    exit 1
fi

format_html_tree "$input_file"
exit 0