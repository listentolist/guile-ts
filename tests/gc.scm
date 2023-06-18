(define-module (tests gc)
  #:use-module (ts api)
  #:use-module (oop goops)
  #:use-module (srfi srfi-64))

(test-group "gc test"
  (let* ((source "[1,null]")
         (parser (make <ts-parser>
                   #:language
                   (get-ts-language-from-file
                    (string-append (getenv "abs_top_builddir")
                                   "/tests/tree-sitter-json.so")
                    "tree_sitter_json")))
         (tree (ts-parser-parse-string parser #f source))
         (root (ts-tree-root-node tree))
         (n 100000))

    (test-assert (string-append "gc " (number->string n))
      (begin
        (do ((i 0 (+ i 1)))
            ((> i n))
          (ts-node-next-named-sibling
           (ts-node-named-child
            root
            (- (ts-node-named-child-count root) 1))))
        (ts-node-sexp root)))
    (ts-tree-delete tree)))