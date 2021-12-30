const std = @import("std");
const readline = @import("readline");

const Entry = struct {
    val: u8,
    nbhd_min: u8,
};

const Part1 = struct {
    row_num: u8,
    current_row: [100]Entry,
    previous_row: [100]Entry,
    risk_count: u64,
};

const PartType = enum(u1) {
    part_one,
    part_two,
};

fn array_min(comptime T: type, arr: []T) T {
    var accum: T = ~@as(T, 0);
    for (arr) |elem| {
        accum = std.math.min(accum, elem);
    }
    return accum;
}

fn partn_parser(comptime part_type: PartType, line: []u8, p1: *Part1) anyerror!void {
    var row_nbhd = [_]u8{10} ** 3;

    for (line) |num_str, col| {
        // parse value
        var val = try std.fmt.parseUnsigned(u8, &[_]u8{num_str}, 10);

        // store as entry
        p1.current_row[col].val = val;
        
        // shift array and fill end
        std.mem.rotate(u8, &row_nbhd, 1);
        row_nbhd[2] = val;
        
        // parse current min
        if (col > 0) {
            var local_row_min = array_min(u8, &row_nbhd);
            if (p1.row_num > 0) {
                p1.current_row[col - 1].nbhd_min = std.math.min(p1.previous_row[col - 1].val, local_row_min);
            } else {
                p1.current_row[col - 1].nbhd_min = local_row_min;
            }
        }

        // update previous minimums
        if (p1.row_num > 0) {
            p1.previous_row[col].nbhd_min = std.math.min(p1.previous_row[col].nbhd_min, val);
            
            // update risk score total
            if (p1.previous_row[col].nbhd_min == p1.previous_row[col].val and p1.previous_row[col].val != 9) {
                std.debug.print(" {} ", .{p1.previous_row[col].val});
                p1.risk_count += p1.previous_row[col].val + 1;
            }
        }
    } else {
        // update last column
        std.mem.rotate(u8, &row_nbhd, 1);
        row_nbhd[2] = 10;

        var local_row_min = array_min(u8, &row_nbhd);
        if (p1.row_num > 0) {
            p1.current_row[p1.current_row.len - 1].nbhd_min = std.math.min(p1.previous_row[p1.current_row.len - 1].val, local_row_min);
        } else {
            p1.current_row[p1.current_row.len - 1].nbhd_min = local_row_min;
        }

    }

    p1.row_num += 1;

    std.mem.copy(Entry, &p1.previous_row, &p1.current_row);

}

fn part1_parser(line: []u8, p1: *Part1) anyerror!void {
    try partn_parser(PartType.part_one, line, p1);
}

fn part2_parser(line: []u8, p1: *Part1) anyerror!void {
    try partn_parser(PartType.part_two, line, p1);
}

fn partn(comptime part_type: PartType) anyerror!void {
    var p1 = Part1 {
        .row_num = 0,
        .current_row = [_]Entry{.{.val = 0, .nbhd_min = 0}} ** 100,
        .previous_row = [_]Entry{.{.val = 0, .nbhd_min = 0}} ** 100,
        .risk_count = 0,
    };

    var parser = switch (part_type) {.part_one => part1_parser, .part_two => part2_parser};

    try readline.parse_file_line_by_line(Part1, "input.txt", parser, &p1);

    // clean up last line
    switch (part_type) {
        .part_one => {
            for (p1.previous_row) |col_entry| {
                if (col_entry.nbhd_min == col_entry.val and col_entry.val != 9) {
                    p1.risk_count += col_entry.val + 1;
                }
            }
        },
        .part_two => {},
    }

    std.debug.print("count: {}\n", .{p1.risk_count});
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
