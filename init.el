;;; init.el --- Modern Emacs config mirroring the nvim setup -*- lexical-binding: t; -*-

;; =============================================================================
;; 1. BOOTSTRAP PACKAGE MANAGEMENT
;; =============================================================================
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile (require 'use-package))
(setq use-package-always-ensure t)

;; =============================================================================
;; 2. CORE EDITOR OPTIONS
;; =============================================================================
(setq-default indent-tabs-mode nil
              tab-width 4
              c-basic-offset 4)

(setq inhibit-startup-screen t
      ring-bell-function 'ignore
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      scroll-margin 8
      scroll-conservatively 101
      use-short-answers t
      sentence-end-double-space nil
      require-final-newline t)

;; Persistent undo (matches vim's undofile)
(setq undo-tree-auto-save-history t)

;; System clipboard
(setq select-enable-clipboard t
      select-enable-primary t)

;; Smart case search
(setq case-fold-search t)

(when (display-graphic-p)
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1))

(xterm-mouse-mode 1)
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
(column-number-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)
(delete-selection-mode 1)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

;; =============================================================================
;; 3. THEME & UI
;; =============================================================================
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  ;; doom-one-light is the closest match to nightfox's "dayfox"
  (load-theme 'doom-one-light t)
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-buffer-file-name-style 'relative-from-project)
  (doom-modeline-minor-modes nil))

(use-package all-the-icons
  :if (display-graphic-p))

;; Bufferline equivalent
(use-package centaur-tabs
  :demand
  :config
  (centaur-tabs-mode t)
  (setq centaur-tabs-style "bar"
        centaur-tabs-set-icons t
        centaur-tabs-set-modified-marker t
        centaur-tabs-modified-marker "●")
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>"  . centaur-tabs-forward))

;; indent-blankline equivalent
(use-package highlight-indent-guides
  :hook (prog-mode . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-responsive 'top))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; =============================================================================
;; 4. PROJECT, FILE TREE, GIT GUTTER
;; =============================================================================
(use-package projectile
  :init (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map)))

(use-package treemacs
  :defer t
  :bind ("C-c e" . treemacs)
  :config
  (treemacs-follow-mode 1)
  (treemacs-project-follow-mode 1)
  (treemacs-filewatch-mode 1)
  (treemacs-git-mode 'deferred))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package treemacs-all-the-icons
  :after treemacs
  :config (treemacs-load-theme "all-the-icons"))

;; gitsigns equivalent
(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (diff-hl-flydiff-mode 1)
  (unless (display-graphic-p)
    (diff-hl-margin-mode 1)))

;; =============================================================================
;; 5. FUZZY FINDER (Telescope equivalent)
;; =============================================================================
(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :after vertico
  :init (marginalia-mode))

(use-package consult
  :bind
  ;; Telescope-style bindings under C-c f
  (("C-c f f" . consult-find)           ; find files
   ("C-c f g" . consult-ripgrep)        ; live grep
   ("C-c f b" . consult-buffer)         ; buffers
   ("C-c f s" . consult-imenu)          ; symbols in file
   ("C-c f S" . consult-imenu-multi)    ; symbols in project
   ("C-c f l" . consult-line)           ; search lines
   ("C-c d"   . consult-flymake)        ; diagnostics
   ("M-y"     . consult-yank-pop)))

(use-package embark
  :bind (("C-."   . embark-act)
         ("C-;"   . embark-dwim)
         ("C-h B" . embark-bindings)))

(use-package embark-consult
  :after (embark consult))

;; =============================================================================
;; 6. AUTOCOMPLETION
;; =============================================================================
(use-package company
  :hook (prog-mode . company-mode)
  :config
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.0
        company-selection-wrap-around t)
  :bind (:map company-active-map
              ("TAB" . company-complete-selection)
              ("<tab>" . company-complete-selection)
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous)))

(use-package company-box
  :if (display-graphic-p)
  :hook (company-mode . company-box-mode))

;; =============================================================================
;; 7. SYNTAX & TREE-SITTER
;; =============================================================================
;; Emacs 29+ ships built-in tree-sitter (treesit). Configure grammars for
;; the same languages the nvim config installs.
(when (and (fboundp 'treesit-available-p) (treesit-available-p))
  (setq treesit-language-source-alist
        '((c        "https://github.com/tree-sitter/tree-sitter-c")
          (cpp      "https://github.com/tree-sitter/tree-sitter-cpp")
          (rust     "https://github.com/tree-sitter/tree-sitter-rust")
          (go       "https://github.com/tree-sitter/tree-sitter-go")
          (gomod    "https://github.com/camdencheek/tree-sitter-go-mod")
          (toml     "https://github.com/tree-sitter/tree-sitter-toml")
          (lua      "https://github.com/MunifTanjim/tree-sitter-lua")
          (zig      "https://github.com/maxxnino/tree-sitter-zig")))
  ;; Prefer ts-modes when grammar is installed
  (dolist (mapping '((c-mode        . c-ts-mode)
                     (c++-mode      . c++-ts-mode)
                     (rust-mode     . rust-ts-mode)
                     (go-mode       . go-ts-mode)
                     (toml-mode     . toml-ts-mode)))
    (add-to-list 'major-mode-remap-alist mapping)))

;; =============================================================================
;; 8. LSP
;; =============================================================================
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((c-mode         . lsp-deferred)
         (c-ts-mode      . lsp-deferred)
         (c++-mode       . lsp-deferred)
         (c++-ts-mode    . lsp-deferred)
         (rustic-mode    . lsp-deferred)
         (rust-ts-mode   . lsp-deferred)
         (go-mode        . lsp-deferred)
         (go-ts-mode     . lsp-deferred)
         (zig-mode       . lsp-deferred)
         (odin-mode      . lsp-deferred)
         (lua-mode       . lsp-deferred)
         (lsp-mode       . lsp-enable-which-key-integration))
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (setq lsp-prefer-flymake nil
        lsp-headerline-breadcrumb-enable t
        lsp-eldoc-render-all nil
        lsp-idle-delay 0.3
        lsp-completion-provider :capf))

(use-package lsp-ui
  :after lsp-mode
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline-show-code-actions t))

(use-package lsp-treemacs
  :after (lsp-mode treemacs))

(use-package flycheck
  :init (global-flycheck-mode))

;; =============================================================================
;; 9. LANGUAGE MODES
;; =============================================================================
(use-package cc-mode :ensure nil) ; built-in (C/C++)

(use-package rustic
  :mode "\\.rs\\'"
  :config (setq rustic-lsp-client 'lsp-mode))

(use-package go-mode
  :mode "\\.go\\'"
  :hook (before-save . gofmt-before-save))

(use-package zig-mode
  :mode "\\.zig\\'")

(use-package odin-mode
  :mode "\\.odin\\'")

(use-package lua-mode
  :mode "\\.lua\\'")

(use-package toml-mode
  :mode "\\.toml\\'")

;; crates.nvim equivalent (Cargo.toml dependency versions)
(use-package cargo
  :hook (rust-mode . cargo-minor-mode))

;; =============================================================================
;; 10. GIT (Neogit equivalent)
;; =============================================================================
(use-package magit
  :bind (("C-c g g" . magit-status)
         ("C-c g b" . magit-blame)
         ("C-c g c" . magit-log-current)
         ("C-c g B" . magit-branch)))

;; =============================================================================
;; 11. UTILITIES
;; =============================================================================
(use-package which-key
  :init (which-key-mode)
  :config (setq which-key-idle-delay 0.3))

(use-package undo-tree
  :init (global-undo-tree-mode)
  :custom
  (undo-tree-history-directory-alist
   `(("." . ,(expand-file-name "undo-tree-history" user-emacs-directory)))))

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
