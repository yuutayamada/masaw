package main

import (
	"encoding/json"
	"fmt"
)

func printer(data *Info) {
	if bytes, err := json.Marshal(data); err == nil {
		fmt.Println(string(bytes[:]))
	} else {
		panic(err)
	}
}
