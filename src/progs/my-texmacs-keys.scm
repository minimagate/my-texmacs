;; my-texmacs: keyboard shortcuts (loaded at every start)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Terminal-like deletion (macOS: M- is Command, A- is Option)
;;   Cmd+Backspace      delete to the start of the line
;;   Option+Backspace   delete the previous word
;;   Cmd+Fn+Backspace   delete to the end of the line
;;   Option+Fn+Backspace delete the next word
;; Deleted text does not go to the clipboard. With a selection, these keys
;; delete the selection; where there is nothing to delete, they act as
;; ordinary Backspace / Delete.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (my-texmacs-delete-range from to)
  (selection-set from to)
  (clipboard-cut "nowhere")
  (clipboard-clear "nowhere"))

(define (my-texmacs-delete-motion move forwards? same-leaf?)
  (if (selection-active-any?)
      (begin (clipboard-cut "nowhere") (clipboard-clear "nowhere"))
      (let ((p (cursor-path)))
        (move)
        (let* ((q (cursor-path))
               (from (if forwards? p q))
               (to (if forwards? q p)))
          (cond ((and (path-less? from to)
                      (or (not same-leaf?) (== (cDr from) (cDr to))))
                 (my-texmacs-delete-range from to))
                (else
                  (go-to-path p)
                  (if forwards? (kbd-delete) (kbd-backspace))))))))

(tm-define (my-texmacs-delete-line-backward)
  (my-texmacs-delete-motion kbd-start-line #f #f))

(tm-define (my-texmacs-delete-line-forward)
  (my-texmacs-delete-motion kbd-end-line #t #f))

(tm-define (my-texmacs-delete-word-backward)
  (my-texmacs-delete-motion go-to-previous-word #f #t))

(tm-define (my-texmacs-delete-word-forward)
  (my-texmacs-delete-motion go-to-next-word #t #t))

(kbd-map
  ("M-backspace" (my-texmacs-delete-line-backward))
  ("A-backspace" (my-texmacs-delete-word-backward))
  ("M-delete" (my-texmacs-delete-line-forward))
  ("A-delete" (my-texmacs-delete-word-forward)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Math: Cmd+1 instead of $ (Shift+4)
;;   Cmd+1 in text      open an inline formula
;;   Cmd+1 in a formula go to the end of the formula
;;   $ in text          types a plain $
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(kbd-map
  ("M-1" (make 'math))
  ("$" (insert "$")))

(kbd-map
  (:mode in-math?)
  ("M-1" (math-make-math)))
