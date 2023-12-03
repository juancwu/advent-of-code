package day1 

import (
    "fmt"
    _ "embed"
)

//go:embed day1.txt
var input string

func Day1() {
    floor := 0
    position := -1
    for i := 0; i < len(input); i++ {
        c := input[i]
        if c == '(' {
            floor++
        } else if c == ')' {
            floor--
            if position == -1 && floor == -1 {
                position = i + 1
            }
        }
    }

    fmt.Printf("Floor: %d\n", floor)
    fmt.Printf("Position: %d\n", position)
}
