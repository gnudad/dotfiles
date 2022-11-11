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
  :config (load-theme 'nord t))

(set-face-attribute 'default nil :font "JetBrains Mono" :height 200)
(set-face-attribute 'fringe  nil :background nil)
(add-to-list 'default-frame-alist '(undecorated-round . t))
(set-frame-parameter nil 'internal-border-width 10)
(setq-default header-line-format " ")
(set-face-attribute 'header-line  nil :inherit nil :background nil :height 0.2)

(use-package telephone-line
  :config
  (setq
   telephone-line-primary-left-separator 'telephone-line-identity-right
   telephone-line-secondary-left-separator 'telephone-line-identity-hollow-right
   telephone-line-primary-right-separator 'telephone-line-identity-left
   telephone-line-secondary-right-separator 'telephone-line-identity-hollow-left)
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

  :config
  (evil-mode)

  :general
  (:keymaps 'key-translation-map "ESC" "C-g")

  (:keymaps 'override :states '(normal motion) :prefix evil-leader
    "u"   'universal-argument
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

(use-package which-key
  :config (which-key-mode))

;;; Projects
(use-package project
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

;;; Emacs Lisp
(use-package lisp-mode
  :ensure nil
  :hook (emacs-lisp-mode . outline-minor-mode)
  :general
  (:keymaps 'outline-minor-mode-map
    "z0" 'outline-show-only-headings))

;;; Misc
(use-package emacs
  :init
  (setq auto-save-default nil
	backup-inhibited t
	custom-file "custom.el"
	delete-section-mode t
	frame-resize-pixelwise t
	ring-bell-function 'ignore)
  (pixel-scroll-precision-mode)
  (scroll-bar-mode -1)
  (put 'narrow-to-region 'disabled nil)
  :hook
  (prog-mode . (lambda () (setq truncate-lines t))))

(use-package vertico
  :init (vertico-mode))

(use-package marginalia
  :init (marginalia-mode))

;;; Startup
(setq inhibit-startup-screen t)
(find-file "~/dotfiles/emacs/init.el")
