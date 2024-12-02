const std = @import("std");

const NumberPairs = struct {
    first_nums: std.ArrayList(i32),
    second_nums: std.ArrayList(i32),
};

pub fn solvePart1(input: []const u8) !i32 {
    const allocater = std.heap.page_allocator;
    const pairs = try processInput(allocater, input);
    defer pairs.first_nums.deinit();
    defer pairs.second_nums.deinit();

    var total_distance: i32 = 0;
    var difference: i32 = 0;
    for (pairs.first_nums.items, pairs.second_nums.items) |first, second| {
        difference = first - second;
        if (difference < 0) difference = difference * -1;
        total_distance = total_distance + difference;
    }

    return total_distance;
}

fn processInput(allocator: std.mem.Allocator, input: []const u8) !NumberPairs {
    var first_nums = std.ArrayList(i32).init(allocator);
    var second_nums = std.ArrayList(i32).init(allocator);

    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        var nums = std.mem.tokenize(u8, line, " ");

        const first = nums.next().?;
        try first_nums.append(try std.fmt.parseInt(i32, first, 10));

        const second = nums.next().?;
        try second_nums.append(try std.fmt.parseInt(i32, second, 10));
    }

    std.mem.sort(i32, first_nums.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, second_nums.items, {}, comptime std.sort.asc(i32));

    return NumberPairs{
        .first_nums = first_nums,
        .second_nums = second_nums,
    };
}

test "day01 solution - test data" {
    const test_input =
        \\3 4
        \\4 3
        \\2 5
        \\1 3
        \\3 9
        \\3 3
    ;
    const result = try solvePart1(test_input);
    try std.testing.expectEqual(@as(i32, 11), result);
    std.debug.print("Result: {}\n", .{result});
}

test "day01 solution - actual data" {
    const input = @embedFile("inputs/01.txt");
    const result = try solvePart1(input);
    std.debug.print("Result: {}\n", .{result});
}
