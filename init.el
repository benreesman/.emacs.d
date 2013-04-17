;; paths
(setq emacs-dir (file-name-directory
		 (or (buffer-file-name) load-file-name)))

(add-to-list 'load-path emacs-dir)

(setq autoload-file (concat emacs-dir "loaddefs.el"))
(setq package-user-dir (concat emacs-dir "elpa"))
(setq custom-file (concat emacs-dir "custom.el"))

;; packages
(require 'package)
(add-to-list 'package-archives 
    '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)

;; turn off gui elements
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (tooltip-mode -1)
  (mouse-wheel-mode t))

(add-hook 'before-make-frame-hook 'turn-off-tool-bar)

;; utf-8
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(ansi-color-for-comint-mode-on)

(setq visible-bell nil
      fringe-mode (cons 4 0)
      echo-keystrokes 0.1
      font-lock-maximum-decoration t
      inhibit-startup-message t
      transient-mark-mode t
      color-theme-is-global t
      shift-select-mode nil
      mouse-yank-at-point t
      require-final-newline t
      truncate-partial-width-windows nil
      uniquify-buffer-name-style 'forward
      ffap-machine-p-known 'reject
      whitespace-style '(trailing lines space-before-tab
                                  face indentation space-after-tab)
      whitespace-line-column 100
      ediff-window-setup-function 'ediff-setup-windows-plain
      make-backup-files nil
      auto-save-default nil
      xterm-mouse-mode t)

;; lusty explorer
(require 'lusty-explorer)

;; keybindings
(global-set-key (kbd "C-x C-f") 'lusty-file-explorer)
(global-set-key (kbd "C-x C-b") 'lusty-buffer-explorer)
(global-set-key (kbd "C-x \\") 'align-regexp)
(define-key global-map (kbd "C-+") 'text-scale-increase)
(define-key global-map (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "\C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)
(global-set-key (kbd "C-c r") 'revert-buffer)
(global-set-key (kbd "C-x O") (lambda () (interactive) (other-window -1))) ;; back one
(global-set-key (kbd "C-x C-o") (lambda () (interactive) (other-window 2))) ;; forward two
(global-set-key (kbd "C-h a") 'apropos)
(global-set-key (kbd "C-c q") 'join-line)
(global-set-key (kbd "M-N") 'windmove-right)          ; move to ; left
(global-set-key (kbd "M-P") 'windmove-left)          ; move to ; left windnow

(global-set-key (kbd "C-c C-r") 'revert-all-buffers)
(global-set-key (kbd "C-c C-v") 'kill-all-buffers)
(global-set-key (kbd "C-c C-j") 'recompile)

;; 23/24 breakage
(when (not (fboundp 'plist-to-alist))
  (defun plist-to-alist (the-plist)
    (defun get-tuple-from-plist (the-plist)
      (when the-plist
	(cons (car the-plist) (cadr the-plist))))

    (let ((alist '()))
      (while the-plist
	(add-to-list 'alist (get-tuple-from-plist the-plist))
	(setq the-plist (cddr the-plist)))
      alist)))

;; ido
(when (> emacs-major-version 21)
  (ido-mode t)
  (setq ido-enable-prefix nil
        ido-enable-flex-matching t
        ido-create-new-buffer 'always
        ido-use-filename-at-point 'guess
        ido-max-prospects 10))

;; cursor/scroll
(global-hl-line-mode 1)
(blink-cursor-mode t)
(setq scroll-step           1
      scroll-conservatively 10000)

;; color theme
(color-theme-solarized-dark)

;; coding
(defun local-column-number-mode ()
  (make-local-variable 'column-number-mode)
  (column-number-mode t))

(defun local-comment-auto-fill ()
  (set (make-local-variable 'comment-auto-fill-only-comments) t)
  (auto-fill-mode t))

(defun turn-on-hl-line-mode ()
  (when (> (display-color-cells) 8) (hl-line-mode t)))

(defun turn-on-save-place-mode ()
  (setq save-place t))

(defun turn-on-whitespace ()
  (whitespace-mode t))

(defun turn-on-paredit ()
  (paredit-mode t))

(defun turn-off-tool-bar ()
  (tool-bar-mode -1))

(defun add-watchwords ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\|TODO\\|FIXME\\|HACK\\|REFACTOR\\):"
          1 font-lock-warning-face t))))

(add-hook 'coding-hook 'local-column-number-mode)
(add-hook 'coding-hook 'local-comment-auto-fill)
(add-hook 'coding-hook 'turn-on-hl-line-mode)
(add-hook 'coding-hook 'turn-on-save-place-mode)
(add-hook 'coding-hook 'pretty-lambdas)
(add-hook 'coding-hook 'add-watchwords)

(defun run-coding-hook ()
  "Enable things that are convenient across all coding buffers."
  (run-hooks 'coding-hook))

(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))

(defun cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (indent-buffer)
  (untabify-buffer)
  (delete-trailing-whitespace))

(defun pretty-lambdas ()
  (font-lock-add-keywords
   nil `(("(?\\(lambda\\>\\)"
          (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                    ,(make-char 'greek-iso8859-7 107))
                    nil))))))

;; paredit
(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)

;; auto-complete
(require 'auto-complete-config)
(ac-config-default)

;; smart split
(defun smart-split ()
  "Split the frame into exactly as many 80-column sub-windows as
   possible."
  (interactive)
  (defun ordered-window-list ()
    "Get the list of windows in the selected frame, starting from
     the one at the top left."
    (window-list (selected-frame) (quote no-minibuf) (frame-first-window)))
  (defun resize-windows-destructively (windows)
    "Resize each window in the list to be 80 characters wide. If
     there is not enough space to do that, delete the appropriate
     window until there is space."
    (when windows
      (condition-case nil
          (progn
            (adjust-window-trailing-edge
             (first windows)
             (- 80 (window-width (first windows))) t)
            (resize-windows-destructively (cdr windows)))
        (error
         (if (cdr windows)
             (progn
               (delete-window (cadr windows))
               (resize-windows-destructively
                (cons (car windows) (cddr windows))))
           (ignore-errors
             (delete-window (car windows))))))))
  (defun subsplit (w)
    "If the given window can be split into multiple 80-column
     windows, do it."
    (when (> (window-width w) (* 2 81))
      (let ((w2 (split-window w 82 t)))
        (save-excursion
          (select-window w2)
          (switch-to-buffer (other-buffer (window-buffer w)))))
      (subsplit w)))
  (resize-windows-destructively (ordered-window-list))
  (walk-windows (quote subsplit))
  (balance-windows))

;; Originally from stevey, adapted to support moving to a new
;; directory.
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive
   (progn
     (if (not (buffer-file-name))
         (error "Buffer '%s' is not visiting a file!" (buffer-name)))
     (list (read-file-name (format "Rename %s to: " (file-name-nondirectory
                                                     (buffer-file-name)))))))
  (if (equal new-name "")
      (error "Aborted rename"))
  (setq new-name (if (file-directory-p new-name)
                     (expand-file-name (file-name-nondirectory
                                        (buffer-file-name))
                                       new-name)
                   (expand-file-name new-name)))
    ;; If the file isn't saved yet, skip the file rename, but still
  ;; update the
  ;; buffer name and visited file.
  (if (file-exists-p (buffer-file-name))
      (rename-file (buffer-file-name) new-name 1))
  (let ((was-modified (buffer-modified-p)))
    ;; This also renames the buffer, and works with uniquify
    (set-visited-file-name new-name)
    (if was-modified
        (save-buffer)
            ;; Clear buffer-modified flag caused by
      ;; set-visited-file-name
      (set-buffer-modified-p nil))
      (message "Renamed to %s." new-name)))

;; show the current file for the buffer, useful if the buffer was
;; opened from the tag interface
(defun show-current-file ()
  (interactive)
  (message (buffer-file-name)))
(global-set-key (kbd "C-c f") 'show-current-file)

(defun kill-all-buffers ()
  "Kill all other buffers."
  (interactive)
  (mapc 'kill-buffer
        (remove-if-not 'buffer-file-name (buffer-list))))

;; custom
(load custom-file)

(smart-split)
