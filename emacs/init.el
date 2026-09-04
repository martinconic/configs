;; -*- lexical-binding: t; -*-
;;; init.el --- Comprehensive, Educational Config for C, Go, and Zig (GNU Emacs 31)

;; =============================================================================
;; WELCOME TO YOUR EMACS CONFIGURATION!
;; =============================================================================
;; This file is organized into clear, logical sections. Each setting includes
;; explanations of WHAT it does, WHY it was chosen (including inspirations from
;; Aleksey Kladov / Matklad and Alexey Kutepov / Tsoding), and HOW to use it.

;; -----------------------------------------------------------------------------
;; WARNING & COMPILATION POPUP SUPPRESSION
;; -----------------------------------------------------------------------------
;; Emacs 31 introduces strict checks and native background compilation via GCCJIT.
;; By default, non-critical notices (like third-party themes missing lexical cookies
;; or background byte-to-native .eln compilation) open pop-up windows over your
;; workspace. We suppress them here so your workflow remains distraction-free:
(setq warning-suppress-types '((files missing-lexbind-cookie)
                               (native-compiler))
      warning-suppress-log-types '((files missing-lexbind-cookie)
                                   (native-compiler))
      native-comp-async-report-warnings-errors 'silent
      warning-minimum-level :error)

;; =============================================================================
;; 1. PACKAGE SYSTEM SETUP (ELPA & MELPA)
;; =============================================================================
;; Emacs has a built-in package manager called 'package.el'. By default, it only
;; connects to GNU ELPA. We add MELPA (Milkypostman's ELPA), which hosts thousands
;; of modern community packages.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; If this is a fresh setup and theme packages are missing, download the MELPA
;; index automatically so 'use-package' can fetch them without manual intervention.
(unless (and (package-installed-p 'gruvbox-theme)
             (package-installed-p 'solarized-theme)
             (package-installed-p 'doom-themes))
  (ignore-errors (package-refresh-contents)))

;; 'use-package' simplifies package configuration declarations.
;; In Emacs 30+, it is built directly into core.
;; ':ensure t' ensures any declared package is installed if not already present.
(require 'use-package)
(setq use-package-always-ensure t)

;; =============================================================================
;; 2. THEMES & VISUAL STYLING
;; =============================================================================
;; We install several hand-picked developer themes:
;; - 'naysayer': Jonathan Blow's retro dark theme with distinct green/yellow accents.
;; - 'gruber-darker': Tsoding's iconic high-contrast dark theme.
;; - 'gruvbox-theme': Warm retro groove color scheme (both dark and light variants).
;; - 'solarized-theme': Scientifically calibrated contrast theme (dark and light).
;; - 'doom-themes': Extensive suite including 'doom-one-light', 'doom-solarized-light', etc.
;;
;; TIP: To switch themes interactively at any time:
;; Press `M-x load-theme RET`, type the theme name, and press RET.

(use-package gruvbox-theme)
(use-package solarized-theme)
(use-package doom-themes)
(use-package naysayer-theme)
(use-package gruber-darker-theme)

;; Active theme on startup
(load-theme 'naysayer t)

;; Cursor style: solid, non-blinking retro block cursor for precision editing
(setq-default cursor-type 'box)
(blink-cursor-mode 0)

;; Base Font Size:
;; 140 = 14pt (adjust up to 150 for larger text or down to 130 for more density)
(set-face-attribute 'default nil :height 140)

;; =============================================================================
;; 3. CORE EDITOR DEFAULTS & HYGIENE
;; =============================================================================

(setq-default
 ;; Indentation: default to spaces instead of tabs (Go overrides this to real tabs)
 indent-tabs-mode nil
 tab-width 4
 c-basic-offset 4            ; Indent C/C++ by 4 spaces (classic c-mode)
 c-ts-mode-indent-offset 4   ; Indent C/C++ by 4 spaces (modern c-ts-mode)
 truncate-lines t)           ; Do not wrap long lines onto the next visual line

(setq
 ;; Startup speed: skip the introductory GNU splash screen and empty the scratch buffer
 inhibit-startup-screen t
 initial-scratch-message nil

 ;; Silence audio/visual bell on errors
 ring-bell-function 'ignore

 ;; System Clipboard: allow copying/pasting seamlessly between Emacs and system apps
 select-enable-clipboard t

 ;; Smooth Scrolling: keep cursor visible with 8 lines of context instead of jumping half-screens
 scroll-conservatively 101
 scroll-margin 8

 ;; File Hygiene (Matklad & Tsoding):
 ;; - Disabling lockfiles prevents annoying '.#filename' symlinks in git status.
 ;; - Disabling backup files stops 'filename~' duplicates from cluttering directories.
 create-lockfiles nil
 make-backup-files nil

 ;; Smart Tab: pressing TAB indents the line, or completes code if already indented
 tab-always-indent 'complete)

;; -----------------------------------------------------------------------------
;; Tree-sitter in Emacs 31:
;; -----------------------------------------------------------------------------
;; Emacs 31 has built-in Tree-sitter parsing for AST-level syntax highlighting.
;; 'treesit-auto-install-grammar 'always' automatically downloads and compiles
;; grammar shared libraries (*.so) into '~/.emacs.d/tree-sitter/' when needed.
(setq treesit-auto-install-grammar 'always
      treesit-enabled-modes t)

;; Pinned grammar sources compatible with Ubuntu's ABI 13-14 libtree-sitter:
(setq treesit-language-source-alist
      '((c      . ("https://github.com/tree-sitter/tree-sitter-c" "v0.21.4"))
        (cpp    . ("https://github.com/tree-sitter/tree-sitter-cpp" "v0.22.0"))
        (go     . ("https://github.com/tree-sitter/tree-sitter-go" "v0.20.0"))
        (gomod  . ("https://github.com/camdencheek/tree-sitter-go-mod"))
        (zig    . ("https://github.com/tree-sitter-grammars/tree-sitter-zig" "v1.0.2"))
        (rust   . ("https://github.com/tree-sitter/tree-sitter-rust" "v0.21.2"))
        (json   . ("https://github.com/tree-sitter/tree-sitter-json"))
        (yaml   . ("https://github.com/ikatyang/tree-sitter-yaml"))))

;; Explicit remaps so Tree-sitter modes (*-ts-mode) are always preferred:
(add-to-list 'major-mode-remap-alist '(go-mode . go-ts-mode))
(add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode))
(add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))

;; -----------------------------------------------------------------------------
;; Performance Tuning for Large Codebases (Swarm Bee, TigerBeetle):
;; -----------------------------------------------------------------------------
;; 1. gc-cons-threshold: Increase GC trigger from 800KB to 100MB so file loading
;;    and LSP parsing don't constantly freeze the editor with garbage collection.
;; 2. read-process-output-max: Increase sub-process pipe reads from 4KB to 1MB.
;;    This is essential for high-throughput JSON-RPC servers like 'gopls' and 'zls'.
;; 3. vc-handled-backends: Limit version control tracking to Git only. Prevents
;;    Emacs from probing for 7 dead VCS types (Bazaar, CVS, RCS, SCCS, SVN, etc.).
(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      vc-handled-backends '(Git))

;; -----------------------------------------------------------------------------
;; Navigation & UI Essentials:
;; -----------------------------------------------------------------------------
(global-auto-revert-mode 1)       ; Reload file if changed externally (e.g., git pull)
(setq dired-dwim-target t)         ; In 2-pane Dired, automatically suggest the other pane for copy/rename
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type t) ; Show line numbers on the left margin
(show-paren-mode 1)                ; Highlight matching () {} [] pairs
(electric-pair-mode 1)             ; Auto-close quotes and brackets while typing
(save-place-mode 1)                ; Remember cursor line when reopening files
(recentf-mode 1)                   ; Track recently opened files
(which-key-mode 1)                 ; Show available keyboard completions in a bottom popup
(windmove-default-keybindings)     ; Navigate between split windows with Shift + Arrow keys
(add-hook 'prog-mode-hook #'hs-minor-mode) ; Enable code folding across all programming modes

;; =============================================================================
;; 4. COMPILATION BUFFER ERGONOMICS (Matklad)
;; =============================================================================
;; Enhancements for `M-x compile`:
;; - Disables annoying save prompts before every compile.
;; - Prevents cursor from auto-jumping away to the first error line before you read the log.
;; - Parses ANSI escape codes so colored terminal output (green/red) renders properly.
(use-package compile
  :custom
  (compilation-scroll-output nil)
  (compilation-ask-about-save nil)
  (compilation-auto-jump-to-first-error nil)
  :hook (compilation-filter . ansi-color-compilation-filter))

;; =============================================================================
;; 5. TEXT MANIPULATION & EDITING SHORTCUTS (Tsoding & Matklad)
;; =============================================================================

;; Move lines or active selections up and down:
;; - M-p (Alt + p): slide line/block UP
;; - M-n (Alt + n): slide line/block DOWN
(use-package move-text
  :bind (("M-p" . move-text-up)
         ("M-n" . move-text-down)))

;; Duplicate line downward (Ctrl + ,) without modifying your clipboard (Tsoding):
(defun rc/duplicate-line ()
  "Duplicate current line and keep cursor column."
  (interactive)
  (let ((column (- (point) (point-at-bol)))
        (line (let ((s (thing-at-point 'line t)))
                (if s (string-remove-suffix "\n" s) ""))))
    (move-end-of-line 1)
    (newline)
    (insert line)
    (move-beginning-of-line 1)
    (forward-char column)))
(global-set-key (kbd "C-,") #'rc/duplicate-line)

;; Smart Cut & Copy (Matklad):
;; - C-w: cuts region if selected; cuts the ENTIRE LINE if nothing is selected.
;; - M-w: copies region if selected; copies the ENTIRE LINE if nothing is selected.
(defun kill-region-smart ()
  "Cut active region, or current line if no selection."
  (interactive)
  (if (use-region-p)
      (call-interactively #'kill-region)
    (kill-whole-line)))

(defun kill-ring-save-smart ()
  "Copy active region, or current line if no selection."
  (interactive)
  (if (use-region-p)
      (call-interactively #'kill-ring-save)
    (save-excursion
      (beginning-of-line)
      (copy-region-as-kill (line-beginning-position) (line-beginning-position 2)))))

(global-set-key (kbd "C-w") #'kill-region-smart)
(global-set-key (kbd "M-w") #'kill-ring-save-smart)

;; Expand Selection (C-=):
;; Progressively selects word -> string -> argument -> expression -> function block.
(use-package expand-region
  :bind ("C-=" . er/expand-region))

;; =============================================================================
;; 6. PROJECT FILE EXPLORER (TREEMACS)
;; =============================================================================
;; Visual sidebar tree for your projects and files.
;; - C-c t t : Toggle tree sidebar on/off
;; - C-c t f : Locate and highlight the current file in the tree
(use-package treemacs
  :bind
  (("C-c t t" . treemacs)
   ("C-c t f" . treemacs-find-file)
   ("C-c t p" . treemacs-add-project-to-workspace))
  :custom
  (treemacs-width 30)
  (treemacs-position 'left)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t))

;; =============================================================================
;; 7. SEARCH & COMPLETION FRAMEWORK (VERTICO + CONSULT)
;; =============================================================================
;; Minimalist, blazingly fast alternative to heavy frameworks like Ivy or Helm.

;; Vertico: vertical interactive completion in the minibuffer
(use-package vertico
  :init
  (vertico-mode 1))

;; Orderless: type search terms out-of-order separated by spaces (e.g. "buff zig" matches "buffered_writer.zig")
(use-package orderless
  :custom
  (completion-styles '(orderless basic)))

;; Marginalia: shows rich annotations (file permissions, function docs) beside search candidates
(use-package marginalia
  :init
  (marginalia-mode 1))

;; Corfu: lightweight, non-intrusive auto-completion popup right at your cursor
(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 2)
  :init
  (global-corfu-mode 1))

;; Consult: fast interactive search commands:
;; - C-s     : search lines in current file with live preview
;; - C-x b   : search buffers and recent files
;; - M-g i   : search functions/types in current file
;; - C-c f g : project-wide ripgrep
(use-package consult
  :bind
  (("C-s"     . consult-line)
   ("C-x b"   . consult-buffer)
   ("M-g i"   . consult-imenu)
   ("M-g I"   . consult-imenu-multi)
   ("C-c f g" . consult-ripgrep)))

;; Better Jumper (Matklad):
;; Remembers your navigation history across definition jumps:
;; - M-[ : jump BACKWARD to previous location
;; - M-] : jump FORWARD
(use-package better-jumper
  :bind
  (("M-[" . better-jumper-jump-backward)
   ("M-]" . better-jumper-jump-forward))
  :config
  (better-jumper-mode 1)
  (with-eval-after-load 'xref
    (advice-add #'xref-push-marker-stack :override #'better-jumper-set-jump)))

;; =============================================================================
;; 8. LANGUAGE SERVER PROTOCOL (EGLOT) & CODE INTELLIGENCE
;; =============================================================================
;; Eglot is Emacs's built-in LSP client. It is lightweight, reliable, and uses
;; standard Emacs features (xref, flymake, eldoc).

;; Ensure GUI Emacs can find compiler and LSP tool binaries on your system:
(add-to-list 'exec-path "/home/calin/go/bin")
(add-to-list 'exec-path "/usr/local/go/bin")
(add-to-list 'exec-path "/home/calin/.local/share/nvim/mason/bin")
(add-to-list 'exec-path "/home/calin/zig")
(add-to-list 'exec-path "/home/calin/bin")
(setenv "PATH" (concat "/home/calin/bin:/home/calin/.local/share/nvim/mason/bin:/home/calin/zig:/home/calin/go/bin:/usr/local/go/bin:" (getenv "PATH")))
(setenv "GOPATH" "/home/calin/go")

;; Go: Enforce standard Go tabs (indent-tabs-mode t)
(add-hook 'go-ts-mode-hook (lambda () (setq-local indent-tabs-mode t)))
(add-hook 'go-mode-hook    (lambda () (setq-local indent-tabs-mode t)))

(use-package eglot
  ;; Automatically start LSP when visiting C, Go, or Zig files
  :hook ((c-mode       . eglot-ensure)
         (c-ts-mode    . eglot-ensure)
         (c++-mode     . eglot-ensure)
         (c++-ts-mode  . eglot-ensure)
         (go-mode      . eglot-ensure)
         (go-ts-mode   . eglot-ensure)
         (zig-ts-mode  . eglot-ensure))
  :bind (:map eglot-mode-map
              ("M-."   . xref-find-definitions)   ; Jump to definition
              ("M-?"   . xref-find-references)    ; Find all references across project
              ("C-c r" . eglot-rename)             ; Rename symbol project-wide
              ("C-c a" . eglot-code-actions)       ; Quickfixes and code actions
              ("C-c h" . eldoc)                    ; View hover documentation
              ("C-p"   . eglot-format-buffer))     ; Format current buffer (Matklad)
  :custom
  ;; Non-blocking LSP: connect asynchronously so opening large files is instant
  (eglot-sync-connect 0)
  ;; Disable 2MB JSON-RPC event buffer to prevent background memory bloat
  (eglot-events-buffer-size 0)
  :config
  ;; Disabling inlay hints prevents typing lag in large C/Go/Zig codebases (Matklad)
  (add-to-list 'eglot-ignored-server-capabilities :inlayHintProvider)

  ;; ---------------------------------------------------------------------------
  ;; Smart Project-Aware Zig Language Server (ZLS):
  ;; ---------------------------------------------------------------------------
  ;; - If inside TigerBeetle (contains ./zig/zig), use ZLS 0.14 with Zig 0.14.1
  ;; - For all other Zig projects, use ZLS 0.16 with global Zig 0.16.0
  (defun my-zls-contact (_interactive)
    (let* ((proj (project-current))
           (root (if proj (project-root proj) default-directory)))
      (if (file-exists-p (expand-file-name "zig/zig" root))
          (list "/home/calin/bin/zls-0.14.0"
                "--config-path" (expand-file-name "zls.json" root))
        (list "/home/calin/zig/zls"))))

  (add-to-list 'eglot-server-programs
               '((zig-mode zig-ts-mode) . my-zls-contact)))

;; Auto-format Go files before saving (gofmt)
(add-hook 'before-save-hook
          (lambda ()
            (when (derived-mode-p 'go-mode 'go-ts-mode)
              (ignore-errors (eglot-format-buffer)))))

;; =============================================================================
;; 9. ZIG TREE-SITTER & STRUCTURAL FOLDING (Matklad)
;; =============================================================================
;; Uses Emacs 31's native :vc support to fetch the latest zig-ts-mode grammar
(use-package zig-ts-mode
  :vc (:url "https://codeberg.org/meow_king/zig-ts-mode" :rev :newest)
  :mode "\\.zig\\'"
  :config
  (font-lock-add-keywords
   'zig-ts-mode
   '(("\\<assert\\>" . font-lock-function-name-face))))

;; AST-based folding for Zig:
;; Press Ctrl + Shift + F (C-S-f) to toggle folding on leaf functions and test blocks
(defun zig-ts--test-node-p (node)
  (equal (treesit-node-type node) "test_declaration"))

(defun zig-ts--function-node-p (node)
  (equal (treesit-node-type node) "function_declaration"))

(defun zig-ts--contains-function-p (node)
  (seq-some (lambda (child)
              (or (zig-ts--function-node-p child)
                  (zig-ts--contains-function-p child)))
            (treesit-node-children node)))

(defun zig-ts--leaf-function-node-p (node)
  (and (zig-ts--function-node-p node)
       (not (zig-ts--contains-function-p node))))

(defun zig-ts--leaf-functions-and-tests (node)
  (if (or (zig-ts--test-node-p node)
          (zig-ts--leaf-function-node-p node))
      (list node)
    (apply #'append
           (mapcar #'zig-ts--leaf-functions-and-tests
                   (treesit-node-children node)))))

(defun my/fold-functions ()
  "Fold leaf Zig functions and tests, or unfold everything if anything is folded."
  (interactive)
  (unless (derived-mode-p 'zig-ts-mode)
    (user-error "This command requires zig-ts-mode"))
  (save-excursion
    (let ((overlays (overlays-in (point-min) (point-max)))
          (folded nil))
      (while (and overlays (not folded))
        (when (overlay-get (car overlays) 'hs)
          (setq folded t))
        (setq overlays (cdr overlays)))
      (if folded
          (hs-show-all)
        (dolist (f (zig-ts--leaf-functions-and-tests (treesit-buffer-root-node 'zig)))
          (when-let* ((body (treesit-node-child f -1)))
            (goto-char (treesit-node-start body))
            (hs-hide-block)))))))

(keymap-global-set "C-S-f" #'my/fold-functions)

;; =============================================================================
;; 10. GIT INTEGRATION (MAGIT)
;; =============================================================================
;; The finest Git interface in any editor.
;; Press 'C-x g' to view git status, stage hunks with 's', commit with 'c c', and push with 'P p'.
(use-package magit
  :bind ("C-x g" . magit-status))

;; =============================================================================
;; 11. CUSTOM AUTOMATIC VARIABLES
;; =============================================================================
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(naysayer))
 '(custom-safe-themes
   '("01a9797244146bbae39b18ef37e6f2ca5bebded90d9fe3a2f342a9e863aaa4fd" "2b0fcc7cc9be4c09ec5c75405260a85e41691abb1ee28d29fcd5521e4fca575b" "67256d7183dc290d2e7b5ab13137774f8d4547a0040986a3a13edb6a208538fa" "09276f492e8e604d9a0821ef82f27ce58b831f90f49f986b4d93a006c12dbcdb" default))
 '(package-selected-packages
   '(treemacs naysayer-theme zig-mode which-key vertico orderless marginalia magit go-mode general evil-collection corfu consult)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
