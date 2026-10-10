
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; my-texmacs: the symbol search palette (Cmd+K)
;;
;; Cmd+K opens a small window: a search field over the best matches among
;; the symbols of progs/my-texmacs-symbols.tsv. Type to search (names, LaTeX
;; names, Unicode names, a few English and Italian synonyms; any case),
;; Up/Down to move the highlight, Return to insert the highlighted symbol at
;; the cursor (in a formula if the cursor is in text), Esc to close. A click
;; on a match inserts it too. Nothing is inserted otherwise.
;;
;; The field is of the "search" type, like the search bar of TeXmacs: it
;; reports every key, with the text typed so far.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define my-texmacs-symbols #f)          ; list of (symbol label words)
(define my-texmacs-symbol-max 10)       ; number of matches shown
(define my-texmacs-symbol-query "")     ; the text typed so far
(define my-texmacs-symbol-hits '())     ; the matches shown
(define my-texmacs-symbol-index 0)      ; the highlighted match

(define (my-texmacs-symbols-load)
  (when (not my-texmacs-symbols)
    (let* ((u (url-concretize "$TEXMACS_PATH/progs/my-texmacs-symbols.tsv"))
           (lines (string-split (string-load u) #\newline))
           (l '()))
      (for (line lines)
        (when (and (!= line "") (not (string-starts? line "#")))
          (with p (string-split line #\tab)
            (when (== (length p) 3)
              (set! l (cons p l))))))
      (set! my-texmacs-symbols (reverse l)))))

;; Ranking: 0 = the name, 1 = the name starts with the query, 2 = a word
;; starts with it, 3 = it occurs somewhere. All the words of the query must
;; occur. Ties keep the order of the list (common symbols first).

(define (my-texmacs-symbol-rank entry words-of-query)
  (let* ((name (car (string-split (cadr entry) #\space)))
         (words (caddr entry))
         (q (car words-of-query)))
    (and (list-and (map (lambda (w) (string-occurs? w words)) words-of-query))
         (cond ((== name q) 0)
               ((string-starts? name q) 1)
               ((or (string-starts? words q)
                    (string-occurs? (string-append " " q) words)) 2)
               (else 3)))))

(define (my-texmacs-symbol-search-update query)
  (set! my-texmacs-symbol-query query)
  (set! my-texmacs-symbol-index 0)
  (let* ((q (string-downcase query))
         (ws (list-filter (string-split q #\space) (lambda (w) (!= w "")))))
    (if (null? ws)
        (set! my-texmacs-symbol-hits (sublist my-texmacs-symbols 0 my-texmacs-symbol-max))
        (let ((buckets (list '() '() '() '())))
          (for (e my-texmacs-symbols)
            (and-with r (my-texmacs-symbol-rank e ws)
              (list-set! buckets r (cons e (list-ref buckets r)))))
          (with all (apply append (map reverse buckets))
            (set! my-texmacs-symbol-hits
                  (sublist all 0 (min my-texmacs-symbol-max (length all)))))))))

(define (my-texmacs-insert-symbol sym)
  (if (in-math?)
      (insert sym)
      (insert `(math ,sym))))

(define (my-texmacs-symbol-choose entry quit)
  (when entry
    (quit)
    (my-texmacs-insert-symbol (car entry))))

(define (my-texmacs-symbol-highlighted)
  (and (< my-texmacs-symbol-index (length my-texmacs-symbol-hits))
       (list-ref my-texmacs-symbol-hits my-texmacs-symbol-index)))

(define (my-texmacs-symbol-key what quit)
  (let ((text (if (pair? what) (car what) what))
        (key (and (pair? what) (cadr what))))
    (cond ((== key "return")
           (my-texmacs-symbol-choose (my-texmacs-symbol-highlighted) quit))
          ((== key "escape") (quit))
          ((in? key '("down" "up"))
           (with n (length my-texmacs-symbol-hits)
             (when (> n 0)
               (set! my-texmacs-symbol-index
                     (modulo (+ my-texmacs-symbol-index (if (== key "down") 1 -1))
                             n))
               (refresh-now "my-texmacs-symbol-hits"))))
          ((and (string? text) (!= text my-texmacs-symbol-query))
           (my-texmacs-symbol-search-update text)
           (refresh-now "my-texmacs-symbol-hits")))))

(define (my-texmacs-symbol-label entry)
  (string-append (car entry) "      " (cadr entry)))

(tm-widget ((my-texmacs-symbol-search-widget) quit)
  (padded
    (input (my-texmacs-symbol-key answer quit) "search" (list "") "34em")
    ===
    (resize "34em" "330px"
      (refreshable "my-texmacs-symbol-hits"
        (vertical
          (for (e my-texmacs-symbol-hits)
            (if (== e (my-texmacs-symbol-highlighted))
                (class "my-texmacs-hit"
                  ((eval (my-texmacs-symbol-label e)) (my-texmacs-symbol-choose e quit))))
            (if (!= e (my-texmacs-symbol-highlighted))
                (class "my-texmacs-row"
                  ((eval (my-texmacs-symbol-label e)) (my-texmacs-symbol-choose e quit)))))
          (if (null? my-texmacs-symbol-hits)
              (text "No matching symbol")))))))

(tm-define (my-texmacs-symbol-search)
  (:synopsis "Search a symbol by name and insert it")
  (my-texmacs-symbols-load)
  (my-texmacs-symbol-search-update "")
  (dialogue-window (my-texmacs-symbol-search-widget) (lambda x (noop)) "Symbols"))

(kbd-map
  ("M-k" (my-texmacs-symbol-search)))
