;;; sqlnet-mode.el --- Major mode for editing sqlnet/listener/tnsnames.ora

;;; Commentary:


;;; Code:

(require 'newcomment)
(require 'smie)

;; Variables:

(defgroup sqlnet nil
  "SQL*Net configuration files."
  :group 'data
  )

(defcustom sqlnet-indent-basic 2
  "Basic amount of indentation.
Default is 2. Use smie-indent-basic when nil"
  :type 'integer
  :group 'sqlnet
  :safe (lambda (x) (and (integerp x) (> x 0)))
  )

;;;

(defconst sqlnet-smie-grammar nil)

(defun sqlnet-smie-rules (kind token)
  (pcase (cons kind token)
    (`(:list-intro . "") t)
    (`(:elem . basic) sqlnet-indent-basic)
    (`(:elem . empty-line-token)
     (cons 'column (* sqlnet-indent-basic (car (syntax-ppss))))
     )
    (`(:before . "(")
     (if (smie-rule-bolp)
         (cons 'column (* sqlnet-indent-basic (1+ (car (syntax-ppss)))))
       )
     )
    (`(:after . ")")
     (if (smie-rule-bolp)
         (cons 'column (* sqlnet-indent-basic (1- (car (syntax-ppss)))))
       )
     )
    )
  )

(defun sqlnet-smie-forward-token ()
  (smie-default-forward-token))

(defun sqlnet-smie-backward-token ()
  (smie-default-backward-token))


;;;

(defvar sqlnet-font-lock-keywords 'nil)
  ;; (list
  ;;  (cons (regexp-opt taskjuggler-properties 'words) font-lock-function-name-face)
  ;;  (cons (regexp-opt taskjuggler-attributes 'words) font-lock-keyword-face)
  ;;  (cons (regexp-opt taskjuggler-reports 'words) font-lock-builtin-face)
  ;;  (cons (regexp-opt taskjuggler-report-keywords 'words) font-lock-constant-face)
  ;;  (cons (regexp-opt taskjuggler-important 'words) font-lock-warning-face)
  ;;  '("\\('\\w*'\\)" . font-lock-variable-name-face))
  ;; "Default highlighting expressions for TASKJUG mode")

(defvar sqlnet-mode-syntax-table
  (let ((st (make-syntax-table)))
    ;; comment syntax
    (modify-syntax-entry ?#  "<"     st) ; shell-style comments
    (modify-syntax-entry ?\n ">"     st) ; comment endings
    (modify-syntax-entry ?\r ">"     st) ;
    ;; string syntax
    (modify-syntax-entry ?\" "\""    st) ; double quote strings
    ;;(modify-syntax-entry ?\' "\""    st) ; single quote strings
    st)
  "Syntax table to use for SQL*Net mode.")

;;;FIXME autoload
(define-derived-mode sqlnet-mode prog-mode
  "SQL*Net"
  "Major mode for editing tnsnames.ora and other Oracle SQL*Network.
"
  :syntax-table sqlnet-mode-syntax-table
  :group 'sqlnet
  ;;:after-hook ???

  ;; Setting up newcomments
  (setq-local comment-start "# ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "#+[ \t]*")

  ;; Setting up Font Lock mode
  (setq-local font-lock-defaults '(sqlnet-font-lock-keywords nil t nil nil))

  ;; Setting up SMIE
  (smie-setup sqlnet-smie-grammar #'sqlnet-smie-rules
              :forward-token 'sqlnet-smie-forward-token
              :backward-token 'sqlnet-smie-backward-token)

  ;;(use-local-map sqlnet-mode-map)
  )

(add-to-list 'auto-mode-alist '("listener\\.ora\\'" . sqlnet-mode))
(add-to-list 'auto-mode-alist '("sqlnet\\.ora\\'" . sqlnet-mode))
(add-to-list 'auto-mode-alist '("tnsnames\\.ora\\'" . sqlnet-mode))

(provide 'sqlnet-mode)
