const std = @import("std");
const readline = @import("readline");

const Part1 = struct {
    called_on_turn: [100]u8,
    bingo_board: [5][5]u8,
    row: u8,
    min_board_score: u32,
    min_turns: u8,
};

fn min_turn_score_scan(bingo_board: *[5][5]u8, called_on_turn: *[100]u8, min_turns: *u8, final_score: *u32) void {
    var ex_reducer: u8 = 101;
    var final_entry: u8 = 0;

    var i: u8 = 0;
    var j: u8 = 0;
    while (i < 5) : ({i += 1; j = 0;}) {
        var in_reducers = [_]u8{0} ** 2;
        var final_entry_reducers = [_]u8{0} ** 2;

        while (j < 5) : (j += 1) {
            for ([_]u8{bingo_board[j][i], bingo_board[i][j]}) |entry, k| {
                var call_turn = called_on_turn[entry];
                if (in_reducers[k] < call_turn) {
                    in_reducers[k] = call_turn;
                    final_entry_reducers[k] = entry;
                }
            }
        }

        if (std.math.min3(ex_reducer, in_reducers[0], in_reducers[1]) != ex_reducer) {
            ex_reducer = std.math.min(in_reducers[0], in_reducers[1]);
            final_entry = final_entry_reducers[@boolToInt(in_reducers[0] > in_reducers[1])];
        }
    }

    min_turns.* = ex_reducer;
    final_score.* = score_calc : {
        var accum: u32 = 0;
        for (bingo_board) |row| {
            for (row) |entry| {
                if (called_on_turn[entry] > min_turns.*) accum += entry;
            }
        }
        accum *= final_entry;
        break :score_calc accum;
    };
}

// fill call order via header
fn part1_header_parser(line: []u8, p1: *Part1) anyerror!void {
    var iter = std.mem.split(line, ",");
    var count: u8 = 0;
    while (iter.next()) |num_str| : (count += 1){
        var idx = try std.fmt.parseUnsigned(u8, num_str, 10);
        p1.called_on_turn[idx] = count;
    }
}

fn part1_scanner_parser(line: []u8, p1: *Part1) anyerror!void {
    if (line.len <= 1) {
        // new line subroutine
        p1.bingo_board = [_][5]u8{[_]u8{0} ** 5} ** 5;
        p1.row = 0;
        return;
    }

    var iter = std.mem.split(line, " ");
    var col: u8 = 0;
    while (iter.next()) |num_str| {
        if (num_str.len == 0) continue;
        var num = try std.fmt.parseUnsigned(u8, num_str, 10);
        p1.bingo_board[p1.row][col] = num;
        col += 1;
    }
    p1.row += 1;
    
    if (p1.row == 5) {
        var min_turns: u8 = 0;
        var final_score: u32 = 0;

        min_turn_score_scan(&p1.bingo_board, &p1.called_on_turn, &min_turns, &final_score);

        if (p1.min_turns >= min_turns) {
            p1.min_turns = min_turns;
            p1.min_board_score = final_score;
        }
        std.debug.print("min_turns = {}, board_score = {}\n\n", .{p1.min_turns, p1.min_board_score});
        for (p1.bingo_board) |row| {
            for (row) |entry| {
                std.debug.print("{} ", .{p1.called_on_turn[entry]});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }
}

fn part1() anyerror!void {
    var p1 = Part1 {
        .called_on_turn = [_]u8{0} ** 100,
        .bingo_board = [_][5]u8{[_]u8{0} ** 5} ** 5,
        .row = 0,
        .min_board_score = 0,
        .min_turns = 101,
    };

    try readline.parse_header_then_scan(Part1, "input.txt", 1, part1_header_parser, part1_scanner_parser, &p1);

    std.debug.print("min_turns: {}, final_score: {}\n", .{p1.min_turns, p1.min_board_score});
}

fn part2_scanner_parser(line: []u8, p2: *Part1) anyerror!void {
    
    if (line.len <= 1) {
        // new line subroutine
        p2.bingo_board = [_][5]u8{[_]u8{0} ** 5} ** 5;
        p2.row = 0;
        return;
    }

    var iter = std.mem.split(line, " ");
    var col: u8 = 0;
    while (iter.next()) |num_str| {
        if (num_str.len == 0) continue;
        var num = try std.fmt.parseUnsigned(u8, num_str, 10);
        p2.bingo_board[p2.row][col] = num;
        col += 1;
    }
    p2.row += 1;
    
    if (p2.row == 5) {
        var max_turns: u8 = 0;
        var final_score: u32 = 0;

        min_turn_score_scan(&p2.bingo_board, &p2.called_on_turn, &max_turns, &final_score);

        if (p2.min_turns <= max_turns) {
            p2.min_turns = max_turns;
            p2.min_board_score = final_score;
        }
        std.debug.print("min_turns = {}, board_score = {}\n\n", .{p2.min_turns, p2.min_board_score});
        for (p2.bingo_board) |row| {
            for (row) |entry| {
                std.debug.print("{} ", .{p2.called_on_turn[entry]});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }
}

fn part2() anyerror!void {
    var p2 = Part1 {
        .called_on_turn = [_]u8{0} ** 100,
        .bingo_board = [_][5]u8{[_]u8{0} ** 5} ** 5,
        .row = 0,
        .min_board_score = 0,
        .min_turns = 0,
    };

    try readline.parse_header_then_scan(Part1, "input.txt", 1, part1_header_parser, part2_scanner_parser, &p2);

    std.debug.print("max_turns: {}, final_score: {}\n", .{p2.min_turns, p2.min_board_score});
}

pub fn main() anyerror!void {
    std.debug.print("Part 1\n------\n", .{});
    try part1();
    std.debug.print("Part 2\n------\n", .{});
    try part2();
}

//final comments -- there's some refactoring to be done to merge part1 & part2 scanning parsers for sure
