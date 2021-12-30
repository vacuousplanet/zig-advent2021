const std = @import("std");
const readline = @import("readline");

const Part1 = struct {
    prev: u32,
    count: u32,
};

fn part1_parser(line: []u8, p1: *Part1) anyerror!void {
    var parsed_entry = try std.fmt.parseUnsigned(u32, line, 10);
    if (parsed_entry > p1.prev) {
        p1.count += 1;
    }
    p1.prev = parsed_entry;
}

fn part1() anyerror!void {
    var p1 = Part1 {.prev = 0, .count = 0};
    try readline.parse_file_line_by_line(Part1, "input.txt", part1_parser, &p1);
    std.debug.print("Part 1 (refactor): {}\n\n", .{p1.count - 1}); 
}

fn sum(window: []u32) u32 {
    var accum: u32 = 0;
    for (window) |num| {
        accum += num;
    }
    return accum;
}

const Part2 = struct {
    window: [4]u32,
    idx: u32,
    count: u32,
};

fn part2_parser(line: []u8, p2: *Part2) anyerror!void {
    defer {p2.idx += 1;}
    var parsed_entry = try std.fmt.parseUnsigned(u32, line, 10);
    if (p2.idx < 3) {
        p2.window[p2.idx] = parsed_entry;
        return;
    } else {
        std.mem.rotate(u32, &p2.window, 1);
        p2.window[3] = parsed_entry;
    }
    var left_sum = sum(p2.window[0..3]);
    var right_sum = sum(p2.window[1..4]);

    p2.count += @boolToInt(right_sum > left_sum);
}

fn part2() anyerror!void {
    var p2 = Part2 {
        .window = [4]u32{0, 0, 0, 0},
        .idx = 0,
        .count = 0
    };
    try readline.parse_file_line_by_line(Part2, "input.txt", part2_parser, &p2);
    std.debug.print("Part 2 (refactor): {}\n\n", .{p2.count});
}

pub fn main() anyerror!void {
    std.debug.print("Part 1\n------\n", .{});
    try part1();
    std.debug.print("Part 2\n------\n", .{});
    try part2();
}
