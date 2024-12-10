package main

import (
	_ "embed"
	"fmt"
	"strings"
)

const testInput = `MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX`

//go:embed 04.txt
var input string

var directions = [8][2]int{
	{0, 1},   // right
	{0, -1},  // left
	{1, 0},   // down
	{-1, 0},  // up
	{-1, 1},  // up-right
	{-1, -1}, // up-left
	{1, 1},   // down-right
	{1, -1},  // down-left
}

var diagonals = [4][2]int{
	{-1, 1},  // up-right
	{-1, -1}, // up-left
	{1, 1},   // down-right
	{1, -1},  // down-left
}

var expectedLetter = [4]byte{
	'M',
	'M',
	'S',
	'S',
}

func main() {
	grid := processInput(input)
	count := solvePart2(grid)
	fmt.Println(count)
}

func solvePart1(grid [][]byte) int {
	count := 0

	for i, row := range grid {
		for j, ch := range row {
			if ch == 'X' {
				for _, dir := range directions {
					seq := "X"
					r := i + dir[0]
					c := j + dir[1]
					for len(seq) < 4 && isValidCoord(len(grid), len(row), r, c) {
						seq = seq + string(grid[r][c])
						r = r + dir[0]
						c = c + dir[1]
					}
					if seq == "XMAS" {
						count += 1
					}
				}
			}
		}
	}

	return count
}

func solvePart2(grid [][]byte) int {
	count := 0
	rows := len(grid)
	cols := len(grid[0])

	for i, row := range grid {
		for j, ch := range row {
			// found center point of cross, now check for a valid cross
			if ch == 'A' {
				// make sure that all four diagonals are not A or X
				upRightRow := i + diagonals[0][0]
				upRightCol := j + diagonals[0][1]
				if !isValidCoord(rows, cols, upRightRow, upRightCol) || grid[upRightRow][upRightCol] == 'A' || grid[upRightRow][upRightCol] == 'X' {
					continue
				}

				upLeftRow := i + diagonals[1][0]
				upLeftCol := j + diagonals[1][1]
				if !isValidCoord(rows, cols, upLeftRow, upLeftCol) || grid[upLeftRow][upLeftCol] == 'A' || grid[upLeftRow][upLeftCol] == 'X' {
					continue
				}

				downRightRow := i + diagonals[2][0]
				downRightCol := j + diagonals[2][1]
				if !isValidCoord(rows, cols, downRightRow, downRightCol) || grid[downRightRow][downRightCol] == 'A' || grid[downRightRow][downRightCol] == 'X' {
					continue
				}

				downLeftRow := i + diagonals[3][0]
				downLeftCol := j + diagonals[3][1]
				if !isValidCoord(rows, cols, downLeftRow, downLeftCol) || grid[downLeftRow][downLeftCol] == 'A' || grid[downLeftRow][downLeftCol] == 'X' {
					continue
				}

				// make sure that diagonals are different
				if grid[upRightRow][upRightCol] == grid[downLeftRow][downLeftCol] {
					continue
				}

				if grid[upLeftRow][upLeftCol] == grid[downRightRow][downRightCol] {
					continue
				}

				count += 1
			}
		}
	}

	return count
}

func isValidCoord(rows, cols, r, c int) bool {
	return 0 <= r && r < rows && 0 <= c && c < cols
}

func processInput(input string) [][]byte {
	rows := strings.Split(input, "\n")
	if len(rows) == 141 {
		rows = rows[:140]
	}
	var grid = make([][]byte, len(rows))
	for i, row := range rows {
		grid[i] = []byte(row)
	}
	return grid
}
