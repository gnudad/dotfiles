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
(set-face-attribute 'default nil :font "JetBrains Mono" :height 200)
(add-to-list 'default-frame-alist '(undecorated-round . t))

;;; Evil/Keybinds
(use-package general)

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

  (:keymaps 'override
    "C-h" 'evil-window-left
    "C-j" 'evil-window-down
    "C-k" 'evil-window-up
    "C-l" 'evil-window-right)

  (:keymaps 'override :states 'normal :prefix evil-leader
    "/"   'comment-line)
  (:keymaps 'override :states 'motion :prefix evil-leader
    "/"   'comment-dwim))

(use-package evil-collection
  :config (evil-collection-init))

(use-package which-key
  :config (which-key-mode))

;;; Git/Project
(use-package magit
  :config (setq magit-display-buffer-function
		'magit-display-buffer-same-window-except-diff-v1))

(use-package project
  :general
  (:keymaps 'override :states '(normal motion) :prefix evil-leader
    "p" project-prefix-map)
  (:keymaps 'project-prefix-map
    "TAB" 'project-switch-to-buffer))

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

;;; Startup
(setq inhibit-startup-screen t)
(find-file "~/dotfiles/emacs/init.el")
