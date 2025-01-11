const std = @import("std");

const Data = struct {
    rules: std.AutoHashMap(u32, std.ArrayList(u32)),
    updates: std.ArrayList(std.ArrayList(u32)),
};

pub fn solvePart1(input: []const u8) !u32 {
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

    var sumOfMidNum: u32 = 0;
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
        }
    }

    return sumOfMidNum;
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
    const sum = try solvePart1(test_input);
    std.debug.print("sum: {d}\n", .{sum});
}

test "day05 solution part 1 - actual data" {
    const input = @embedFile("inputs/05.txt");
    const sum = try solvePart1(input);
    std.debug.print("sum: {d}\n", .{sum});
}
