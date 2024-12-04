const std = @import("std");

const State = enum {
    Start,
    AfterM,
    AfterU,
    AfterL,
    AfterOpenParen,
    InFirstNumber,
    AfterComma,
    InSecondNumber,
};

const StatePart2 = enum {
    Start,
    AfterM,
    AfterU,
    AfterL,
    AfterOpenParen,
    InFirstNumber,
    AfterComma,
    InSecondNumber,
    AfterD,
    AfterO,
    AfterN,
    AfterTilt,
    AfterT,
};

pub fn main() !void {
    const input = @embedFile("inputs/03.txt");
    const sum = try solvePart1(input);
    std.debug.print("Sum: {}\n", .{sum});
    std.debug.print("Sum: {}\n", .{try solvePart2(input)});
}

pub fn solvePart1(input: []const u8) !i32 {
    var state: State = State.Start;
    var sum: i32 = 0;
    var n: i32 = 0;
    var m: i32 = 0;
    var num_start: usize = 0;
    var num_end: usize = 0;

    for (input, 0..) |c, i| {
        switch (state) {
            .Start => {
                if (c == 'm') {
                    state = .AfterM;
                } else {
                    state = .Start;
                }
            },
            .AfterM => {
                if (c == 'u') {
                    state = .AfterU;
                } else {
                    state = .Start;
                }
            },
            .AfterU => {
                if (c == 'l') {
                    state = .AfterL;
                } else {
                    state = .Start;
                }
            },
            .AfterL => {
                if (c == '(') {
                    state = .AfterOpenParen;
                } else {
                    state = .Start;
                }
            },
            .AfterOpenParen => {
                if (std.ascii.isDigit(c)) {
                    state = .InFirstNumber;
                    num_start = i;
                    num_end = i + 1;
                } else {
                    state = .Start;
                }
            },
            .InFirstNumber => {
                if (std.ascii.isDigit(c) and num_end - num_start < 4) {
                    num_end = i + 1;
                } else if (c == ',') {
                    state = .AfterComma;
                    // parse the integer read
                    n = try std.fmt.parseInt(i32, input[num_start..num_end], 10);
                } else {
                    state = .Start;
                }
            },
            .AfterComma => {
                if (std.ascii.isDigit(c)) {
                    state = .InSecondNumber;
                    num_start = i;
                    num_end = i + 1;
                } else {
                    state = .Start;
                }
            },
            .InSecondNumber => {
                if (std.ascii.isDigit(c) and num_end - num_start < 4) {
                    num_end = i + 1;
                } else if (c == ')') {
                    // parse the integer read
                    m = try std.fmt.parseInt(i32, input[num_start..num_end], 10);

                    // multiply and add the product to total sum
                    sum += n * m;

                    // reset state
                    state = .Start;
                } else {
                    state = .Start;
                }
            },
        }
    }

    return sum;
}

pub fn solvePart2(input: []const u8) !i32 {
    var prev_state: StatePart2 = StatePart2.Start;
    var state: StatePart2 = StatePart2.Start;
    var sum: i32 = 0;
    var n: i32 = 0;
    var m: i32 = 0;
    var num_start: usize = 0;
    var num_end: usize = 0;
    var enabled: bool = true;

    for (input, 0..) |c, i| {
        switch (state) {
            .Start => {
                prev_state = state;
                switch (c) {
                    'm' => state = .AfterM,
                    'd' => state = .AfterD,
                    else => state = .Start,
                }
            },
            .AfterD => {
                prev_state = state;
                if (c == 'o') {
                    state = StatePart2.AfterO;
                } else {
                    state = .Start;
                }
            },
            .AfterO => {
                prev_state = state;
                switch (c) {
                    '(' => {
                        state = .AfterOpenParen;
                    },
                    'n' => state = .AfterN,
                    else => state = .Start,
                }
            },
            .AfterN => {
                prev_state = state;
                switch (c) {
                    '\'' => state = .AfterTilt,
                    else => state = .Start,
                }
            },
            .AfterTilt => {
                prev_state = state;
                switch (c) {
                    't' => state = .AfterT,
                    else => state = .Start,
                }
            },
            .AfterT => {
                prev_state = state;
                switch (c) {
                    '(' => state = .AfterOpenParen,
                    else => state = .Start,
                }
            },
            .AfterM => {
                prev_state = state;
                if (c == 'u') {
                    state = .AfterU;
                } else {
                    state = .Start;
                }
            },
            .AfterU => {
                prev_state = state;
                if (c == 'l') {
                    state = .AfterL;
                } else {
                    state = .Start;
                }
            },
            .AfterL => {
                prev_state = state;
                if (c == '(') {
                    state = .AfterOpenParen;
                } else {
                    state = .Start;
                }
            },
            .AfterOpenParen => {
                if (c == ')' and prev_state == StatePart2.AfterO) {
                    enabled = true;
                    state = .Start;
                    prev_state = .Start;
                } else if (c == ')' and prev_state == StatePart2.AfterT) {
                    enabled = false;
                    state = .Start;
                    prev_state = .Start;
                } else if (std.ascii.isDigit(c) and prev_state == StatePart2.AfterL) {
                    state = .InFirstNumber;
                    num_start = i;
                    num_end = i + 1;
                } else {
                    state = .Start;
                }
            },
            .InFirstNumber => {
                prev_state = state;
                if (std.ascii.isDigit(c) and num_end - num_start < 4) {
                    num_end = i + 1;
                } else if (c == ',') {
                    state = .AfterComma;
                    // parse the integer read
                    n = try std.fmt.parseInt(i32, input[num_start..num_end], 10);
                } else {
                    state = .Start;
                }
            },
            .AfterComma => {
                prev_state = state;
                if (std.ascii.isDigit(c)) {
                    state = .InSecondNumber;
                    num_start = i;
                    num_end = i + 1;
                } else {
                    state = .Start;
                }
            },
            .InSecondNumber => {
                prev_state = state;
                if (std.ascii.isDigit(c) and num_end - num_start < 4) {
                    num_end = i + 1;
                } else if (c == ')') {
                    // parse the integer read
                    m = try std.fmt.parseInt(i32, input[num_start..num_end], 10);

                    // multiply and add the product to total sum
                    if (enabled) sum += n * m;

                    // reset state
                    state = .Start;
                    prev_state = .Start;
                } else {
                    state = .Start;
                }
            },
        }
    }

    return sum;
}

test "Day 03 part 1" {
    const input: []const u8 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";

    const sum = try solvePart1(input);

    try std.testing.expectEqual(@as(i32, 161), sum);
}

test "Day 03 part 2" {
    const input: []const u8 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

    const sum = try solvePart2(input);

    try std.testing.expectEqual(@as(i32, 48), sum);
}
