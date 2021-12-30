const std = @import("std");
const readline = @import("readline");

const Part1 = struct {
    x: u32,
    y: u32,
};

const Keyword = enum(usize) {
    forward = 7,
    down = 4,
    up = 2,
    _,
};

fn part1_parser(line: []u8, p1: *Part1) anyerror!void {
    var iter = std.mem.split(line, " ");
    if (iter.next()) |keyword| {
        var movement = try std.fmt.parseUnsigned(u32, iter.next() orelse "0", 10);
        switch (@intToEnum(Keyword, keyword.len)) {
            Keyword.forward => {p1.x += movement;},
            Keyword.down => {p1.y += movement;},
            Keyword.up => {p1.y -= movement;},
            else => {},
        }
    }
}

fn part1() anyerror!void {
    var p1 = Part1 {.x = 0, .y = 0};
    try readline.parse_file_line_by_line(Part1, "input.txt", part1_parser, &p1);
    std.debug.print("Dims: {} x {}\nArea: {}\n\n", .{p1.x, p1.y, p1.x * p1.y}); 
}

const Part2 = struct {
    x: u32,
    y: u32,
    aim: u32,
};

fn part2_parser(line: []u8, p2: *Part2) anyerror!void {
    var iter = std.mem.split(line, " ");
    if (iter.next()) |keyword| {
        var movement = try std.fmt.parseUnsigned(u32, iter.next() orelse "0", 10);
        switch(@intToEnum(Keyword, keyword.len)) {
            Keyword.forward => {p2.x += movement; p2.y += p2.aim * movement;},
            Keyword.down => {p2.aim += movement;},
            Keyword.up => {p2.aim -= movement;},
            else => {},
        }
    }
}

fn part2() anyerror!void {
    var p2 = Part2 {
        .x = 0,
        .y = 0,
        .aim = 0,
    };
    try readline.parse_file_line_by_line(Part2, "input.txt", part2_parser, &p2);
    std.debug.print("Dims: {} x {}\nArea: {}\n\n", .{p2.x, p2.y, p2.x * p2.y});
}

pub fn main() anyerror!void {
    std.debug.print("Part 1\n------\n", .{});
    try part1();
    std.debug.print("Part 2\n------\n", .{});
    try part2();
}
