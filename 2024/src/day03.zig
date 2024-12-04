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

pub fn main() !void {
    const input = @embedFile("inputs/03.txt");
    const sum = try solvePart1(input);
    std.debug.print("Sum: {}\n", .{sum});
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

test "Day 03 part 1" {
    const input: []const u8 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";

    const sum = try solvePart1(input);

    try std.testing.expectEqual(@as(i32, 161), sum);
}
