import re

def format_html(file_path):
    try:
        with open(file_path, 'r', encoding="utf-8") as file:
            lines = file.readlines()
        indent_level = 0
        formatted_lines = []
        taguri_self_closing = ["area", "base", "br", "col", "embed", "hr", "img", "input",
                               "link", "meta", "param", "source", "track", "wbr", "frame",
                               "command", "keygen", "menuitem"]

        for line in lines:
            line = line.strip()
            if not line:
                continue

            # Remove attributes and inner text
            line = re.sub(r'<(\w+)[^>]*>', r'<\1>', line)  # Simplify opening tags
            line = re.sub(r'>.*?(?=<|$)', r'>', line)  # Remove inner text between tags

            # Check if the line is a self-closing tag
            is_self_closing = any(
                re.match(fr'<{tag}[^>]*>$', line) for tag in taguri_self_closing
            )
            if is_self_closing:
                # Add the line without changing the indentation level
                formatted_lines.append('    ' * indent_level + line)
                continue

            # Detect closing tags
            if re.match(r'</[^>]+>', line):
                indent_level -= 1

            # Add the line with the correct indentation level
            formatted_lines.append('    ' * indent_level + line)

            # Detect opening tags that are not self-closing
            if re.match(r'<[^/!][^>]*[^/]>$', line):
                indent_level += 1

        # Write the formatted result to a new file
        output_file = file_path.replace('.html', '_formatted.html')
        with open(output_file, 'w', encoding="utf-8") as file:
            file.write('\n'.join(formatted_lines))

        print(f"HTML formatted and written to: {output_file}")

    except FileNotFoundError:
        print("The specified file was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == '__main__':
    file_path = "index.html"
    format_html(file_path)
