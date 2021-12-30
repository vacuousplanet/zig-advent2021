const std = @import("std");
const readline = @import("readline");

const Part1 = struct {
    counts: [12]i32,
};

fn part1_parser(line: []u8, p1: *Part1) anyerror!void {
    for (line) |character, idx| {
        switch(character) {
            '0' => {p1.counts[idx] -= 1;},
            '1' => {p1.counts[idx] += 1;},
            else => {},
        }
    }
}

fn part1() anyerror!void {
    var p1 = Part1 {.counts = [_]i32{0} ** 12};
    try readline.parse_file_line_by_line(Part1, "input.txt", part1_parser, &p1);

    for (p1.counts) |count| {
        std.debug.print("{},",.{@boolToInt(count > 0)});
    }

    var gamma_rate = gamma : {
        var accum: u12 = 0;
        for (p1.counts) |count, i| {
            accum += @boolToInt(count > 0) * (@intCast(u12, 1) << @intCast(u4, 11 - i)); 
        }
        break :gamma accum;
    };

    var epsilon_rate = ~@as(u12, gamma_rate);

    var power_consumption: u32 = @as(u32, gamma_rate) * @as(u32, epsilon_rate);

    std.debug.print("gamma rate: {}\nepsilon rate: {}\nproduct: {}\n\n", .{gamma_rate, epsilon_rate, power_consumption}); 
}

fn find_common(val_slice: []u12, exp: u4) u1 {
    const mask: u12 = @as(u12, 0b1) << (exp - 1);
    var accum: u32 = 0;
    for (val_slice) |value| {
        accum += @boolToInt(value & mask > 0);
    }
    return @boolToInt(2 * accum >= val_slice.len);
}

fn update_idx_range(vals: *[1000]u12, start: *u32, stop: *u32, common: u1, exp: u4) void {
    const mask: u12 = @as(u12, 0b1) << (exp - 1);
    var _start: u32 = start.*;
    var _stop: u32 = stop.*;

    var start_accum: u32 = 0;
    var stop_accum: u32 = 0;
    var accum_on_start: bool = false;
    for (vals[_start.._stop]) |val, i| {
        if (@boolToInt(val & mask > 0) != common) {
            if (i == 0) {
                accum_on_start = true;
            }
            start_accum += @boolToInt(accum_on_start);
            stop_accum += @boolToInt(!accum_on_start);
        }
    }
    start.* += start_accum;
    stop.* -= stop_accum;
}

const Part2 = struct {
    values: [1000]u12,
    idx_o2: u32,
    end_o2: u32,
    idx_co2: u32,
    end_co2: u32,
    found_o2: bool,
    found_co2: bool,
};

fn part2_parser(line: []u8, p2: *Part2) anyerror!void {
    var line_val = try std.fmt.parseUnsigned(u12, line, 2);
    p2.values[p2.idx_o2] = line_val;
    p2.idx_o2 += 1;
}

fn part2() anyerror!void {

    var p2 = Part2 {
        .values = [_]u12{0} ** 1000,
        .idx_o2 = 0,
        .end_o2 = 0,
        .idx_co2 = 0,
        .end_co2 = 0,
        .found_o2 = false,
        .found_co2 = false,
    };

    // fill values and sort for nlog(n) solution
    try readline.parse_file_line_by_line(Part2, "input.txt", part2_parser, &p2);
    std.sort.sort(u12, &p2.values, {}, comptime std.sort.desc(u12));
    p2.end_o2 = p2.idx_o2;
    p2.end_co2 = p2.end_o2;
    p2.idx_o2 = 0;

    var exp: u4 = 12;
    while(!p2.found_o2 or !p2.found_co2) {

        if (!p2.found_o2) {
            //std.debug.print("O2 strt: {}\nO2 stop: {}\n\n", .{p2.idx_o2, p2.end_o2});
            var common_o2 = find_common(p2.values[p2.idx_o2..p2.end_o2], exp);
            update_idx_range(&p2.values, &p2.idx_o2, &p2.end_o2, common_o2, exp);
            p2.found_o2 = (p2.end_o2 - p2.idx_o2 == 1);
        }

        if (!p2.found_co2) {
            //std.debug.print("CO2 strt: {}\nCO2 stop: {}\n\n", .{p2.idx_co2, p2.end_co2});
            var common_co2: u1 = 0;
            var _tmp = @addWithOverflow(u1, find_common(p2.values[p2.idx_co2..p2.end_co2], exp), 1, &common_co2);
            update_idx_range(&p2.values, &p2.idx_co2, &p2.end_co2, common_co2, exp);
            p2.found_co2 = (p2.end_co2 - p2.idx_co2 == 1);
        }

        if (exp == 0) {
            unreachable;
        }
        exp -= 1;
    }

    std.debug.print("O2 rating: {}\nCO2 rating: {}\n\n", .{p2.values[p2.idx_o2], p2.values[p2.idx_co2]});
    var life_support_rating: u32 = @as(u32, p2.values[p2.idx_o2]) * @as(u32, p2.values[p2.idx_co2]);

    std.debug.print("Total rating: {}\n\n", .{life_support_rating});
}

pub fn main() anyerror!void {
    std.debug.print("Part 1\n------\n", .{});
    try part1();
    std.debug.print("Part 2\n------\n", .{});
    try part2();
}
