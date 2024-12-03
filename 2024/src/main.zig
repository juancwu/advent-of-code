const std = @import("std");
const day01 = @import("day01.zig");
const day02 = @import("day02.zig");

const day01_input = @embedFile("inputs/01.txt");
const day02_input = @embedFile("inputs/02.txt");

pub fn main() !void {
    const result01_part1 = try day01.solvePart1(day01_input);
    std.debug.print("Day 01 result part 1: {}\n", .{result01_part1});
    const result02_part1 = try day02.solvePart1(day02_input);
    std.debug.print("Day 02 result part 1: {}\n", .{result02_part1});
    const result02_part2 = try day02.solvePart2(day02_input);
    std.debug.print("Day 02 result part 2: {}\n", .{result02_part2});
}
