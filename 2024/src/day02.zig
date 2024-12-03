const std = @import("std");

pub fn main() !void {
    const input = @embedFile("inputs/02.txt");
    const result_part1 = try solvePart1(input);
    std.debug.print("Day 02 result part 1: {}\n", .{result_part1});
    const result_part2 = try solvePart2(input);
    std.debug.print("Day 02 result part 2: {}\n", .{result_part2});
}

pub fn solvePart1(input: []const u8) !i32 {
    const allocator = std.heap.page_allocator;
    const reports = try processInput(allocator, input);
    defer {
        for (reports.items) |item| {
            item.deinit();
        }
        reports.deinit();
    }

    var count: i32 = 0;
    for (reports.items) |report| {
        if (isValidSequence(report.items, null)) {
            count += 1;
        }
    }

    return count;
}

pub fn solvePart2(input: []const u8) !i32 {
    const allocator = std.heap.page_allocator;
    const reports = try processInput(allocator, input);
    defer {
        for (reports.items) |item| {
            item.deinit();
        }
        reports.deinit();
    }

    var count: i32 = 0;
    for (reports.items) |report| {
        // check without removing numbers
        if (isValidSequence(report.items, null)) {
            count += 1;
            continue;
        }

        var i: usize = 0;
        var found_valid = false;
        while (i < report.items.len and !found_valid) : (i += 1) {
            if (isValidSequence(report.items, i)) {
                count += 1;
                found_valid = true;
            }
        }
    }

    return count;
}

fn isValidSequence(items: []const i32, skip_index: ?usize) bool {
    if (items.len <= 1) return true;

    var filtered_items = std.ArrayList(i32).init(std.heap.page_allocator);
    defer filtered_items.deinit();

    for (items, 0..) |item, i| {
        if (skip_index != null and i == skip_index.?) {
            continue;
        }
        filtered_items.append(item) catch return false;
    }

    const list = filtered_items.items;
    if (list.len < 2) return true;

    const first_diff = list[1] - list[0];
    if (first_diff == 0) return false;
    const is_increasing = first_diff > 0;

    var i: usize = 0;
    while (i < list.len - 1) : (i += 1) {
        const diff = list[i + 1] - list[i];

        if (is_increasing and diff <= 0) return false;
        if (!is_increasing and diff >= 0) return false;

        if (@abs(diff) < 1 or @abs(diff) > 3) return false;
    }

    return true;
}

fn processInput(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(std.ArrayList(i32)) {
    var reports = std.ArrayList(std.ArrayList(i32)).init(allocator);

    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        var converted = std.ArrayList(i32).init(allocator);
        var nums = std.mem.tokenize(u8, line, " ");
        while (nums.next()) |num| {
            try converted.append(try std.fmt.parseInt(i32, num, 10));
        }
        try reports.append(converted);
    }

    return reports;
}

test "day02 part 1 - test data" {
    const test_input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;
    const result = try solvePart1(test_input);
    try std.testing.expectEqual(@as(i32, 2), result);
}

test "day02 part 2 - test data" {
    const test_input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;
    const result = try solvePart2(test_input);
    try std.testing.expectEqual(@as(i32, 4), result);
}
