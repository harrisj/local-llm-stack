;; =============================================================================
;; 1. GHOSTEL UTILITIES & POPUPS
;; =============================================================================

(use-package! ghostel)

(use-package! evil-ghostel
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))

(defun +ghostel-display-responsive-fn (buffer alist)
  "Display Ghostel at the 'right on portrait screens, or 'bottom on landscape screens."
  (let* ((side (if (> (frame-pixel-height) (frame-pixel-width)) 'right 'bottom))
         (size (if (eq side 'right) 0.40 0.35))
         ;; Explicitly override the side and window-height/window-width layout options
         (extended-alist (append `((side . ,side)
                                   (window-height . ,size)
                                   (window-width . ,size)) 
                                 alist)))
    (+popup-display-buffer-stacked-side-window-fn buffer extended-alist)))

(after! ghostel
  (add-hook 'ghostel-mode-hook
            (lambda ()
              ;; Changes the font family and size specifically inside this buffer
              (face-remap-add-relative 'default 
                                       :family "Fira Code" 
                                       :height 120)))
  
  ;; 1. Standard Ghostel buffers keep using your responsive layout function
  (set-popup-rule! "^\\*ghostel" 
    :actions '(+ghostel-display-responsive-fn)
    :vslot -4 
    :select t 
    :quit nil 
    :ttl 0)
  
  ;; 2. The Pi Fallback buffer is explicitly forced to open on the right
  (set-popup-rule! "^\\*pi-tui-fallback" 
    :side 'right      ; Always open on the right edge
    :size 0.30        ; Occupy 30% of the screen width
    :vslot -3 
    :select t 
    :quit nil 
    :ttl 0)

  )

;; =============================================================================
;; 2. TOGGLE HELPERS & COMMANDS
;; =============================================================================

(defun +pi/ghostel-tui-escape ()
  "Launch the native Pi TUI inside Ghostel using Doom's popup engine.
Only kill *pi-tui-fallback* if its default-directory ≠ project root.
Reuse otherwise and bring the buffer to the foreground."
  (interactive)
  (let* ((proj-dir (or (doom-project-root) default-directory))
         (buf-name "*pi-tui-fallback*")
         (existing-buf (get-buffer buf-name))
         (buf nil))
    
    ;; 1. Choose or create the buffer
    (if existing-buf
        (with-current-buffer existing-buf
          (let ((curr-dir default-directory))
            ;; Use string= instead of eq for string path comparisons
            (if (string= curr-dir proj-dir)
                (setq buf existing-buf)
              (kill-buffer existing-buf)
              (setq buf (get-buffer-create buf-name)))))
      ;; FIXED: This is now correctly the 'else' branch of the if statement
      (setq buf (get-buffer-create buf-name)))

    ;; 2. Ensure the chosen buffer's default-directory is correct (project root)
    (with-current-buffer buf 
      (setq default-directory proj-dir))

    ;; 3. Bring the buffer to the foreground
    (pop-to-buffer buf)

    ;; 4. Final setup
    (setq evil-ghostel-escape 'terminal)
    (ghostel-exec buf "fence" '("pi"))))

(defun +ghostel/toggle ()
  "Toggle the default global Ghostel terminal popup window."
  (interactive)
  (let ((buffer (get-buffer "*ghostel*")))
    (if (and buffer (get-buffer-window buffer))
        (delete-window (get-buffer-window buffer))
      (ghostel))))

(defun +ghostel/toggle-project ()
  "Toggle a responsive Ghostel terminal mapped strictly to the current project root."
  (interactive)
  (if-let* ((project (project-current))
            (root (project-root project))
            ;; Ghostel names project buffers based on the directory name format
            (buf-name (format "*ghostel-%s*" (file-name-nondirectory (directory-file-name root))))
            (buffer (get-buffer buf-name)))
      (if (get-buffer-window buffer)
          (delete-window (get-buffer-window buffer))
        (pop-to-buffer buffer))
    ;; If no terminal instance exists for this project yet, create it natively
    (ghostel-project)))

;; =============================================================================
;; 3. KEYBINDINGS
;; =============================================================================

(map! :leader
      ;; Main toggles
      :desc "Toggle Ghostel terminal"   "o t" #'+ghostel/toggle
      :desc "Open Ghostel here"        "o T" #'ghostel
      :desc "Project Ghostel terminal" "p t" #'+ghostel/toggle-project
      
      ;; Integrated custom c (code) prefix maps (Doom v3 syntax compatible)
      (:prefix-map ("c" . "code")
       :desc "Pi Agent TUI Escape"     "p" #'+pi/ghostel-tui-escape))

;; Traditional keybinding fallback
(map! "C-c p t" #'+pi/ghostel-tui-escape)
