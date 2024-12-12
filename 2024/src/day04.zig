const std = @import("std");

const Data = struct {
    arr: std.ArrayList(u8),
    cols: usize,
    rows: usize,
};

const Position = struct {
    x: usize,
    y: usize,
    valid: bool,
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
    const part1 = solvePart1(data.arr.items, data.rows, data.cols);
    std.debug.print("part 1: {}\n", .{part1});
}

pub fn solvePart1(input: []const u8, rows: usize, cols: usize) u32 {
    var count: u32 = 0;

    var idx: usize = 0;
    var ch: u8 = 0;
    var sequence: [4]u8 = [4]u8{ '-', '-', '-', '-' };
    const to_match: [4]u8 = [4]u8{ 'X', 'M', 'A', 'S' };
    var pos: Position = Position{ .x = 0, .y = 0, .valid = true };
    for (0..rows) |i| {
        for (0..cols) |j| {
            idx = i * cols + j;
            ch = input[idx];
            if (ch == 'X') {
                for (directions) |dir| {
                    sequence[0] = ch;
                    pos = getPositionByDir(dir, rows, cols, i, j);
                    var k: usize = 1;
                    while (pos.valid and k < 4) : (k += 1) {
                        sequence[k] = input[pos.y * cols + pos.x];
                        // std.debug.print("d: {}, s: {s}, p: {}\n", .{ dir, sequence, pos });
                        pos = getPositionByDir(dir, rows, cols, pos.y, pos.x);
                    }
                    if (matchSequence(&sequence, &to_match)) {
                        count = count + 1;
                    }
                    for (0..4) |p| {
                        sequence[p] = '-';
                    }
                }
            }
        }
    }

    return count;
}

fn getPositionByDir(dir: Direction, rows: usize, cols: usize, row: usize, col: usize) Position {
    var pos: Position = Position{
        .x = 0,
        .y = 0,
        .valid = false,
    };

    switch (dir) {
        .Up => {
            if (row == 0) return pos;
            pos.y = row - 1;
            pos.x = col;
        },
        .Down => {
            if (row == rows - 1) return pos;
            pos.y = row + 1;
            pos.x = col;
        },
        .Left => {
            if (col == 0) return pos;
            pos.y = row;
            pos.x = col - 1;
        },
        .Right => {
            if (col == cols - 1) return pos;
            pos.y = row;
            pos.x = col + 1;
        },
        .UpRight => {
            if (row == 0 or col == cols - 1) return pos;
            pos.y = row - 1;
            pos.x = col + 1;
        },
        .UpLeft => {
            if (row == 0 or col == 0) return pos;
            pos.y = row - 1;
            pos.x = col - 1;
        },
        .DownRight => {
            if (row == rows - 1 or col == cols - 1) return pos;
            pos.y = row + 1;
            pos.x = col + 1;
        },
        .DownLeft => {
            if (row == rows - 1 or col == 0) return pos;
            pos.y = row + 1;
            pos.x = col - 1;
        },
    }

    pos.valid = true;
    return pos;
}

fn matchSequence(sequence: []u8, to_match: []const u8) bool {
    if (sequence.len != 4 or to_match.len != 4 or sequence.len != to_match.len) return false;

    for (0..4) |i| {
        if (sequence[i] != to_match[i]) return false;
    }

    return true;
}

fn isInBound(rows: usize, cols: usize, row: usize, col: usize) bool {
    return 0 <= row and row < rows and 0 <= col and col < cols;
}

fn processInput(allocator: std.mem.Allocator, input: []const u8) !Data {
    var data = std.ArrayList(u8).init(allocator);
    var rows: usize = 1;
    var cols: usize = 0;
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
    if (rows > 140) {
        rows -= 1;
        try data.resize(rows * cols);
        std.debug.print("A: {}, r: {}, c: {}, l: {}\n", .{ rows * cols, rows, cols, data.items.len });
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
    const count = solvePart1(data.arr.items, data.rows, data.cols);
    try std.testing.expectEqual(18, count);
}
