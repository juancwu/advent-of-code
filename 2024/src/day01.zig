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

pub fn solvePart2(input: []const u8) !i32 {
    const allocater = std.heap.page_allocator;
    const pairs = try processInput(allocater, input);
    defer pairs.first_nums.deinit();
    defer pairs.second_nums.deinit();

    // create a hash map to count the appearance of each
    // number in the right list
    var count_hash = std.AutoHashMap(i32, i32).init(allocater);
    defer count_hash.deinit();
    for (pairs.second_nums.items) |num| {
        const count = count_hash.get(num);
        if (count == null) {
            try count_hash.put(num, 1);
        } else {
            try count_hash.put(num, count.? + 1);
        }
    }

    // go through the left list and multiply by the count
    var sum: i32 = 0;
    for (pairs.first_nums.items) |num| {
        const count = count_hash.get(num);
        if (count == null) {
            continue;
        } else {
            sum += num * count.?;
        }
    }

    return sum;
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

test "day01 solution part 2 - test data" {
    const test_input =
        \\3 4
        \\4 3
        \\2 5
        \\1 3
        \\3 9
        \\3 3
    ;
    const result = try solvePart2(test_input);
    try std.testing.expectEqual(@as(i32, 31), result);
    std.debug.print("Result: {}\n", .{result});
}

test "day01 solution part 2- actual data" {
    const input = @embedFile("inputs/01.txt");
    const result = try solvePart2(input);
    std.debug.print("Result: {}\n", .{result});
}
