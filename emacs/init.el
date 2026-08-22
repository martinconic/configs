;;; init.el --- Complete, Old-School Setup for C, Go, and Zig

;; -----------------------------------------------------------------------------
;; 1. PACKAGE SYSTEM SETUP
;; -----------------------------------------------------------------------------
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(require 'use-package)
(setq use-package-always-ensure t)

;; -----------------------------------------------------------------------------
;; 2. THEME (Jonathan Blow's Naysayer)
;; -----------------------------------------------------------------------------
(use-package naysayer-theme
  :config
  (load-theme 'naysayer t))

;; Optional: Retro block cursor without blinking
(setq-default cursor-type 'box)
(blink-cursor-mode 0)

;; -----------------------------------------------------------------------------
;; 3. CORE EDITOR DEFAULTS
;; -----------------------------------------------------------------------------
(setq-default
 indent-tabs-mode nil         ; Spaces for tabs (Go automatically overrides to real tabs)
 tab-width 4
 c-basic-offset 4
 truncate-lines t)           ; Do not wrap lines

(setq inhibit-startup-screen t
      initial-scratch-message nil
      ring-bell-function 'ignore
      select-enable-clipboard t    ; Sync with system clipboard
      scroll-conservatively 101    ; Smooth scroll
      scroll-margin 8)             ; Context lines around cursor

;; UI & Navigation Essentials
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative) ; Relative line numbers
(show-paren-mode 1)                        ; Highlight matching brackets
(electric-pair-mode 1)                     ; Auto-close quotes and brackets
(save-place-mode 1)                        ; Remember cursor position across restarts
(recentf-mode 1)                           ; Keep track of recent files
(which-key-mode 1)                         ; Popup hints for key combinations

;; -----------------------------------------------------------------------------
;; 4. LEFT-SIDE PROJECT NAVIGATOR (TREEMACS)
;; -----------------------------------------------------------------------------
(use-package treemacs
  :bind
  (("C-c t t" . treemacs)                    ; Toggle sidebar on/off
   ("C-c t f" . treemacs-find-file)          ; Focus current file in tree
   ("C-c t p" . treemacs-add-project-to-workspace))
  :custom
  (treemacs-width 30)
  (treemacs-position 'left)
  (treemacs-follow-mode t)                   ; Automatically highlight active file
  (treemacs-filewatch-mode t))

;; -----------------------------------------------------------------------------
;; 5. SEARCH & INTERACTIVE COMPLETION (VERTICO + CONSULT)
;; -----------------------------------------------------------------------------
(use-package vertico
  :init
  (vertico-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic)))

(use-package marginalia
  :init
  (marginalia-mode 1))

;; Fast, lightweight in-buffer completion popup for LSP
(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 2)
  :init
  (global-corfu-mode 1))

;; Fast search across buffers, files, functions, and project grep
(use-package consult
  :bind
  (("C-s"     . consult-line)                ; Fast search inside current file
   ("C-x b"   . consult-buffer)              ; Switch buffer / recent file
   ("M-g i"   . consult-imenu)               ; Search functions/methods in file
   ("M-g I"   . consult-imenu-multi)         ; Search functions across all open files
   ("C-c f g" . consult-ripgrep)))           ; Ripgrep across whole project

;; -----------------------------------------------------------------------------
;; 6. CODE INTELLIGENCE & LSP (EGLOT)
;; -----------------------------------------------------------------------------
(require 'eglot)

;; Hook built-in Eglot into your specific languages
(add-hook 'c-mode-hook #'eglot-ensure)       ; Uses clangd
(add-hook 'c++-mode-hook #'eglot-ensure)     ; Uses clangd
(add-hook 'go-mode-hook #'eglot-ensure)      ; Uses gopls
(add-hook 'zig-mode-hook #'eglot-ensure)     ; Uses zls

;; Auto-format Go files before saving
(add-hook 'before-save-hook
          (lambda ()
            (when (eq major-mode 'go-mode)
              (eglot-format-buffer))))

;; Major Modes for Go & Zig (C/C++ is built-in)
(use-package go-mode)
(use-package zig-mode)

;; -----------------------------------------------------------------------------
;; 7. GIT INTEGRATION (MAGIT)
;; -----------------------------------------------------------------------------
(use-package magit
  :bind ("C-x g" . magit-status))
