# HTMLPrettyPrinter
## Matei-Iulian Cocu, Alexandru Ștefan Tinică
 
This project provides a script to process HTML files and display their hierarchical structure in a clear, tree-like format.

**Problem Statement:**
Parsing HTML documents and representing their structure hierarchically is crucial for understanding complex web pages. This tool addresses the need for a simplified, readable, and structured representation of HTML tag relationships.

**Key Objectives:**
*   Generate a text file (`format_tree.txt`) reflecting the HTML structure with specific indentations and symbols.
    *   `├` for elements at the same level.
    *   `└` for the last element at a given level.
    *   `│` for vertical connections between levels.
*   Enhance navigability and debugging for complex HTML documents.
*   Automate structural analysis for further applications like diagram generators or validation tools.

**Solution Specification:**
The "pretty" script processes an input HTML file to:
1.  **Eliminate Redundancies:** Removes unnecessary spaces, comments, and `<!DOCTYPE>` tags.
2.  **Simplify Tags:** Retains only the essential tag names.
3.  **Create Hierarchical Representation:** Uses symbols and indentations for each HTML level.

This solution tackles two main challenges:
*   Linear processing of HTML documents without a dedicated parser.
*   Clear and readable representation of the hierarchical structure in a text format.

**Usage Characteristics:**
*   **Simple Interface:** The script takes a single argument: the absolute path to the HTML file.
*   **Clear Error Messages:** Provides informative error messages for non-existent or corrupted files.
*   **Technical Aspects:**
    *   Runs on any Unix/Linux system using `sed`, `grep`, and `tr`.
    *   Compatible with large HTML files.
    *   Can be used as an intermediate step for HTML structure validation before full parsing.

**Minimal Use Cases:**
*   **Use Case 1:** User provides an existing HTML file, and the script generates `format_tree.txt` with the hierarchical structure.
*   **Use Case 2:** User provides an invalid HTML file (e.g., missing closing tags), and the script outputs clear error messages indicating the problem.

**Assumptions, Constraints, and Dependencies:**

*   **Assumptions:**
    *   Input HTML files are well-formed and valid.
    *   The user has access rights to the specified file.
    *   HTML tags are properly formatted and closed.
*   **Constraints:**
    *   The script does not perform full HTML validation against W3C standards.
    *   Extremely large files (>500 MB) might require longer processing times.
*   **Dependencies:**
    *   `grep`, `sed`, `tr` utilities must be available on the user's system.
    *   HTML files must be accessible via an absolute path.

**Software Architecture:**

1.  **HTML File Preprocessing:**
    *   Redundancies (spaces, comments, boilerplate tags) are eliminated using a chain of `sed`, `tr`, and `grep` commands for line-by-line processing.
    *   This step reduces the structural complexity to a minimal set of relevant elements.

2.  **Hierarchical Structure Identification:**
    *   Tags are extracted using regular expressions (`grep -oP '<[^>]*?>'`).
    *   A stack-based algorithm (simulated with Bash arrays) manages parent-child relationships between tags.

3.  **Tree Construction:**
    *   An incremental hierarchical representation is built with visual symbols and appropriate indentation.
    *   Indentation is controlled by an `indent_level` counter and an `indent_stack` that tracks branch continuity.

**Mechanisms and Algorithms:**

*   **Linear Processing (Unix Commands):**
    *   Standard utilities (`sed`, `grep`, `tr`) are chosen for their portability and ease of text processing.
    *   This approach is preferred for projects not requiring full W3C-compliant HTML parsing.

*   **Hierarchical Structure Management (Logic Stack):**
    *   A stack-based algorithm efficiently constructs hierarchical relationships with minimal memory proportional to the nesting level of HTML tags.

**Solutions for Technical Challenges:**

*   **Self-Closing Tag Differentiation:** An explicit list of self-closing tags is used for verification.
*   **Nested Tag Management:** A stack-based algorithm (simulated with Bash arrays) tracks nesting relationships.
*   **Space and Comment Removal:** Adaptive regular expressions are used to correctly remove `<!--.*?-->` comments and `> <` spaces between tags.
*   **Cross-Environment Compatibility:** The script has been tested on multiple Unix systems for portability, with `awk` or `perl` considered as fallbacks.

---
