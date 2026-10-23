# Emacs Configuration (GNU Emacs 31+)

A fast, lightweight, and educational configuration for **C, Go, and Zig** development, drawing inspiration from **Dennis Ritchie & Brian Kernighan (K&R)**, **Jonathan Blow**, **Casey Muratori**, **Alexey Kutepov (Tsoding)**, and **Aleksey Kladov (matklad)**.

---

## Structure

* **`init.el`**: Primary configuration with Tree-sitter, Eglot (LSP), Vertico, Consult, Corfu, Magit, and custom ergonomics.
* **`custom.el`**: Automatically generated Customize variables isolated from `init.el` to keep dotfiles clean and prevent theme conflicts.
* **`emacs-cheatsheet.pdf`**: Complete 4-page printable cheatsheet covering navigation, C editing, search, compilation, and LSP.
* **`master_linux/`**: Linux configuration mirror.
* **`win/`**: Windows configuration variant (Consolas, LLVM/clangd path).

---

## Key Features & Ergonomics

1. **Classic 4-Space K&R Indentation for C/C++**:
   * Functions start `{` on a newline at column 0 (`C-M-a` / `C-M-e` function navigation).
   * Control flow (`if`, `for`, `while`) keeps `{` on the same line.
   * `C-p` formats the buffer with standard 4-space K&R indentation via Tree-sitter without clangd 2-space distortion.

2. **Instant Rebuilds (Casey Muratori & Matklad)**:
   * **`F5`** or **`C-c C-c`**: Re-run the last compile command immediately without prompts.
   * **`C-c c`**: Trigger a new `compile` command.
   * Auto-saves buffers silently and formats ANSI color output.

3. **Fluid Editing (Tsoding & Matklad)**:
   * **`C-w` / `M-w`**: Cuts/copies the whole line when no region is active.
   * **`C-,`**: Duplicates current line without polluting clipboard/kill-ring.
   * **`M-p` / `M-n`**: Slides current line or selection up/down (`move-text`).
   * **`C-=`**: Expand region semantically (token -> expression -> block).

4. **Fast Navigation**:
   * **`C-x p f`**: Fuzzy project file finder.
   * **`M-s r`** / **`C-c f g`**: Project-wide ripgrep (`consult-ripgrep`).
   * **`M-.` / `M-,`**: Jump to definition (`xref-find-definitions`) / Jump back (`xref-go-back`).
   * **`C-x b`**: Live buffer switcher with previews.

5. **Systems Programming Toolkit (C, C++, POSIX, GDB)**:
   * **`C-c o`**: Instantly flip between `.h` header and `.c` source (`ff-find-other-file`).
   * **`C-c C-e`**: Expand C macro at point using compiler preprocessor (`c-macro-expand`).
   * **`C-c m`**: Open Linux/POSIX system call & C library man page (`man`).
   * **`M-x gdb`**: Visual 6-pane GDB debugging station (`gdb-many-windows`).
   * **Code Hygiene**: 80-column ruler indicator & automatic trailing whitespace strip on save.
   * **`M-x hexl-find-file`**: Hexadecimal / binary inspection side-by-side with ASCII.

6. **Visual Themes**:
   * **Default:** `solarized-light`
   * Available: `naysayer`, `gruber-darker`, `gruvbox`, `doom-themes`.
   * Switch anytime with `M-x load-theme RET`.

---

## Installation

Clone or link to your home directory:

```bash
# Backup existing config
mv ~/.emacs.d ~/.emacs.d.bak

# Symlink or copy
mkdir -p ~/.emacs.d
cp init.el custom.el emacs-cheatsheet.pdf .gitignore ~/.emacs.d/
```
