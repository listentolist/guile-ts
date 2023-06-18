(define-module (tests tcursor)
  #:use-module (ts api)
  #:use-module (oop goops)
  #:use-module (srfi srfi-64))

(test-group "tree-curosr"
  (let* ((source "[1,null]")
         (parser (make <ts-parser>
                   #:language
                   (get-ts-language-from-file
                    (string-append (getenv "abs_top_builddir")
                                   "/tests/tree-sitter-json.so")
                    "tree_sitter_json")))
         (tree (ts-parser-parse-string parser #f source))
         (root (ts-tree-root-node tree)))

    (test-assert "ts-tree-cursor-delete"
      (ts-tree-cursor-delete
       (ts-tree-cursor-new root)))
    (test-error "ts-tree-cursor-delete: error value"
                'wrong-type-arg
                (ts-tree-cursor-delete #f))
    (test-error
     "ts-tree-cursor-delete: delete twice"
     #t
     (let ((t (ts-tree-cursor-new root)))
       (ts-tree-cursor-delete t)
       (ts-tree-cursor-delete t)))

    (let ((cursor (ts-tree-cursor-new root)))
      (test-equal "ts-tree-cursor-current-node"
        root
        (ts-tree-cursor-current-node cursor))
      (ts-tree-cursor-delete cursor))
    (let ((cursor (ts-tree-cursor-new root))
          (node2 (ts-node-child (ts-node-child root 0) 0) ))
      (ts-tree-cursor-reset! cursor node2)
      (test-equal "ts-tree-cursor-reset!"
        node2
        (ts-tree-cursor-current-node cursor))
      (ts-tree-cursor-delete cursor))

    (let ((cursor (ts-tree-cursor-new root)))
      (test-error "ts-tree-cursor-reset!: error value"
                  #t
                  (ts-tree-cursor-reset! cursor #f))
      (ts-tree-cursor-delete cursor))

    (let* ((_cursor (ts-tree-cursor-new root))
           (cursor (ts-tree-cursor-copy _cursor)))
      (test-assert "ts-tree-cursor-copy: copyed obj is different obj"
        (not (equal? _cursor cursor)))

      (ts-tree-cursor-delete _cursor)

      (test-equal "ts-tree-cursor-copy: use new one after deleted original one"
        root (ts-tree-cursor-current-node cursor))
      (ts-tree-cursor-delete cursor))

    (let* ((cursor (ts-tree-cursor-new root)))
      (test-assert "ts-tree-cursor-goto-first-child"
        (ts-tree-cursor-goto-first-child cursor))

      (let ((c2 (ts-tree-cursor-copy cursor)))
        (test-assert "ts-tree-cursor-goto-parent: move successfully"
          (ts-tree-cursor-goto-parent cursor))
        (ts-tree-cursor-delete c2))

      (test-equal "ts-tree-cursor-goto-parent: go to parent"
        root
        (begin (ts-tree-cursor-goto-parent cursor)
               (ts-tree-cursor-current-node cursor)))
      (ts-tree-cursor-delete cursor))

    (let ((cursor (ts-tree-cursor-new root)))
      (test-equal "ts-tree-cursor-goto-parent: no parent"
        #f (ts-tree-cursor-goto-parent cursor))
      (ts-tree-cursor-delete cursor))

    (ts-tree-delete tree)))