# MASAW ![Build Status](https://travis-ci.org/yuutayamada/masaw.svg?branch=master)
This is cosmetic program for golang and Emacs.
You can get rid of some golang's braces and you can see python like syntax.

![Image](/masaw.png)

## Requirements

Go execution environment and gofmt

## Install

```sh
go get github.com/yuutayamada/masaw
```

## Emacs's Configuration

```lisp
(unless (require 'masaw nil t)
  (load (concat (getenv "GOPATH")
                "/src/github.com/yuutayamada/masaw/misc/emacs/masaw")))
(add-hook 'masaw-after-gofmt-before-save-hook 'masaw)
```

If you want to change this program manually, then configuration is like this:

```lisp
(define-key (kbd "C-3") 'masaw-mode) ; turn on or off
```

## Note

This program is still under development.
If you have any problem, let me know via github's issue.
