(require 'pos-tip)
;; defface is not work great
(defface my-pos-tip-face
  '((t :height 15.0 :family "monospace"))
  "Face for pos-tip hover.")
(setq pos-tip-face 'my-pos-tip-face)
(setq pos-tip-foreground-color "#FFFFFF")
(setq pos-tip-background-color "#FFFFFF")


;; (setq pos-tip-background-color "yellow")
;; (setq pos-tip-border-color "purple")
;; (setq pos-tip-border-width 2)
;; (setq pos-tip-internal-border-width 1)
;; (setq pos-tip-use-relative-coordinates t)
;; (setq pos-tip-stay-near-point t)
(setq pos-tip-max-width 220)
(setq pos-tip-max-height 220)

;; naming is complicated TODO: change it
(defun my-momentarily-display-after-line-end (string &optional timeout)
  (let ((ov (make-overlay (line-end-position) (line-end-position))))
    (overlay-put
     ov 'after-string
     (concat (propertize " " 'display
                         `(space :align-to (- middle-fringe
                                              ,(1+ (length string)))))
             (propertize string 'face '(:height 2.0))))
    (sit-for (or timeout 5))
    (delete-overlay ov)))

(defun my-momentarily-small-display-after-line-end (string &optional timeout)
  (let ((ov (make-overlay (line-end-position) (line-end-position))))
    (overlay-put
     ov 'after-string
     (concat (propertize " " 'display
                         `(space :align-to (- middle-fringe
                                              ,(1+ (length string)))))
             (propertize string 'face '(:height 1.2))))
    (sit-for (or timeout 5))
    (delete-overlay ov)))


(defun my-momentarily-display-after-cursor-end (string &optional timeout)
  (let ((ov (make-overlay (point) (point))))
    (overlay-put ov 'after-string
                 (concat (propertize " " 'display
                                     '(space :align-to (+ left-fringe 10)))
                         (propertize string 'display
                                     '(raise -1)
                                     'face '(:height 3.5))
                         "\n\n"))
    (sit-for (or timeout 5))
    (delete-overlay ov)))


;; It Also works on bioxiv.org
;; example: https://www.biorxiv.org/content/10.1101/2023.01.21.524489v1
(defun hover-arxiv-abstract ()
  (interactive)
  (let* ((url (thing-at-point 'url))
         (script-path (expand-file-name "arxiv_abstract.py" (file-name-directory (locate-library "hover-arxiv-abstract"))))
         (if (and url (string-match "rxiv" url))
             (let ((output (shell-command-to-string (concat "python3 " script-path " " url))))
               (my-momentarily-small-display-after-line-end output))
           (message "No arxiv url found at cursor position."))))


(defun display-image-at-cursor ()
  "Display an image at the cursor position in the current buffer."
  (interactive)
  (let* ((file (thing-at-point 'filename))
         (image (create-image file)))
    (if (and file (file-exists-p file))
        (if image
            (let ((overlay (make-overlay (point) (point))))
              (overlay-put overlay 'before-string (propertize " " 'display image))
              (run-at-time 3 nil (lambda (ov) (delete-overlay ov)) overlay))
          (error "Failed to create image from file %s" file))
      (error "No file path at point"))))


(defun display-image-from-user-input (file)
  "Display image from user input"
  (interactive "fImage file: ")
  (if (file-exists-p file)
      (let ((image (create-image file)))
        (if image
            (let ((overlay (make-overlay (point) (point))))
              (overlay-put overlay 'before-string (propertize " " 'display image))
              (run-at-time 3 nil (lambda (ov) (delete-overlay ov)) overlay))
          (error "Failed to create image from file %s" file)))
    (error "File %s does not exist" file)))

(defun display-image-from-python-script (sentence)
  "Run a Python script, pass a sentence as an argument, and display the image generated by the script at the cursor position in the current buffer."
  (interactive "sEnter a sentence: ")
  (let* ((cwd (file-name-directory (buffer-file-name)))
         (script "lukimage.py")
         (output (shell-command-to-string (format "cd %s/image && python3 %s %s" cwd script (shell-quote-argument sentence))))
         (file-path (progn
                      (string-match "\\(.*\\)\\.\\(jpg\\|png\\|gif\\)$" output)
                      (concat cwd "image/" (match-string 1 output) "." (match-string 2 output))))
         )
    (message (format "Output: %s" output))
    (message (format "File path: %s" file-path))
    (sleep-for 2)
    (if (file-exists-p file-path)
        (let ((image (create-image file-path)))
          (if image
              (let ((overlay (make-overlay (point) (point))))
                (overlay-put overlay 'before-string (propertize " " 'display image))
                (run-at-time 3 nil (lambda (ov) (delete-overlay ov)) overlay))
            (error "Failed to create image from file %s" file)))
      (error "File %s does not exist" file))))


(defun evil-display-image-from-python-script ()
  "Run a Python script, pass a sentence as an argument, and display the image generated by the script at the cursor position in the current buffer."
  (interactive)
  (let* (
         (sentence (buffer-substring (region-beginning) (region-end)))
         (cwd "~/.spacemacs.d/image/")
         (script "lukimage.py")
         (output (shell-command-to-string (format "cd %s && python3 %s %s" cwd script (shell-quote-argument sentence))))
         (file-path (progn
                      (string-match "\\(.*\\)\\.\\(jpg\\|png\\|gif\\)$" output)
                      (concat cwd (match-string 1 output) "." (match-string 2 output))))
         )
    (message (format "Output: %s" output))
    (message (format "File path: %s" file-path))
    (sleep-for 2)
    (if (file-exists-p file-path)
        (let ((image (create-image file-path)))
          (if image
              (let ((overlay (make-overlay (point) (point))))
                (overlay-put overlay 'before-string (propertize " " 'display image))
                (run-at-time 3 nil (lambda (ov) (delete-overlay ov)) overlay))
            (error "Failed to create image from file %s" file)))
      (error "File %s does not exist" file))))

(defun evil-display-image-from-bing-script ()
  "Run a bing script, pass a sentence as an argument, and display the image generated by the script at the cursor position in the current buffer."
  (interactive)
  (let* (
         (sentence (buffer-substring (region-beginning) (region-end)))
         (cwd (file-name-directory (buffer-file-name)))
         (script "bing_lukimage.py")
         (output (shell-command-to-string (format "cd %s/image && python3 %s %s" cwd script (shell-quote-argument sentence))))
         (file-path (progn
                      (string-match "\\(.*\\)\\.\\(jpg\\|png\\|gif\\)$" output)
                      (concat cwd (match-string 1 output) "." (match-string 2 output))))
         )
    (message (format "Output: %s" output))
    (message (format "File path: %s" file-path))
    (sleep-for 2)
    (if (file-exists-p file-path)
        (let ((image (create-image file-path)))
          (if image
              (let ((overlay (make-overlay (point) (point))))
                (overlay-put overlay 'before-string (propertize " " 'display image))
                (run-at-time 3 nil (lambda (ov) (delete-overlay ov)) overlay))
            (error "Failed to create image from file %s" file)))
      (error "File %s does not exist" file))))

(defun evil-buffer-diagram-image-from-bing-script ()
  "Run a bing script, pass a sentence as an argument, and display the image generated by the script at the new buffer."
  (interactive)
  (let* (
         (sentence (buffer-substring (region-beginning) (region-end)))
         (sentence (concat  "diagram of " sentence ))
         (message sentence)
         (cwd (file-name-directory (buffer-file-name)))
         (script "bing_lukimage.py")
         (output (shell-command-to-string (format "cd %s/image && python3 %s %s" cwd script (shell-quote-argument sentence))))
         (file-path (progn
                      (string-match "\\(.*\\)\\.\\(jpg\\|png\\|gif\\)$" output)
                      (concat cwd (match-string 1 output) "." (match-string 2 output))))
         )
    (message (format "Output: %s" output))
    (message (format "File path: %s" file-path))
    (sleep-for 2)
    (if (file-exists-p file-path)
        (let ((image-buffer (get-buffer-create "*image*")))
          (switch-to-buffer-other-window image-buffer)
          (setq buffer-read-only nil)
          (erase-buffer)
          (let ((image (create-image file-path)))
            (if image
                (insert-image image)
              (error "Failed to create image from file %s" file))))
      (error "File %s does not exist" file))))

(defun evil-hover-diagram-image-from-bing-script ()
  "Run a bing script, pass a sentence as an argument, and display the image generated by the script at the cursor position in the current buffer."
  (interactive)
  (let* (
         (sentence (buffer-substring (region-beginning) (region-end)))
         (sentence (concat  "diagram of " sentence ))
         (message sentence)
         (cwd (file-name-directory (buffer-file-name)))
         (script "bing_lukimage.py")
         (output (shell-command-to-string (format "cd %s/image && python3 %s %s" cwd script (shell-quote-argument sentence))))
         (file-path (progn
                      (string-match "\\(.*\\)\\.\\(jpg\\|png\\|gif\\)$" output)
                      (concat cwd (match-string 1 output) "." (match-string 2 output))))
         )
    (message (format "Output: %s" output))
    (message (format "File path: %s" file-path))
    ;; change sleep time
    (sleep-for 2)
    (if (file-exists-p file-path)
        (let ((image (create-image file-path)))
          (if image
              ;; change overlay time
              (let ((overlay (make-overlay (point) (point))))
                (overlay-put overlay 'before-string (propertize " " 'display image))
                (run-at-time 7 nil (lambda (ov) (delete-overlay ov)) overlay))
            (error "Failed to create image from file %s" file)))
      (error "File %s does not exist" file))))

(defun my-specific-mode-hook ()
  (interactive)
  (add-hook 'post-command-hook 'hover_arxiv_abstract nil t))
(add-hook 'my-specific-mode-hook 'my-specific-mode-hook)

(defun my-escape-specific-mode ()
  (interactive)
  (my-specific-mode -1))



