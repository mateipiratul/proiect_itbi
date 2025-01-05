import re

def format_html(file_path):
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            text = " ".join(file.read().strip().split())

        # remove all comments
        text = re.sub(r'<!--.*?-->', '', text, flags=re.DOTALL)

        indent_level = 0
        formatted_lines = []
        taguri_self_closing = ["area", "base", "br", "col", "embed", "hr", "img", "input",
                               "link", "meta", "param", "source", "track", "wbr", "frame",
                               "command", "keygen", "menuitem"]

        # remove attributes from tags
        text = re.sub(r'<(\w+)[^>]*?>', r'<\1>', text)
        tags = re.findall(r'<[^>]*?>', text)

        for box in tags:
            box = box.strip()
            if not box:  # skip empty strings
                continue

            # detect self-closing tags
            is_self_closing = any(
                re.match(fr'<{tag}\s*/?>$', box, re.IGNORECASE) for tag in taguri_self_closing
            ) or re.match(r'<![^>]+>$', box, re.IGNORECASE)

            if is_self_closing:
                formatted_lines.append('    ' * indent_level + box)
                continue

            # detect closing tags
            if re.match(r'</[^>]+>$', box):
                indent_level -= 1

            # indentation level setting
            formatted_lines.append('    ' * indent_level + box)

            # detect opening tags
            if re.match(r'<[^/][^>]*>$', box):
                indent_level += 1

        # create the output file name
        output_file = file_path.replace(".html", "_formatted.html")

        # write the formatted content to the output file
        with open(output_file, "w", encoding="utf-8") as file:
            file.write('\n'.join(formatted_lines))

        print(f"HTML formatted and written to: {output_file}")

    except FileNotFoundError:
        print("The specified file was not found.")
    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == '__main__':
    print("Enter the HTML file name:")
    user_input = input("> ").strip()
    format_html(user_input)
