;;; init.el --- Complete, Old-School Setup for C, Go, and Zig

;; -----------------------------------------------------------------------------
;; 1. PACKAGE SYSTEM SETUP
;; -----------------------------------------------------------------------------
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Auto-refresh MELPA index if any theme package is not yet installed
(unless (and (package-installed-p 'gruvbox-theme)
             (package-installed-p 'solarized-theme)
             (package-installed-p 'doom-themes))
  (ignore-errors (package-refresh-contents)))

(require 'use-package)
(setq use-package-always-ensure t)

;; -----------------------------------------------------------------------------
;; 2. THEME PACKAGES (All installed & registered for UI selection)
;; -----------------------------------------------------------------------------
;; Select any theme interactively with `M-x load-theme` or `M-x customize-themes`.

(use-package gruvbox-theme)    ; Provides 'gruvbox-light-medium, 'gruvbox-light-soft, 'gruvbox-dark-medium, etc.
(use-package solarized-theme)  ; Provides 'solarized-light, 'solarized-dark, 'solarized-gruvbox-light, etc.
(use-package doom-themes)       ; Provides 'doom-gruvbox-light, 'doom-solarized-light, 'doom-one-light, etc.
(use-package naysayer-theme)   ; Provides 'naysayer

;; Default starting theme (change or pick from UI with M-x load-theme)
(load-theme 'naysayer t)

;; Optional: Retro block cursor without blinking
(setq-default cursor-type 'box)
(blink-cursor-mode 0)

;; Set font size (130 = 13pt; increase to 140 or 150 for larger text)
(set-face-attribute 'default nil :height 140)

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
(setq display-line-numbers-type t)         ; Absolute line numbers
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
;; Ensure Emacs finds gopls, zls, zig, and go binaries when started from GUI
(add-to-list 'exec-path "/home/calin/go/bin")
(add-to-list 'exec-path "/usr/local/go/bin")
(add-to-list 'exec-path "/home/calin/.local/share/nvim/mason/bin")
(add-to-list 'exec-path "/home/calin/zig")
(setenv "PATH" (concat "/home/calin/.local/share/nvim/mason/bin:/home/calin/zig:/home/calin/go/bin:/usr/local/go/bin:" (getenv "PATH")))
(setenv "GOPATH" "/home/calin/go")

(use-package go-mode
  :mode "\\.go\\'")

(use-package eglot
  :hook ((c-mode    . eglot-ensure)
         (c++-mode  . eglot-ensure)
         (go-mode   . eglot-ensure)
         (zig-mode  . eglot-ensure))
  :bind (:map eglot-mode-map
              ("M-."   . xref-find-definitions)   ; Go to definition
              ("M-?"   . xref-find-references)    ; Find references
              ("C-c r" . eglot-rename)             ; Rename symbol
              ("C-c a" . eglot-code-actions)       ; Code actions / quickfix
              ("C-c h" . eldoc)))                  ; Hover documentation

;; Auto-format Go files before saving
(add-hook 'before-save-hook
          (lambda ()
            (when (eq major-mode 'go-mode)
              (ignore-errors (eglot-format-buffer)))))

(use-package zig-mode)

;; -----------------------------------------------------------------------------
;; 7. GIT INTEGRATION (MAGIT)
;; -----------------------------------------------------------------------------
(use-package magit
  :bind ("C-x g" . magit-status))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(solarized-light))
 '(custom-safe-themes
   '("2b0fcc7cc9be4c09ec5c75405260a85e41691abb1ee28d29fcd5521e4fca575b" "67256d7183dc290d2e7b5ab13137774f8d4547a0040986a3a13edb6a208538fa" "09276f492e8e604d9a0821ef82f27ce58b831f90f49f986b4d93a006c12dbcdb" default))
 '(package-selected-packages
   '(treemacs naysayer-theme zig-mode which-key vertico orderless marginalia magit go-mode general evil-collection corfu consult)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
