
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; my-texmacs: the colours of the page on the screen
;;
;; With the dark interface the page is dark too; with the light one it keeps
;; the colours of TeXmacs (black on white). The interface follows the
;; preference "gui theme" (Edit > Preferences > General > User interface
;; theme): "dark", "light", or "default", which follows the appearance of
;; macOS when TeXmacs starts.
;;
;; packages/standard/std.ts takes the colours of the page from the functions
;; below. Printing, PDF export and the pictures made for other exports switch
;; them to black on white for the time they run. Nothing of this is saved in
;; the documents, and a document that sets its own colours keeps them.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (my-texmacs-system-dark?)
  (and (os-macos?)
       (string-starts?
         (var-eval-system "defaults read -g AppleInterfaceStyle 2>/dev/null")
         "Dark")))

(define my-texmacs-dark?
  (with theme (get-preference "gui theme")
    (cond ((== theme "dark") #t)
          ((== theme "default") (my-texmacs-system-dark?))
          (else #f))))

(define my-texmacs-printing? #f)

(define (my-texmacs-dark-page?)
  (and my-texmacs-dark? (not my-texmacs-printing?)))

(tm-define (my-texmacs-page-bg)
  (:secure #t)
  (if (my-texmacs-dark-page?) "#2b2b2b" "white"))

(tm-define (my-texmacs-page-fg)
  (:secure #t)
  (if (my-texmacs-dark-page?) "#e4e4e4" "black"))

(tm-define (my-texmacs-page-link)
  (:secure #t)
  (if (my-texmacs-dark-page?) "#8ab4f8" "global"))

;; TeXmacs caches each document style, on disk too, with the colours it was
;; computed with: forget them when the page changes from dark to light or
;; back since the last start.
(with mode (if my-texmacs-dark? "dark" "light")
  (when (!= (get-preference "my-texmacs page") mode)
    (style-clear-cache)
    (set-preference "my-texmacs page" mode)))

(define (my-texmacs-printing on?)
  (set! my-texmacs-printing? on?)
  (style-clear-cache))

(define (my-texmacs-while-printing thunk)
  (if (or my-texmacs-printing? (not my-texmacs-dark?))
      (thunk)
      (dynamic-wind
        (lambda () (my-texmacs-printing #t))
        thunk
        (lambda ()
          (my-texmacs-printing #f)
          (update-current-buffer)))))

(define my-texmacs-print-to-file print-to-file)
(define my-texmacs-print-pages-to-file print-pages-to-file)
(define my-texmacs-print print)
(define my-texmacs-print-pages print-pages)
(define my-texmacs-print-snippet print-snippet)

(tm-define (print-to-file . args)
  (my-texmacs-while-printing
    (lambda () (apply my-texmacs-print-to-file args))))
(tm-define (print-pages-to-file . args)
  (my-texmacs-while-printing
    (lambda () (apply my-texmacs-print-pages-to-file args))))
(tm-define (print . args)
  (my-texmacs-while-printing
    (lambda () (apply my-texmacs-print args))))
(tm-define (print-pages . args)
  (my-texmacs-while-printing
    (lambda () (apply my-texmacs-print-pages args))))
(tm-define (print-snippet . args)
  (my-texmacs-while-printing
    (lambda () (apply my-texmacs-print-snippet args))))
