package masaw

import (
	"encoding/json"
	"flag"
	"fmt"
)

type Options struct {
	File string
	Help bool
}

func CmdParse() *Options {
	h := flag.Bool("h", false, "show help")
	help := flag.Bool("help", false, "show help")
	file := flag.String("file", "", "file name")
	flag.Parse()
	return &Options{*file, *help || *h}
}

func Printer(data *Info) {
	if bytes, err := json.Marshal(data); err == nil {
		fmt.Println(string(bytes[:]))
	} else {
		panic(err)
	}
}
