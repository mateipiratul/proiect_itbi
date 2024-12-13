import re

def format_html(file):
    try:
        with open(file_path, 'r', encoding="utf-8") as file:
            lines = file.readlines()
        indent_level = 0
        formatted_lines = []

        for line in lines:
            line = line.strip()

            if not line:
                continue  # Sarim peste liniile goale

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
    f = open(file_path)
    format_html(f)