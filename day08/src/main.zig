const std = @import("std");
const readline = @import("readline");

const Part1 = struct {
    digit_count: u64,
};

const PartType = enum(u1) {
    part_one,
    part_two,
};

const SegmentStore = struct {
    one: [2]u8,
    seven: [3]u8,
    four: [4]u8,
    len_five_cands: [3][5]u8,
    five_count: u8,
    len_six_cands: [3][6]u8,
    six_count: u8,
    two_char: u8,
};

fn digit_sum(line: []const u8) u16 {
    var accum: u16 = 0;
    for (line) |digit| {
        accum += digit;
    }
    return accum;
}

fn partn_parser(comptime part_type: PartType, line: []u8, p1: *Part1) anyerror!void {
    var iter = std.mem.split(line, " ");

    switch (part_type) {
        .part_one => {
            const unique_lengths = [4]usize{2, 3, 4, 7};

            var bar_flag = false;
            while (iter.next()) |readout| {
                if (readout[0] == '|') {
                    bar_flag = true;
                    continue;
                } else if (!bar_flag) {
                    continue;
                }

                p1.digit_count += std.mem.count(usize, &unique_lengths, &[_]usize{readout.len});
            }
        },
        .part_two => {
            const digits = "abcdefg";
            const dig_sum: u16 = comptime get_sum: {
                var accum: u16 = 0;
                for (digits) |digit| {
                    accum += digit;
                }
                break :get_sum accum;
            };

            var digit_log: [10]u16 = ([_]u16{0} ** 8) ++ [_]u16{ dig_sum } ++ [_]u16{0};

            var store = SegmentStore {
                .one = undefined,
                .seven = undefined,
                .four = undefined,
                .len_five_cands = undefined,
                .five_count = 0,
                .len_six_cands = undefined,
                .six_count = 0,
                .two_char = 0,
            };

            var digit_multiplier: u16 = 1000;            

            var bar_flag = false;
            while(iter.next()) |readout| {
                if (readout[0] == '|') {
                    bar_flag = true;

                    // parse store
                    digit_log[1] = digit_sum(&store.one);
                    digit_log[7] = digit_sum(&store.seven);
                    digit_log[4] = digit_sum(&store.four);
                    
                    // find length six digits
                    var six_found = false;
                    var zero_found = false;
                    var nine_found = false;
                    outer: for (store.len_six_cands) |six_cand| {
                        var sum = digit_sum(six_cand[0..]);
                        if (!six_found) {
                            for (store.one) |one_digit| {
                                if (sum + one_digit == digit_log[8]) {
                                    digit_log[6] = sum;

                                    // segment iii will be in 5 digit
                                    store.two_char = one_digit;
                                    six_found = true;
                                    continue :outer;
                                }
                            }
                        }
                        if (!zero_found) {
                            for (store.four) |four_digit| {
                                if (sum + four_digit == digit_log[8]) {
                                    digit_log[0] = sum;
                                    zero_found = true;
                                    continue :outer;
                                }
                            }
                        }
                        if (!nine_found) {
                            digit_log[9] = sum;
                            nine_found = true;
                        }
                    }

                    // find length five digits
                    // 2 and 5 are differentiated by presence of segment iii character
                    // there are cases where 2 & 5 have the same digit sum
                    digit_log[5] = digit_log[9] + digit_log[6] - digit_log[8];
                    digit_log[2] = digit_log[8] - (digit_log[4] + digit_log[6] + digit_log[0] - 2 * digit_log[8]);
                    digit_log[3] = digit_log[2] + digit_log[5] + digit_log[1] - digit_log[8];

                    continue;
                }

                if (!bar_flag) {
                    switch(readout.len) {
                        2 => {store.one = readout[0..2].*;},
                        3 => {store.seven = readout[0..3].*;},
                        4 => {store.four = readout[0..4].*;},
                        5 => {
                            store.len_five_cands[store.five_count] = readout[0..5].*;
                            store.five_count += 1;
                        },
                        6 => {
                            //std.debug.print("six_digits: {s}\n", .{readout});
                            //std.debug.print("six_count: {}\n", .{store.six_count});
                            store.len_six_cands[store.six_count] = readout[0..6].*;
                            store.six_count += 1;
                        },
                        7 => {},
                        else => unreachable,
                    }
                } else {
                    var read_digit: u8 = switch(readout.len) {
                        2 => 1,
                        3 => 7,
                        4 => 4,
                        5 => blk: {
                            var five_count_sum = digit_sum(readout);
                            if (five_count_sum == digit_log[3]) break :blk @as(u8, 3);
                            if (five_count_sum == digit_log[2]) {
                                for (readout) |char| {
                                    if (char == store.two_char) break :blk @as(u8,2);
                                }
                            }
                            break :blk @as(u8,5);
                        },
                        6 => blk: {
                            if (std.mem.indexOfScalar(u16, digit_log[0..], digit_sum(readout))) |val| {
                                break :blk @truncate(u8, val);
                            } else {
                                unreachable;
                            }
                        },
                        7 => 8,
                        else => unreachable,
                    };
                    //std.debug.print("{}", .{read_digit});
                    p1.digit_count += read_digit * digit_multiplier;

                    digit_multiplier /= 10;
                }
                
            }
            //std.debug.print("\n", .{});

        }
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
        .digit_count = 0,
    };

    var parser = switch (part_type) {.part_one => part1_parser, .part_two => part2_parser};

    try readline.parse_file_line_by_line(Part1, "input.txt", parser, &p1);

    std.debug.print("count: {}\n", .{p1.digit_count});
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

// this is really messy, but it works :/
// could probably be more efficient in terms of memory storage
// i'll come back to this in a bit for a refactor
