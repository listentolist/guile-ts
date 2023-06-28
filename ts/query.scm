(define-module (ts query)
  #:use-module (ts init)
  #:use-module (ts util)
  #:use-module (ts language)
  #:use-module (oop goops)
  #:use-module (srfi srfi-171)
  #:export (ts-query-new
            ts-query-pattern-rooted?
            ts-query-predicates-for-pattern
            ts-query-cursor-new
            ts-query-cursor-exec
            ts-query-pattern-count
            ts-query-capture-count
            ts-query-string-count
            ts-query-capture-name-for-id
            ts-query-string-value-for-id
            ts-query-capture-quantifier-for-id
            ts-query-start-byte-for-pattern
            ts-query-cursor-set-byte-range!
            ts-query-cursor-next-match
            ts-query-cursor-remove-match
            ts-query-cursor-next-capture
            ts-query-match-id
            ts-query-match-pattern-index
            ts-query-match-captures))

(eval-when (expand load eval)
  (load-extension "libguile_ts" "init_ts_query"))

(define-class <ts-query-match> ()
  (id #:getter ts-query-match-id)
  (pattern-index #:getter ts-query-match-pattern-index)
  (captures #:getter ts-query-match-captures))

(define (ts-query-predicates-for-pattern self index)
  (let ((steps (%ts-query-predicates-for-pattern self index)))
    (list-transduce (compose
                     (tpartition (lambda (o) (eq? (car o) 'done)))
                     (tremove (lambda (o) (equal? o '((done . #f))))))
                    rcons steps)))
