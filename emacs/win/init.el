;; -*- lexical-binding: t; -*-
;;; init.el --- Comprehensive, Educational Config for Windows (C, Go, Zig - GNU Emacs 31)

;; =============================================================================
;; WELCOME TO YOUR WINDOWS EMACS CONFIGURATION!
;; =============================================================================
;; Optimized for Windows 10/11 with NTFS filesystem safety, ClearType typography,
;; and sub-second compilation feedback loops inspired by Casey Muratori,
;; Jonathan Blow, Alexey Kutepov (Tsoding), and Aleksey Kladov (Matklad).

;; -----------------------------------------------------------------------------
;; WARNING & COMPILATION POPUP SUPPRESSION
;; -----------------------------------------------------------------------------
(setq warning-suppress-types '((files missing-lexbind-cookie)
                               (native-compiler))
      warning-suppress-log-types '((files missing-lexbind-cookie)
                                   (native-compiler))
      native-comp-async-report-warnings-errors 'silent
      warning-minimum-level :error)

;; Maximize GC threshold during startup for fast loading, restore after init:
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 100 1024 1024))))

;; =============================================================================
;; 1. PACKAGE SYSTEM SETUP (ELPA & MELPA)
;; =============================================================================
(require 'package)
(setq package-archives
      '(("gnu"          . "https://elpa.gnu.org/packages/")
        ("nongnu"       . "https://elpa.nongnu.org/nongnu/")
        ("melpa"        . "https://melpa.org/packages/")))
(package-initialize)

(unless (and (package-installed-p 'gruvbox-theme)
             (package-installed-p 'solarized-theme)
             (package-installed-p 'doom-themes))
  (ignore-errors (package-refresh-contents)))

(require 'use-package)
(setq use-package-always-ensure t)

;; =============================================================================
;; 2. WINDOWS PATHS & TOOLING INTEGRATION
;; =============================================================================
;; Automatically detect standard Windows installation directories for LLVM/Clang,
;; Go, and Zig if they exist:
(dolist (path '("C:/Program Files/LLVM/bin"
                "C:/Program Files/Go/bin"
                "C:/Go/bin"
                "C:/zig"
                "C:/tools/bin"))
  (when (file-directory-p path)
    (add-to-list 'exec-path path)
    (setenv "PATH" (concat path ";" (getenv "PATH")))))

;; =============================================================================
;; 3. THEMES & WINDOWS VISUAL STYLING
;; =============================================================================
(use-package gruvbox-theme)
(use-package solarized-theme)
(use-package doom-themes)
(use-package naysayer-theme)
(use-package gruber-darker-theme)

;; Active theme on startup
(load-theme 'solarized-light t)

;; Cursor style: solid, non-blinking retro block cursor
(setq-default cursor-type 'box)
(blink-cursor-mode 0)

;; Windows Typography: Consolas with ClearType renders crisp and readable
(when (member "Consolas" (font-family-list))
  (set-face-attribute 'default nil :family "Consolas" :height 120))

;; =============================================================================
;; 4. CORE EDITOR DEFAULTS, HYGIENE & WINDOWS OPTIMIZATIONS
;; =============================================================================
(setq-default
 indent-tabs-mode nil         ; Spaces for tabs (Go overrides to real tabs)
 tab-width 4
 c-basic-offset 4            ; Classic C 4-space
 c-ts-mode-indent-offset 4   ; Tree-sitter C 4-space
 c-ts-mode-indent-style 'k&r ; Standard K&R C indentation (clean 4 spaces)
 truncate-lines t)

(setq c-default-style "k&r")

(setq
 inhibit-startup-screen t
 initial-scratch-message nil
 ring-bell-function 'ignore
 select-enable-clipboard t
 scroll-conservatively 101
 scroll-margin 8

 ;; Windows NTFS File Hygiene:
 ;; - Disabling lockfiles prevents NTFS symlink permission crashes on Windows.
 ;; - Disabling backup files stops 'filename~' duplicates from cluttering dirs.
 create-lockfiles nil
 make-backup-files nil

 ;; Smart Tab: TAB indents, or completes if already indented
 tab-always-indent 'complete)

;; Windows Subprocess Pipe Throughput & Low Latency:
;; Critical for high-speed LSP (clangd.exe, gopls.exe, zls.exe) on Windows
(setq read-process-output-max (* 1024 1024)
      w32-pipe-read-delay 0
      vc-handled-backends '(Git)
      project-vc-extra-root-markers '(".project" "Makefile" "build.bat"))

;; Navigation & UI Essentials
(global-auto-revert-mode 1)
(setq dired-dwim-target t)
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type t)
(show-paren-mode 1)
(electric-pair-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(which-key-mode 1)
(windmove-default-keybindings)
(add-hook 'prog-mode-hook #'hs-minor-mode)

;; Systems Code Hygiene:
;; - 80-column vertical ruler for clean side-by-side editing in split windows
;; - Automatically strip trailing whitespace before saving
(setq-default fill-column 80)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)
(add-hook 'before-save-hook #'delete-trailing-whitespace)

;; =============================================================================
;; 5. COMPILATION BUFFER ERGONOMICS (Casey Muratori & Matklad)
;; =============================================================================
;; Windows build.bat / nmake / MSVC cl.exe optimization:
(use-package compile
  :custom
  (compilation-scroll-output nil)
  (compilation-ask-about-save nil)
  (compilation-auto-jump-to-first-error nil)
  :hook (compilation-filter . ansi-color-compilation-filter))

;; Instant rebuild shortcuts:
;; - F5 or C-c C-c : re-run previous compile command (build.bat / make) immediately
;; - C-c c         : invoke new compile command
(global-set-key (kbd "<f5>") #'recompile)
(global-set-key (kbd "C-c c") #'compile)
(global-set-key (kbd "C-c C-c") #'recompile)

;; Visual 6-Pane GDB Debugger (M-x gdb):
(setq gdb-many-windows t
      gdb-show-main t)

;; Quick POSIX / C Library Manuals (C-c m):
(global-set-key (kbd "C-c m") (if (executable-find "man") #'man #'woman))

;; =============================================================================
;; 6. TEXT MANIPULATION & EDITING SHORTCUTS (Tsoding & Matklad)
;; =============================================================================
(use-package move-text
  :bind (("M-p" . move-text-up)
         ("M-n" . move-text-down)))

(defun rc/duplicate-line ()
  "Duplicate current line and keep cursor column."
  (interactive)
  (let ((column (- (point) (pos-bol)))
        (line (let ((s (thing-at-point 'line t)))
                (if s (string-remove-suffix "\n" s) ""))))
    (move-end-of-line 1)
    (newline)
    (insert line)
    (move-beginning-of-line 1)
    (forward-char column)))
(global-set-key (kbd "C-,") #'rc/duplicate-line)

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

(use-package expand-region
  :bind ("C-=" . er/expand-region))

;; Universal Format Buffer (C-p):
;; In C/C++, use standard Emacs 4-space K&R indentation. In Go/Zig, use LSP (gopls/zls).
(defun rc/format-buffer ()
  "Format entire buffer: in C/C++ use standard Emacs indentation, otherwise use LSP if active."
  (interactive)
  (if (and (bound-and-true-p eglot--managed-mode)
           (fboundp 'eglot-format-buffer)
           (not (derived-mode-p 'c-mode 'c-ts-mode 'c++-mode 'c++-ts-mode))
           (eglot-server-capable :documentFormattingProvider))
      (eglot-format-buffer)
    (save-excursion
      (indent-region (point-min) (point-max))
      (message "Buffer formatted (standard 4-space K&R)"))))

(keymap-set prog-mode-map "C-p" #'rc/format-buffer)

;; Fast Header <-> Source file flip (C-c o):
(keymap-set prog-mode-map "C-c o" #'ff-find-other-file)

;; C/C++ Macro Preprocessor Expansion (C-c C-e):
(with-eval-after-load 'c-ts-mode
  (when (boundp 'c-ts-base-mode-map)
    (keymap-set c-ts-base-mode-map "C-c C-e" #'c-macro-expand)))
(with-eval-after-load 'cc-mode
  (when (boundp 'c-mode-base-map)
    (keymap-set c-mode-base-map "C-c C-e" #'c-macro-expand)))

;; =============================================================================
;; 7. PROJECT FILE EXPLORER (TREEMACS)
;; =============================================================================
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
;; 8. SEARCH & INTERACTIVE COMPLETION (VERTICO + CONSULT)
;; =============================================================================
(use-package vertico
  :init
  (vertico-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic)))

(use-package marginalia
  :init
  (marginalia-mode 1))

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 2)
  :init
  (global-corfu-mode 1))

(use-package consult
  :bind
  (("C-s"             . consult-line)
   ("C-x b"           . consult-buffer)
   ("M-g i"           . consult-imenu)
   ("M-g I"           . consult-imenu-multi)
   ("M-s r"           . consult-ripgrep)
   ("C-c f g"         . consult-ripgrep)))

;; Standard Jump Navigation (Built-in Xref):
;; - M-. : jump to definition (xref-find-definitions)
;; - M-, : jump back to previous location (xref-go-back)
;; - M-? : find all references across the project (xref-find-references)

;; Terminal Focus Event Safety:
(unless (display-graphic-p)
  (define-key input-decode-map "\e[I" [focus-in])
  (define-key input-decode-map "\e[O" [focus-out]))

;; =============================================================================
;; 9. LANGUAGE SERVER PROTOCOL (EGLOT) & CODE INTELLIGENCE
;; =============================================================================
(use-package eglot
  :hook ((c-mode       . eglot-ensure)
         (c-ts-mode    . eglot-ensure)
         (c++-mode     . eglot-ensure)
         (c++-ts-mode  . eglot-ensure)
         (go-mode      . eglot-ensure)
         (go-ts-mode   . eglot-ensure)
         (zig-mode     . eglot-ensure)
         (zig-ts-mode  . eglot-ensure))
  :bind (:map eglot-mode-map
              ("M-."   . xref-find-definitions)
              ("M-,"   . xref-go-back)
              ("M-?"   . xref-find-references)
              ("C-c r" . eglot-rename)
              ("C-c a" . eglot-code-actions)
              ("C-c h" . eldoc)
              ("C-p"   . rc/format-buffer))
  :custom
  (eglot-sync-connect 0)
  (eglot-events-buffer-size 0)
  :config
  (add-to-list 'eglot-ignored-server-capabilities :inlayHintProvider)
  ;; Disable on-type formatting so clangd won't reformat or move braces while typing
  (add-to-list 'eglot-ignored-server-capabilities :documentOnTypeFormattingProvider))

(add-hook 'before-save-hook
          (lambda ()
            (when (derived-mode-p 'go-mode 'go-ts-mode)
              (ignore-errors (eglot-format-buffer)))))

(use-package go-mode)
(use-package zig-mode)

;; =============================================================================
;; 10. GIT INTEGRATION (MAGIT)
;; =============================================================================
(use-package magit
  :bind ("C-x g" . magit-status))

;; =============================================================================
;; 11. CUSTOM AUTOMATIC VARIABLES ISOLATION
;; =============================================================================
(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file t))

;;; init.el ends here