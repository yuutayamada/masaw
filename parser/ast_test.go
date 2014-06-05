package masaw

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"testing"
)

func TestParser(t *testing.T) {
	b1, _ := ioutil.ReadFile("../test/sample.out.json")
	info := Info{File: "../test/sample.go"}
	info.Braces = GetPositions(info.File, "")
	b2, _ := json.Marshal(info)
	if !(len(b1)-1 == len(b2)) {
		t.Error("\n file size was not matched.")
		fmt.Printf("sample.go:       %i\nsample.out.json: %i", len(b1), len(b2))
	}
	for i, _ := range b1 {
		if !bytes.Equal(b1[:i], b2[:i]) {
			t.Error("\n parsed file and sample.out.json file was not matched.")
			fmt.Println(b1, "\n", b2)
		}
	}
}
