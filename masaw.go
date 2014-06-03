package main

import (
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
)

type Brace struct {
	LBrace *Position
	RBrace *Position
}

type Position struct {
	Line   int // height from above
	Column int // width from left
}

type Info struct {
	File   string
	Braces *[]Brace
}

var (
	info    Info = Info{}
	options *Options
)

func main() {
	if options = cmdParse(); options.File == "" {
		fmt.Println("File not found, you need to specify file by -file option.")
		return
	}
	info = Info{File: options.File}
	getPositions(info.File, "")
	printer(&info)
}

func getPositions(filename, src string) {
	var bracePositions []Brace
	fset := token.NewFileSet()
	f, err := parser.ParseFile(fset, filename, nil, 0)
	if err != nil {
		panic(err)
	}
	ast.Inspect(f, func(n ast.Node) bool {
		switch n.(type) {
		case *ast.BlockStmt:
			bracePositions = append(bracePositions,
				[]Brace{
					Brace{
						&Position{fset.Position(n.Pos()).Line, fset.Position(n.Pos()).Column},
						&Position{fset.Position(n.End()).Line, fset.Position(n.End()).Column},
					},
				}...)
		}
		return true
	})
	info.Braces = &bracePositions
}
