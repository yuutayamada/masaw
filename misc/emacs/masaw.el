;;; masaw.el --- Cosmetic package for golang

;; Copyright (C) 2014 by Yuta Yamada

;; Author: Yuta Yamada <cokesboy"at"gmail.com>
;; URL: https://github.com/yuutayamada/masaw
;; Version: 0.0.1
;; Package-Requires: ()
;; Keywords: golang

;;; License:
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;; Commentary:
;; To use this program, you should set below configuration:
;; (unless (require 'masaw nil t)
;;   (load (concat (getenv "GOPATH")
;;                 "/src/github.com/yuutayamada/masaw/misc/emacs/masaw")))
;; (add-hook 'masaw-after-gofmt-before-save-hook 'masaw)

;;; Code:
(require 'json)
(eval-when-compile (require 'cl))

(defvar masaw-program (executable-find "masaw"))
(defvar masaw-timer-object)
(defvar masaw-after-gofmt-before-save-hook '())
(defvar masaw-tasks '())

(defvar-local masaw-covered-flag nil)

(easy-mmode-define-minor-mode
 masaw-mode "Cosmetic package for golang" nil "M" nil
 (if masaw-covered-flag
     (progn (masaw-reset)
            (minibuffer-message "masaw-mode off"))
   (masaw)
   (minibuffer-message "masaw-mode on")))

(defun masaw ()
  "Hide some Golang's {}."
  (interactive)
  (condition-case err
      (when (and (eq major-mode 'go-mode) (file-exists-p buffer-file-truename))
        (add-hook 'post-self-insert-hook 'masaw-reset)
        (masaw-reset)
        (setq-local masaw-covered-flag t)
        (masaw-cancel-timer)
        (masaw-append (append `(,buffer-file-truename) (masaw-extract-braces)))
        (masaw-register-timer))
    (error (format "%s" err))))

(defun masaw-append (newtask)
  "Append NEWTASK."
  (lexical-let
      ((fname (car newtask)))
    (if (assoc fname masaw-tasks)
        (setq masaw-tasks
              (append `(,newtask)
                      (loop for elem in masaw-tasks
                            unless (string-match fname (car elem))
                            collect elem)))
      (add-to-list 'masaw-tasks newtask))))

(defun masaw-register-timer ()
  "Register timer func."
  (setq masaw-timer-object
        (run-with-timer
         0.5 nil (lambda ()
                   (masaw-hide-golang-braces)))))

(defun masaw-cancel-timer ()
  "Cancel timer."
  (when (timerp (bound-and-true-p masaw-timer-object))
    (cancel-timer masaw-timer-object)))

(defun masaw-hide-golang-braces ()
  "Hide braces."
  (lexical-let
      ((braces (assoc buffer-file-truename masaw-tasks)))
    (when (equal buffer-file-truename (car braces))
      (loop for (lc . (ll . (rc . (rl . nil)))) in (cdr braces) do
            (masaw-cover-by "" lc ll 1)
            (masaw-cover-by "" rc rl 0)))))

(defun masaw-parse-file (file)
  "Parse json FILE."
  (let ((json (json-read-from-string
               (shell-command-to-string (concat masaw-program " -file " file)))))
    (if (json-alist-p json)
        json
      (error (format "cannot produce json format from %s" file)))))

(defun masaw-extract-braces ()
  "Organize braces."
  (loop with tree = (masaw-parse-file buffer-file-truename)
        with file = (nth 1 tree)
        with braces = (cdr (nth 0 tree))
        for (rbrace . (lbrace . nil)) across braces
        for lcolumn = (cdadr  lbrace)
        for rcolumn = (cdadr  rbrace)
        for lline   = (cdaddr lbrace)
        for rline   = (cdaddr rbrace)
        collect `(,lcolumn ,lline ,rcolumn ,rline)))

(defun masaw-cover-by (char column line adjust)
  "Cover by CHAR at COLUMN LINE.
If you set ADJUST, then adjust column point."
  (save-excursion
    (masaw-move (+ column adjust) line)
    (masaw-hide (1- (point)) (point) char)))

(defun masaw-move (column line)
  "Move to COLUMN and LINE."
  (goto-char (point-min))
  (forward-line (1- line))
  (forward-char (1- column)))

(defun masaw-hide (start end char)
  "Hide START, END by CHAR."
  (interactive)
  (compose-region start end char))

(defun masaw-reset ()
  "Reset covered stuff."
  (interactive)
  (if (eq major-mode 'go-mode)
      (when masaw-covered-flag
        (setq-local masaw-covered-flag nil)
        (decompose-region (point-min) (point-max)))
    (remove-hook 'post-self-insert-hook 'masaw-reset)))

(defadvice gofmt-before-save
  (around masaw-add-hook activate)
  "Hook for covering by invisible char to Golang's braces.
Run this hook after `gofmt-before-save'."
  ad-do-it
  (run-hooks 'masaw-after-gofmt-before-save-hook))

(provide 'masaw)

;; Local Variables:
;; coding: utf-8
;; mode: emacs-lisp
;; End:

;;; masaw.el ends here
