const std = @import("std");
const readline = @import("readline");

const Part1 = struct {
    positions: std.ArrayList(u16),
    fuel_cost: i32,
};

const PartType = enum(u1) {
    part_one,
    part_two,
};

fn partn_parser(comptime part_type: PartType, line: []u8, p1: *Part1) anyerror!void {
    var iter = std.mem.tokenize(line, ",");

    while (iter.next()) |num_str| {
        var pos = try std.fmt.parseUnsigned(u16, num_str, 10);
        try p1.positions.append(pos);
    }

    switch (part_type) {
        .part_one => {
            std.sort.sort(u16, p1.positions.items, {}, comptime std.sort.asc(u16));
            const median_idx = p1.positions.items.len / 2;
            const median_val: i32 = p1.positions.items[median_idx];

            var accum: i32 = 0;
            for (p1.positions.items) |pos_sorted| {
                accum += try std.math.absInt(median_val - pos_sorted);
            }
            p1.fuel_cost = accum;
        },
        .part_two => {
            var mean: f32 = 0.0;
            for (p1.positions.items) |pos, i| {
                var idx_float: f32 = @intToFloat(f32, i);
                mean = (mean * idx_float + @intToFloat(f32, pos)) / (idx_float + 1.0);
            }

            // you can show that the problem can be solved with the mean +/- 1, so we can just check that range
            var mean_int: i32 = @floatToInt(i32, @round(mean));
            var mean_window = [3]i32{mean_int - 1, mean_int, mean_int + 1};

            var accum = [_]i32{0} ** 3;
            for (p1.positions.items) |pos| {
                for (mean_window) |check, i| {
                    var diff: i32 = try std.math.absInt(check - pos);
                    accum[i] += @divFloor(diff * (diff + 1), 2);
                }
            }

            p1.fuel_cost = std.math.min3(accum[0], accum[1], accum[2]);
        },
    }
}

fn part1_parser(line: []u8, p1: *Part1) anyerror!void {
    try partn_parser(PartType.part_one, line, p1);
}

fn part2_parser(line: []u8, p1: *Part1) anyerror!void {
    try partn_parser(PartType.part_two, line, p1);
}

fn partn(comptime part_type: PartType) anyerror!void {

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leak = gpa.deinit();
    }

    var p1 = Part1 {
        .positions = std.ArrayList(u16).init(&gpa.allocator),
        .fuel_cost = 0,
    };
    defer p1.positions.deinit();

    var parser = switch (part_type) {.part_one => part1_parser, .part_two => part2_parser};

    try readline.parse_file_line_by_line(Part1, "input.txt", parser, &p1);

    std.debug.print("fuel cost: {}\n", .{p1.fuel_cost});
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

// not bad, although it seems just looping through and checking isn't too expensive 
