const std = @import("std");

const Data = struct {
    rules: std.AutoHashMap(u32, std.ArrayList(u32)),
    updates: std.ArrayList(std.ArrayList(u32)),
};

const Part1Result = struct {
    sum: u32,
    invalids: std.ArrayList(std.ArrayList(u32)),
};

pub fn solvePart1(allocator: std.mem.Allocator, data: Data) !Part1Result {
    var sumOfMidNum: u32 = 0;
    var invalids: std.ArrayList(std.ArrayList(u32)) = std.ArrayList(std.ArrayList(u32)).init(allocator);
    for (data.updates.items) |list| {
        var is_valid = true;
        var seen = std.AutoHashMap(u32, void).init(allocator);
        defer seen.deinit();

        for (list.items) |num| {
            try seen.put(num, {});
            if (data.rules.get(num)) |num2s| {
                for (num2s.items) |num2| {
                    if (seen.contains(num2)) {
                        is_valid = false;
                        break;
                    }
                }
            }
            if (!is_valid) break;
        }

        // get the middle number
        if (is_valid) {
            const mid_idx = list.items.len / 2;
            sumOfMidNum += list.items[mid_idx];
        } else {
            var list_clone: std.ArrayList(u32) = std.ArrayList(u32).init(allocator);
            for (list.items) |num| {
                try list_clone.append(num);
            }
            try invalids.append(list_clone);
        }
    }

    return Part1Result{
        .sum = sumOfMidNum,
        .invalids = invalids,
    };
}

const Part2Result = struct {
    sum: u32,
};

pub fn solvePart2(allocator: std.mem.Allocator, data: Data, part1: Part1Result) !Part2Result {
    // go over the invalid lists
    var sum: u32 = 0;
    for (part1.invalids.items) |list| {
        const fixed = try fixSequence(allocator, data.rules, list);
        defer fixed.deinit();
        const mid_idx = fixed.items.len / 2;
        sum += fixed.items[mid_idx];
    }

    return Part2Result{ .sum = sum };
}

fn fixSequence(
    allocator: std.mem.Allocator,
    rules: std.AutoHashMap(u32, std.ArrayList(u32)),
    sequence: std.ArrayList(u32),
) !std.ArrayList(u32) {
    var fixed = std.ArrayList(u32).init(allocator);
    errdefer fixed.deinit();

    for (sequence.items) |num| {
        try fixed.append(num);
    }

    var i: usize = 1;
    while (i < fixed.items.len) : (i += 1) {
        const current = fixed.items[i];
        var j = i;

        while (j > 0) {
            const prev = fixed.items[j - 1];

            var must_swap = false;
            if (rules.get(prev)) |rule| {
                for (rule.items) |after| {
                    if (after == current) {
                        must_swap = true;
                        break;
                    }
                }
            }

            if (!must_swap) {
                break;
            }

            fixed.items[j] = prev;
            fixed.items[j - 1] = current;
            j -= 1;
        }
    }

    return fixed;
}

fn processInput(allocator: std.mem.Allocator, input: []const u8) !Data {
    var map = std.AutoHashMap(u32, std.ArrayList(u32)).init(allocator);
    errdefer {
        var it = map.valueIterator();
        while (it.next()) |list| {
            list.deinit();
        }
        map.deinit();
    }

    var updates = std.ArrayList(std.ArrayList(u32)).init(allocator);
    errdefer {
        for (updates.items) |list| {
            list.deinit();
        }
        updates.deinit();
    }

    var parsing_rules = true;
    var it = std.mem.split(u8, input, "\n");
    while (it.next()) |line| {
        if (line.len == 0) {
            parsing_rules = false;
            continue;
        }

        if (parsing_rules) {
            var parts = std.mem.split(u8, line, "|");
            const num1_str = parts.next() orelse continue;
            const num2_str = parts.next() orelse continue;

            const num1 = try std.fmt.parseInt(u32, num1_str, 10);
            const num2 = try std.fmt.parseInt(u32, num2_str, 10);

            var entry = try map.getOrPut(num1);
            if (!entry.found_existing) {
                entry.value_ptr.* = std.ArrayList(u32).init(allocator);
            }

            try entry.value_ptr.append(num2);
        } else {
            var number_list = std.ArrayList(u32).init(allocator);
            errdefer number_list.deinit();
            var parts = std.mem.split(u8, line, ",");
            while (parts.next()) |num_str| {
                const num = try std.fmt.parseInt(u32, num_str, 10);
                try number_list.append(num);
            }
            try updates.append(number_list);
        }
    }

    return Data{
        .rules = map,
        .updates = updates,
    };
}

test "day05 solution part 1 - test data" {
    const test_input =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var data = try processInput(allocator, test_input);
    defer {
        var it = data.rules.valueIterator();
        while (it.next()) |list| {
            list.deinit();
        }
        data.rules.deinit();
        for (data.updates.items) |list| {
            list.deinit();
        }
        data.updates.deinit();
    }
    const result = try solvePart1(allocator, data);
    defer {
        for (result.invalids.items) |list| {
            list.deinit();
        }
        result.invalids.deinit();
    }
    std.debug.print("sum: {d}\n", .{result.sum});
}

test "day05 solution part 1 - actual data" {
    const input = @embedFile("inputs/05.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var data = try processInput(allocator, input);
    defer {
        var it = data.rules.valueIterator();
        while (it.next()) |list| {
            list.deinit();
        }
        data.rules.deinit();
        for (data.updates.items) |list| {
            list.deinit();
        }
        data.updates.deinit();
    }
    const result = try solvePart1(allocator, data);
    defer {
        for (result.invalids.items) |list| {
            list.deinit();
        }
        result.invalids.deinit();
    }
    std.debug.print("sum: {d}\n", .{result.sum});
}

test "day05 solution part 2 - test data" {
    const test_input =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var data = try processInput(allocator, test_input);
    defer {
        var it = data.rules.valueIterator();
        while (it.next()) |list| {
            list.deinit();
        }
        data.rules.deinit();
        for (data.updates.items) |list| {
            list.deinit();
        }
        data.updates.deinit();
    }
    const result = try solvePart1(allocator, data);
    defer {
        for (result.invalids.items) |list| {
            list.deinit();
        }
        result.invalids.deinit();
    }
    const part2 = try solvePart2(allocator, data, result);
    std.debug.print("sum: {d}\n", .{part2.sum});
}

test "day05 solution part 2 - actual data" {
    const input = @embedFile("inputs/05.txt");
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var data = try processInput(allocator, input);
    defer {
        var it = data.rules.valueIterator();
        while (it.next()) |list| {
            list.deinit();
        }
        data.rules.deinit();
        for (data.updates.items) |list| {
            list.deinit();
        }
        data.updates.deinit();
    }
    const result = try solvePart1(allocator, data);
    defer {
        for (result.invalids.items) |list| {
            list.deinit();
        }
        result.invalids.deinit();
    }
    const part2 = try solvePart2(allocator, data, result);
    std.debug.print("sum: {d}\n", .{part2.sum});
}
