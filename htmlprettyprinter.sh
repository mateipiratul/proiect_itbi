#!/bin/bash

format_html_tree() {
    input_file="$1"
    output_file="format_tree.txt"

    echo "File path received: '$input_file'"

    if [ ! -f "$input_file" ]; then
        echo "Error: File cannot be opened or does not exist."
        exit 1
    fi

    # verificare extensie
    if [[ "$input_file" != *.html ]]; then
        echo "Error: The input file must have a .html extension."
        exit 1
    fi

    # stergere newline si whitespace
    text=$(tr -d '\n' < "$input_file" | sed 's/> *</></g')

    # verificare taguri invalide
    if echo "$text" | grep -qE '<\s+[^>]*>'; then
        echo "Error: Invalid tag detected (spaces after '<')."
        exit 1
    fi

    # stergere comentarii
    text=$(echo "$text" | sed -E 's/<!--.*?-->//g')

    # stergere <!DOCTYPE>
    if echo "$text" | grep -iqE '^<!DOCTYPE[^>]*>'; then
        text=$(echo "$text" | sed -E 's/^<![dD][^>]*>//')
    fi

    # simplificarea tagurilor
    text=$(echo "$text" | sed -E 's/<([a-zA-Z0-9]+)[^>]*?>/<\1>/g')

    # definirea tagurilor self-closing
    self_closing_tags=("area" "base" "br" "col" "embed" "hr" "img" "input" "link" "meta" "param" "source" "track" "wbr" "frame" "command" "keygen" "menuitem" "!DOCTYPE")

    # initializarea variabilelor
    indent_level=0
    formatted_lines=()
    indent_stack=()

    # extragerea tagurilor
    tags=$(echo "$text" | grep -oP '<[^>]*?>')

    # procesarea acestora
    for tag in $tags; do
        tag=$(echo "$tag" | xargs) # strip spatii

        # verificare taguri self-closing
        is_self_closing=false
        for self_tag in "${self_closing_tags[@]}"; do
            if echo "$tag" | grep -iqE "^<${self_tag}(/?>)?$"; then
                is_self_closing=true
                break
            fi
        done

        # taguri closing
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

        # cresterea indentarii
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
