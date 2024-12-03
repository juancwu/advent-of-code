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

fn checkArrayOrder(list: std.ArrayList(i32)) i32 {
    if (list.items.len <= 1) return 0;
    var inc = true;
    var dec = true;

    var i: usize = 1;
    while (i < list.items.len) : (i += 1) {
        const diff = if (list.items[i] > list.items[i - 1])
            list.items[i] - list.items[i - 1]
        else
            list.items[i - 1] - list.items[i];

        if (diff < 1 or diff > 3) {
            return 0;
        }

        if (list.items[i] <= list.items[i - 1]) {
            inc = false;
        }
        if (list.items[i] >= list.items[i - 1]) {
            dec = false;
        }
        if (!inc and !dec) {
            return 0;
        }
    }

    if (inc) return 1;
    if (dec) return -1;
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
