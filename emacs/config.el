;; =============================================================================
;; PILISH
;; =============================================================================

;; IMPORTANT Customize pilish in customize-group to call
;; fence -m --fence-log-file ~/code/tmp/fence-denials.log -- pi

(defvar +pilish-layout-state nil
  "Tracks the current layout state of the pilish windows.
Values can be nil (hidden), 'right-third, or 'fullscreen.")

(defun +pilish-get-window-by-type (type)
  "Find a pilish window matching TYPE ('chat or 'input)."
  (cl-find-if
   (lambda (w)
     (let ((bname (buffer-name (window-buffer w))))
       (cond
        ((eq type 'chat)  (string-match-p "\\*pilish-chat:.*\\*" bname))
        ((eq type 'input) (string-match-p "\\*pilish-input:.*\\*" bname)))))
   (window-list)))

(defun +pilish-toggle-layout ()
  "Cyclically toggle the dual-window pilish environment sequence:
1. First invocation: Carves a 1/3 slice on the right and boots pilish inside it.
2. Second invocation: Maximizes the layout to full-screen.
3. Third invocation: Closes the layout entirely."
  (interactive)
  ;; Suppress workspace structural change updates while we reorganize the layout tree
  (let ((window-configuration-change-hook nil)
        (inhibit-redisplay t))
    (cond
     ;; STATE 1: Hidden -> Suspend +popup & workspaces, carve 1/3 layout slice and launch pilish
     ((null +pilish-layout-state)
      (let ((chat-w (+pilish-get-window-by-type 'chat)))
        (unless chat-w
          ;; Let-bind +popup and buffer rules to completely isolate this transaction
          (let* ((+popup-window-parameters nil)
                 (display-buffer-alist nil)
                 (right-drawer-w (split-window (frame-root-window) 
                                               (- (frame-width) (/ (frame-width) 3)) 
                                               'right)))
            ;; Move focus inside the freshly carved right drawer before booting
            (select-window right-drawer-w)
            
            ;; Execute pilish inside this dedicated layout slice
            (if (fboundp 'pilish)
                (pilish)
              (call-interactively 'pilish))
            
            ;; Re-enforce layout geometry adjustments after pilish draws its 20% input line
            (let ((new-chat-w (+pilish-get-window-by-type 'chat)))
              (when (and new-chat-w (window-parent new-chat-w))
                (let ((window-size-fixed nil)
                      (window-combination-resize t)
                      (p-window (window-parent new-chat-w))
                      (target-width (/ (frame-width) 3)))
                  (window-resize p-window (- target-width (window-width p-window)) t))))))
        
        ;; Explicitly select the input window so you can type immediately
        (let ((input-w (+pilish-get-window-by-type 'input)))
          (when input-w (select-window input-w))))
      (setq +pilish-layout-state 'right-third))

     ;; STATE 2: Right-Third -> Maximize to full screen
     ((eq +pilish-layout-state 'right-third)
      (let ((chat-w (+pilish-get-window-by-type 'chat))
            (input-w (+pilish-get-window-by-type 'input)))
        (if (and chat-w input-w)
            (progn
              ;; Clear out workspace restrictions briefly to mutate frame root layout
              (let ((window-size-fixed nil))
                (dolist (w (window-list))
                  (unless (memq w (list chat-w input-w))
                    (delete-window w))))
              ;; Refocus the input pane
              (select-window input-w)
              (setq +pilish-layout-state 'fullscreen))
          (setq +pilish-layout-state nil))))

     ;; STATE 3: Fullscreen -> Close and clear state via native binary toggle
     ((eq +pilish-layout-state 'fullscreen)
      (if (fboundp 'pilish-toggle)
          (pilish-toggle)
        ;; Fallback structural layout purge
        (let ((chat-w (+pilish-get-window-by-type 'chat))
              (input-w (+pilish-get-window-by-type 'input)))
          (when chat-w (delete-window chat-w))
          (when input-w (delete-window input-w))))
      (setq +pilish-layout-state nil)))))

;; Bind to Doom Leader 'SPC c p'
(map! :leader
      :desc "Cycle Pilish Layout states" "c p" #'+pilish-toggle-layout)

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
