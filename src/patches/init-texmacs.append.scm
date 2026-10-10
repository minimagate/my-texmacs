
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; my-texmacs (appended by my-texmacs/scripts/build.sh)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; the colours of the page: dark with the dark interface, white on paper
(load (url-concretize "$TEXMACS_PATH/progs/my-texmacs-page.scm"))

;; the symbol search palette (Cmd+K)
(load (url-concretize "$TEXMACS_PATH/progs/my-texmacs-symbol-search.scm"))

;; keyboard shortcuts: terminal-like deletion, Cmd+1 for formulas
(load (url-concretize "$TEXMACS_PATH/progs/my-texmacs-keys.scm"))
