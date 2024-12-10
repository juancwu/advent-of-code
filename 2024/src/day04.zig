const std = @import("std");

const Data = struct {
    arr: std.ArrayList(u8),
    cols: isize,
    rows: isize,
};

// Direction struct to represent movement in the grid
const Direction = enum {
    Up,
    Down,
    Right,
    Left,
    UpRight,
    UpLeft,
    DownRight,
    DownLeft,
};

const Position = struct {
    x: isize,
    y: isize,
};

const directions: [8]Direction = [8]Direction{
    .Up,
    .Down,
    .Right,
    .Left,
    .UpRight,
    .UpLeft,
    .DownRight,
    .DownLeft,
};

pub fn main() !void {
    const input = @embedFile("inputs/04.txt");
    const allocator = std.heap.page_allocator;
    const data = try processInput(allocator, input);
    defer data.arr.deinit();
    const count = findXmasSequences(data);
    std.debug.print("xmas count: {}\n", .{count});
}

pub fn findXmasSequences(data: Data) !u32 {
    // a word can only count if its all in one direction.
    var count: u32 = 0;

    var idx: isize = 0;
    var c: u8 = 0;
    var i: isize = 0;
    var j: isize = 0;
    while (i < data.rows) : (i += 1) {
        j = 0;
        while (j < data.cols) : (j += 1) {
            idx = i * data.cols + j;
            c = data.arr.items[@as(usize, @intCast(idx))];
            if (c == 'X') {
                // look at all 8 directions
                for (directions) |dir| {
                    var k: isize = 1;
                    var position: Position = getNewPosition(i, j, dir);
                    var is_correct = true;
                    while (k < 4 and isInBound(data.rows, data.cols, position.y, position.x) and is_correct) : (k += 1) {
                        std.debug.print("k: {}\n", .{k});
                        const index: isize = position.y * data.cols + position.x;
                        is_correct = isExpectedChar(k, data.arr.items[@as(usize, @intCast(index))]);
                        position = getNewPosition(position.y, position.x, dir);
                    }
                    if (is_correct) {
                        count += 1;
                    }
                }
            }
        }
    }

    return count;
}

fn getNewPosition(row: isize, col: isize, dir: Direction) Position {
    switch (dir) {
        .Up => {
            return Position{
                .x = col,
                .y = row - 1,
            };
        },
        .Down => {
            return Position{
                .x = col,
                .y = row + 1,
            };
        },
        .Right => {
            return Position{
                .x = col + 1,
                .y = row,
            };
        },
        .Left => {
            return Position{
                .x = col - 1,
                .y = row,
            };
        },
        .UpRight => {
            return Position{
                .x = col + 1,
                .y = row - 1,
            };
        },
        .UpLeft => {
            return Position{
                .x = col - 1,
                .y = row - 1,
            };
        },
        .DownRight => {
            return Position{
                .x = col + 1,
                .y = row + 1,
            };
        },
        .DownLeft => {
            return Position{
                .x = col - 1,
                .y = row + 1,
            };
        },
    }
}

fn isExpectedChar(k: isize, char: u8) bool {
    if (k == 1 and char == 'M') return true;
    if (k == 2 and char == 'A') return true;
    if (k == 3 and char == 'S') return true;
    return false;
}

fn isInBound(rows: isize, cols: isize, row: isize, col: isize) bool {
    return 0 <= row and row < rows and 0 <= col and col < cols;
}

fn processInput(allocator: std.mem.Allocator, input: []const u8) !Data {
    var data = std.ArrayList(u8).init(allocator);
    var rows: isize = 1;
    var cols: isize = 0;
    var stop_counting_cols: bool = false;

    for (input) |c| {
        if (c != '\n') {
            try data.append(c);
            if (!stop_counting_cols) cols += 1;
        } else {
            rows += 1;
            stop_counting_cols = true;
        }
    }

    // adjust for trainling newline
    if (input.len > 0 and input[input.len - 1] == '\n') {
        rows -= 1;
    }

    return Data{
        .arr = data,
        .cols = cols,
        .rows = rows,
    };
}

test "Day 04 part 1" {
    const input =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;
    const allocator = std.heap.page_allocator;
    const data = try processInput(allocator, input);
    defer data.arr.deinit();
    const count = try findXmasSequences(data);
    try std.testing.expectEqual(18, count);
}
