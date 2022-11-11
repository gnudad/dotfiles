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
(use-package evil
  :init (setq evil-want-keybinding nil)
  :config (evil-mode))

(use-package evil-collection
  :config (evil-collection-init))

(use-package which-key
  :config (which-key-mode))

;;; Git
(use-package magit
  :config (setq magit-display-buffer-function
		'magit-display-buffer-same-window-except-diff-v1))

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
