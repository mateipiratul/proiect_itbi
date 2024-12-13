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
                continue  # Sarim peste liniile goale

            # Verificam daca linia este un tag self-closing
            is_self_closing = any(
                re.match(fr'<{tag}[^>]*>$', line) for tag in taguri_self_closing
            )

            if is_self_closing:
                # Adaugam linia fara a schimba nivelul de indentare
                formatted_lines.append('    ' * indent_level + line)
                continue

            # Detectam tag-urile de inchidere
            if re.match(r'</[^>]+>', line):
                indent_level -= 1

            # Adaugam linia cu nivelul de indentare corespunzator
            formatted_lines.append('    ' * indent_level + line)

            # Detectam tag-urile de deschidere care nu sunt self-closing
            if re.match(r'<[^/!][^>]*[^/]>$', line):
                indent_level += 1

        # Scriem rezultatul formatat intr-un fisier nou
        output_file = file_path.replace('.html', '_formatted.html')
        with open(output_file, 'w', encoding="utf-8") as file:
            file.write('\n'.join(formatted_lines))

        print(f"HTML formatat scris in:\n{output_file}")

    except FileNotFoundError:
        print("Fisierul specificat nu a fost gasit.")
    except Exception as e:
        print(f"A aparut o eroare: {e}")


if __name__ == '__main__':
    file_path = "index.html"
    format_html(file_path)
