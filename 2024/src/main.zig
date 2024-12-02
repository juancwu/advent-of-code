const std = @import("std");
const day01 = @import("day01.zig");

const day01_input = @embedFile("inputs/01.txt");

pub fn main() !void {
    const result01_part1 = try day01.solvePart1(day01_input);
    std.debug.print("Day 01 resutl: {}\n", .{result01_part1});
}
