;;; init.el --- A modern Emacs config for Rust/Go/C/Zig dev -*- lexical-binding: t; -*-

;; =============================================================================
;; 1. BOOTSTRAP PACKAGE MANAGEMENT
;; =============================================================================
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile (require 'use-package))
(setq use-package-always-ensure t)

;; =============================================================================
;; 2. UI & THEME
;; =============================================================================
(setq-default indent-tabs-mode nil tab-width 4)

;; Only disable GUI elements if Emacs is running in a graphical session
(when (display-graphic-p)
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1))

(xterm-mouse-mode 1)
(global-display-line-numbers-mode 1)

(use-package doom-themes
  :init (load-theme 'doom-gruvbox t)) ; Corrected theme name

(use-package doom-modeline
  :init (doom-modeline-mode 1))

(use-package all-the-icons) ; For icons in the modeline and treemacs

(use-package projectile
  :init (projectile-mode +1))

(use-package treemacs
  :after (projectile)
  :config
  (treemacs-follow-mode 1)
  (treemacs-project-follow-mode 1))

(use-package treemacs-projectile
  :after (treemacs projectile)
  :bind
  ("C-c t" . treemacs-projectile))

;; =============================================================================
;; 3. FUZZY FINDER & COMPLETION
;; =============================================================================
(use-package vertico
  :init (vertico-mode))

(use-package consult) ; Provides powerful search commands

(use-package marginalia
  :after vertico
  :init (marginalia-mode))

(use-package company
  :hook (prog-mode . company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.0))

;; =============================================================================
;; 4. LANGUAGE SUPPORT (LSP)
;; =============================================================================
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((go-mode . lsp-deferred)
         (rustic-mode . lsp-deferred)
         (c-mode . lsp-deferred)
         (c++-mode . lsp-deferred)
         (zig-mode . lsp-deferred))
  :config
  (setq lsp-prefer-flymake nil))

;; C/C++ Support
(use-package cc-mode
  :ensure nil) ; Built-in

;; Zig Support
(use-package zig-mode
  :mode "\\.zig\\'")

;; Rust Support
(use-package rustic
  :mode "\\.rs\\'")

;; Go Support
(use-package go-mode
  :mode "\\.go\\'")

;; =============================================================================
;; 5. OTHER GOODIES
;; =============================================================================
(use-package magit
  :defer t)

(use-package which-key
  :init (which-key-mode))

(use-package undo-tree
  :init (global-undo-tree-mode))

;; In Section 2, after (global-display-line-numbers-mode 1)
(global-set-key (kbd "C-c SPC") 'set-mark-command)

(electric-pair-mode 1)

;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
