package main

import (
	"fmt"

	m "github.com/yuutayamada/masaw/parser"
)

var (
	info    m.Info
	options *m.Options
)

func main() {
	if options = m.CmdParse(); options.File == "" {
		fmt.Println("File not found, you need to specify file by -file option.")
		return
	}
	info = m.Info{File: options.File}
	info.Braces = m.GetPositions(info.File, "")
	m.Printer(&info)
}
