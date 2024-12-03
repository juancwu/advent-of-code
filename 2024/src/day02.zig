const std = @import("std");

pub fn solvePart1(input: []const u8) !i32 {
    const allocater = std.heap.page_allocator;
    const reports = try processInput(allocater, input);
    defer {
        for (reports.items) |item| {
            item.deinit();
        }
        reports.deinit();
    }

    // need a state to know which direction we are going

    // no number starts with 0
    // smallest in the input
    // assuming that all reports have at least 2 levels
    var direction: i32 = -1;
    var count: i32 = 0;
    // loop through each line and check numbers are
    // increasing/decreasing
    for (reports.items) |report| {
        direction = checkArrayOrder(report);
        if (direction == 1 or direction == -1) {
            count += 1;
        }
    }

    return count;
}

pub fn solvePart2(input: []const u8) !i32 {
    const allocater = std.heap.page_allocator;
    const reports = try processInput(allocater, input);
    defer {
        for (reports.items) |item| {
            item.deinit();
        }
        reports.deinit();
    }

    // need a state to know which direction we are going

    // no number starts with 0
    // smallest in the input
    // assuming that all reports have at least 2 levels
    var direction: i32 = -1;
    var count: i32 = 0;
    // loop through each line and check numbers are
    // increasing/decreasing
    for (reports.items) |report| {
        direction = checkArrayOrder(report);
        if (direction == 1 or direction == -1) {
            count += 1;
        }
    }

    return count;
}

fn isValidSequence(items: []const i32, skip_index: ?usize) bool {
    var prev_index: ?usize = null;
    var inc: ?bool = null;

    var i: usize = 0;
    while (i < items.len) : (i += 1) {
        if (skip_index != null and i == skip_index.?) {
            continue;
        }
        if (prev_index != null) {
            const prev = items[prev_index.?];
            const curr = items[i];
            const diff = if (curr > prev) curr - prev else prev - curr;
            if (diff < 1 or diff > 3) {
                return false;
            }
            const is_inc = curr > prev;
            if (inc == null) {
                inc = is_inc;
            } else if (inc.? != is_inc) {
                // sudden change in direction
                return false;
            }
        }
        prev_index = i;
    }
    return true;
}

fn checkArrayOrder(list: std.ArrayList(i32)) i32 {
    if (list.items.len <= 1) return 0;

    if (isValidSequence(list.items, null)) {
        return if (list.items[0] < list.items[list.items.len - 1]) 1 else -1;
    }

    var i: usize = 1;
    while (i < list.items.len) : (i += 1) {
        if (isValidSequence(list.items, i)) {
            const first = if (i == 0) list.items[1] else list.items[0];
            const last = if (i == list.items.len - 1) list.items[list.items.len - 2] else list.items[list.items.len - 1];
            return if (first < last) 1 else -1;
        }
    }

    return 0;
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
