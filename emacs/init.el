;;; Bootstrap
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package use-package
  :config
  (require 'use-package-ensure)
  (setq use-package-always-ensure t))

;;; Appearance
(use-package nord-theme
  :config
  (load-theme 'nord t)
  (set-face-attribute 'default nil :font "JetBrains Mono" :height 200)
  (set-face-attribute 'fringe  nil :background nil)
  (set-frame-parameter nil 'internal-border-width 10)
  (setq-default header-line-format " ")
  (set-face-attribute 'header-line  nil :inherit nil :background nil :height 0.3))

(use-package telephone-line
  :config
  (setq
   telephone-line-primary-left-separator 'telephone-line-identity-right
   telephone-line-secondary-left-separator 'telephone-line-identity-hollow-right
   telephone-line-primary-right-separator 'telephone-line-identity-left
   telephone-line-secondary-right-separator 'telephone-line-identity-hollow-left)
  (custom-set-faces
   `(telephone-line-evil-normal   ((t (:foreground "black" :background "#81A1C1"))))
   `(telephone-line-evil-insert   ((t (:foreground "black" :background "#A3BE8C"))))
   `(telephone-line-evil-visual   ((t (:foreground "black" :background "#D08770"))))
   `(telephone-line-evil-replace  ((t (:foreground "white" :background "#BF616A"))))
   `(telephone-line-evil-operator ((t (:foreground "black" :background "#B48EAD"))))
   `(telephone-line-evil-motion   ((t (:foreground "black" :background "#D8DEE9"))))
   `(telephone-line-evil-emacs    ((t (:foreground "white" :background "#4E1D6B"))))
   )
  (telephone-line-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :hook (prog-mode . rainbow-mode))

;;; Evil/Keybinds
(use-package general
  :config
  (general-define-key
   "<wheel-left>"  (lambda () (interactive) (scroll-right 2))
   "<wheel-right>" (lambda () (interactive) (scroll-left  2))))

(use-package evil
  :init
  (defconst evil-leader "SPC")
  (setq evil-want-C-u-scroll t
	evil-want-keybinding nil)
  (modify-syntax-entry ?_ "w")

  :config
  (evil-mode)

  :general
  (:keymaps 'key-translation-map "ESC" "C-g")

  (:keymaps 'override :states '(normal motion) :prefix evil-leader
    "h"   'help-command
    "w"   'evil-window-map

    "TAB" 'switch-to-buffer
    "k"   'kill-current-buffer

    "RET" 'execute-extended-command
    "eb"  'eval-buffer
    "ed"  'eval-defun
    "ee"  'eval-expression
    "er"  'eval-region
    "es"  'eval-last-sexp

    "nd"  'narrow-to-defun
    "nr"  'narrow-to-region
    "ns"  'org-narrow-to-subtree
    "nw"  'widen)

  (:keymaps 'override :states '(normal insert motion emacs)
    "s-u" 'universal-argument
    "C-h" 'evil-window-left
    "C-j" 'evil-window-down
    "C-k" 'evil-window-up
    "C-l" 'evil-window-right)

  (:keymaps 'override :states 'normal :prefix evil-leader
    "/"   'comment-line)

  (:keymaps 'override :states 'motion :prefix evil-leader
    "/"   'comment-dwim))

(use-package evil-collection
  :custom (evil-collection-want-unimpaired-p nil)
  :config (evil-collection-init))

(use-package evil-surround
  :config (global-evil-surround-mode))

(use-package evil-goggles
  :config
  (evil-goggles-mode)
  (evil-goggles-use-magit-faces))

(use-package avy
  :general
  (:keymaps '(evil-normal-state-map evil-motion-state-map)
    "s" 'avy-goto-char-timer
    "S" 'avy-resume
    "[s" 'avy-prev
    "]s" 'avy-next))

(use-package expand-region
  :general
  (:keymaps '(evil-normal-state-map evil-motion-state-map)
	    "s-k" 'er/expand-region
	    "s-j" 'er/contract-region))

(use-package which-key
  :config (which-key-mode))

;;; Projects
(use-package project
  :custom
  (project-switch-commands '((project-find-file "Find file" "f")
			     (project-dired "Dired" "d")
			     (vterm "Vterm" "t")))
  :general
  (:keymaps 'override :states '(normal motion) :prefix evil-leader
    "p" project-prefix-map)
  (:keymaps 'project-prefix-map
    "TAB" 'project-switch-to-buffer))

;;; Git
(use-package magit
  :config
  (setq magit-display-buffer-function
	'magit-display-buffer-same-window-except-diff-v1)
  :general
  (:keymaps 'override :states '(normal motion) :prefix evil-leader
    "gg" 'magit-status)
  (:keymaps '(magit-status-mode-map magit-diff-mode-map)
    "s-k" 'magit-section-backward
    "s-j" 'magit-section-forward))

(use-package git-gutter
  :config
  (setq git-gutter:update-interval 0.1)
  (global-git-gutter-mode)
  :general
  (:keymaps 'override :states '(normal motion) :prefix evil-leader
    "gm" 'git-gutter:mark-hunk
    "gp" 'git-gutter:popup-hunk
    "gr" 'git-gutter:revert-hunk
    "gs" 'git-gutter:stage-hunk)
  (:keymaps 'override :states '(normal motion)
    "[g" 'git-gutter:previous-hunk
    "]g" 'git-gutter:next-hunk))

(use-package git-gutter-fringe
  :config
  (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240] nil nil 'bottom))

;;; Terminal
(use-package vterm)

(use-package multi-vterm
  :general
  (:keymaps 'override :states '(normal motion) :prefix evil-leader
    "tt" 'multi-vterm
    "pt" 'multi-vterm-project)
  (:keymaps 'override :states '(normal motion)
    "[t" 'multi-vterm-prev
    "]t" 'multi-vterm-next)
  (:keymaps 'vterm-mode-map :states '(normal insert motion)
    "C-q" 'evil-quit))

;;; Tree-sitter
(use-package tree-sitter
  :config (global-tree-sitter-mode)
  :hook (tree-sitter-after-on . tree-sitter-hl-mode))

(use-package tree-sitter-langs)

(use-package evil-textobj-tree-sitter
  :config
  (defun textobj/prev-function ()
    (interactive)
    (if tree-sitter-mode
	(evil-textobj-tree-sitter-goto-textobj "function.outer" t)
      (beginning-of-defun)))
  (defun textobj/next-function ()
    (interactive)
    (if tree-sitter-mode
	(evil-textobj-tree-sitter-goto-textobj "function.outer")
      (end-of-defun)))
  :general
  (:keymaps 'evil-inner-text-objects-map
    "f" (evil-textobj-tree-sitter-get-textobj "function.inner"))
  (:keymaps 'evil-outer-text-objects-map
    "f" (evil-textobj-tree-sitter-get-textobj "function.outer"))
  (:keymaps 'override :states '(normal motion)
    "[f" 'textobj/prev-function
    "]f" 'textobj/next-function))

;;; LSP
(use-package eglot
  :config (setq eglot-stay-out-of '(company))
  :hook (python-mode . eglot-ensure))
  
;;; Completion
(use-package company
  :config
  (setq company-backends '((company-capf company-dabbrev company-files))
	company-dabbrev-downcase nil
	company-transformers '(delete-dups
			       company-sort-by-occurrence
			       company-sort-prefer-same-case-prefix))
  :general
  (:keymaps 'company-active-map
    [tab]    'company-complete-selection
    "`"      'company-complete-common
    "ESC"    'company-abort
    [return] 'evil-ret
    "RET"    'evil-ret)
  :hook
  (after-init . global-company-mode))

;;; Flymake
(use-package flymake
  :general
  (:keymaps 'override :states '(normal motion emacs)
    "[e"  'flymake-goto-prev-error
    "]e"  'flymake-goto-next-error)
  (:keymaps 'override :states '(normal motion emacs) :prefix evil-leader
    "q"   (lambda ()
	    (interactive)
	    (flymake-show-buffer-diagnostics)
	    (other-window 1)))
  (:keymaps 'flymake-diagnostics-buffer-mode-map :states 'normal
    "TAB" 'flymake-show-diagnostic))
  
;;; Emacs Lisp
(use-package lisp-mode
  :ensure nil
  :hook (emacs-lisp-mode . outline-minor-mode)
  :general
  (:keymaps 'outline-minor-mode-map :states 'normal
    "z0" 'outline-show-only-headings))

;;; Org
(use-package org
  :init
  (setq
   org-agenda-files (list "~/Library/Mobile Documents/com~apple~CloudDocs/org/")
   org-agenda-window-setup 'current-window
   org-todo-keywords
     '((type "TODO(t)" "PROJ(p)" "WAIT(w)" "MEET(m)" "|" "DONE(d)" "CANC(c)"))
   org-startup-indented t
   org-startup-folded 'content
   org-tags-column 0
   org-agenda-tags-column 0
   org-scheduled-string "REQ:"
   org-agenda-scheduled-leaders '("REQ: " "REQ.%2dx: ")
   org-scheduled-past-days 0
   org-agenda-skip-scheduled-if-done t
   org-deadline-string "DUE:"
   org-agenda-deadline-leaders '("DUE: " "In %3d d.: " "%2d d. ago: ")
   org-deadline-warning-days 0
   org-agenda-skip-deadline-if-done t
   org-log-done 'time
   org-log-done-with-time nil
   org-agenda-sorting-strategy '(
     (agenda todo-state-down deadline-up scheduled-up ts-up)
     (todo priority-down category-keep)
     (tags priority-down category-keep)
     (search category-keep))
   org-agenda-start-with-log-mode '(closed)
   org-agenda-use-time-grid nil
   org-bookmark-names-plist nil)
  :general
  (:keymaps 'org-mode-map :states 'normal
    "z0"  'outline-show-only-headings
    "s-h" 'org-metaleft
    "s-k" 'org-metaup
    "s-j" 'org-metadown
    "s-l" 'org-metaright)
  (:keymaps 'org-mode-map :states '(normal insert)
    "s-<return>" 'evil-org-org-insert-todo-heading-below)
  (:keymaps 'org-mode-map :states 'normal :prefix evil-leader
    "s"   'org-schedule
    "d"   'org-deadline)
  (:keymaps 'override :states '(normal motion) :prefix evil-leader
    "oa" 'org-agenda
    "of" '(lambda ()
	   (interactive)
	   (ido-find-file-in-dir (car org-agenda-files)))
    "os" 'org-occur-in-agenda-files))

(use-package evil-org
  :init
  (setq evil-org-key-theme
	'(textobjects insert navigation additional shift todo heading))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys)
  :hook
  (org-mode . (lambda() (evil-org-mode t))))

;;; Misc
(use-package emacs
  :init
  (setq auto-save-default nil
	backup-inhibited t
	custom-file "custom.el"
	delete-section-mode t
	frame-resize-pixelwise t
	help-window-select t
	ring-bell-function 'ignore)
  (pixel-scroll-precision-mode)
  (electric-pair-mode)
  (put 'narrow-to-region 'disabled nil)
  :hook
  (prog-mode . (lambda () (setq truncate-lines t))))

(use-package vertico
  :init (vertico-mode))

(use-package marginalia
  :init (marginalia-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file  (styles basic partial-completion))))
  :config
  (defun company-completion-styles (capf-fn &rest args)
    (let ((completion-styles '(basic partial-completion)))
      (apply capf-fn args))
    (advice-add 'company-capf :around #'company-completion-styles)
    (advice-add 'company-dabbrev :around #'company-completion-styles)
    (advice-add 'company-files :around #'company-completion-styles)))

;;; Startup
(setq inhibit-startup-screen t)
(find-file "~/dotfiles/emacs/init.el")
