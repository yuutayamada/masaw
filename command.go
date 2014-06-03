package main

import (
	"flag"
)

func cmdParse() *Options {
	h := flag.Bool("h", false, "show help")
	help := flag.Bool("help", false, "show help")
	file := flag.String("file", "", "file name")
	flag.Parse()
	return &Options{*file, *help || *h}
}

type Options struct {
	File string
	Help bool
}
