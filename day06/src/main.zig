const std = @import("std");
const readline = @import("readline");

const Part1 = struct {
    cycle_bins: [9]u64,
};

const PartType = enum(u1) {
    part_one,
    part_two,
};

fn partn_parser(comptime part_type: PartType, line: []u8, p1: *Part1) anyerror!void {
    var iter = std.mem.tokenize(line, ",");

    while (iter.next()) |num_str| {
        var idx = try std.fmt.parseUnsigned(u8, num_str, 10);
        p1.cycle_bins[idx] += 1;
    }

    var days: u16 = 0;
    const total_days: comptime u16 = switch (part_type) {
        .part_one => 80,
        .part_two => 256,
    };
    while (days < total_days) : (days += 1) {
        std.mem.rotate(u64, &p1.cycle_bins, 1);
        p1.cycle_bins[6] += p1.cycle_bins[8];
    }
}

fn part1_parser(line: []u8, p1: *Part1) anyerror!void {
    try partn_parser(PartType.part_one, line, p1);
}

fn part2_parser(line: []u8, p1: *Part1) anyerror!void {
    try partn_parser(PartType.part_two, line, p1);
}

fn partn(comptime part_type: PartType) anyerror!void {
    var p1 = Part1 {
        .cycle_bins = [_]u64{0} ** 9,
    };

    var parser = switch (part_type) {.part_one => part1_parser, .part_two => part2_parser};

    try readline.parse_file_line_by_line(Part1, "input.txt", parser, &p1);

    var accum: u64 = 0;
    for (p1.cycle_bins) |cycle| {
        accum += cycle;
    }

    std.debug.print("fish count: {}\n", .{accum});
}

fn part1() anyerror!void {
    try partn(PartType.part_one);
}

fn part2() anyerror!void {
    try partn(PartType.part_two);
}

pub fn main() anyerror!void {
    std.debug.print("Part 1\n------\n", .{});
    try part1();
    std.debug.print("Part 2\n------\n", .{});
    try part2();
}

// final-comment: not much to say here.  nice clean implementation 
