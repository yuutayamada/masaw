package masaw

import (
	"go/ast"
	"go/parser"
	"go/token"
)

type Info struct {
	File   string
	Braces *[]Brace
}

type Brace struct {
	LBrace *Position
	RBrace *Position
}

type Position struct {
	Line   int // height from above
	Column int // width from left
}

var bracePositions []Brace

func GetPositions(filename, src string) *[]Brace {
	fset := token.NewFileSet()
	f, err := parser.ParseFile(fset, filename, nil, 0)
	if err != nil {
		panic(err)
	}
	Inspect(f, fset)
	return &bracePositions
}

func Inspect(f ast.Node, fset *token.FileSet) {
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
}
