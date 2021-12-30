const std = @import("std");
const readline = @import("readline");

const Point = struct {x: i16, y: i16};

const LineType = enum(u2) {
    diagonal = 0,
    horizontal = 1,
    vertical = 2,
    point = 3
};

const Part1 = struct {
    map: std.AutoHashMap(Point, u8),
};

const PartType = enum(u1) {
    part_one,
    part_two,
};

fn partn_parser(comptime part_type: PartType, line: []u8, p1: *Part1) anyerror!void {
    var iter = std.mem.tokenize(line, ", ->");

    var point_data = [_]i16{0} ** 4;

    var count: u8 = 0;
    while (iter.next()) |num_str| {
        if (num_str.len == 0) continue;
        point_data[count] = try std.fmt.parseUnsigned(i16, num_str, 10);
        count += 1;
    }

    var line_type: LineType = LineType.diagonal;
    var _tmp = @addWithOverflow(
        u2,
        @boolToInt(point_data[0] == point_data[2]),
        2 * @as(u2, @boolToInt(point_data[1] == point_data[3])),
        @ptrCast(*u2, &line_type)
    );
    switch (line_type) {
        .diagonal => {
            switch (part_type) {
                .part_one => {},
                .part_two => {
                    var sign_y: i8 = 1 - 2 * @as(i8, @boolToInt(point_data[1] > point_data[3]));
                    var sign_x: i8 = 1 - 2 * @as(i8, @boolToInt(point_data[0] > point_data[2]));

                    var x: i16 = point_data[0];
                    var y: i16 = point_data[1];
                    while (y != point_data[3] + sign_y) : ({y += sign_y; x += sign_x;}) {
                        if (p1.map.get(.{.x = x, .y = y})) |val| {
                            try p1.map.put(.{.x = x, .y = y}, val + 1);
                        } else {
                            try p1.map.put(.{.x = x, .y = y}, 1);
                        }
                    }
                }
            }
        },
        .horizontal => {
            var sign: i8 = 1 - 2 * @as(i8, @boolToInt(point_data[1] > point_data[3]));
            var y: i16 = point_data[1];
            while (y != point_data[3] + sign) : (y += sign) {
                if (p1.map.get(.{.x = point_data[0], .y = y})) |val| {
                    try p1.map.put(.{.x = point_data[0], .y = y}, val + 1);
                } else {
                    try p1.map.put(.{.x = point_data[0], .y = y}, 1);
                }
            }
        },
        .vertical => {
            var sign: i8 = 1 - 2 * @as(i8, @boolToInt(point_data[0] > point_data[2]));
            var x: i16 = point_data[0];
            while (x != point_data[2] + sign) : (x += sign) {
                if (p1.map.get(.{.x = x, .y = point_data[1]})) |val| {
                    try p1.map.put(.{.x = x, .y = point_data[1]}, val + 1);
                } else {
                    try p1.map.put(.{.x = x, .y = point_data[1]}, 1);
                }
            }
        },
        .point => {
            if (p1.map.get(.{.x = point_data[0], .y = point_data[1]})) |val| {
                try p1.map.put(.{.x = point_data[0], .y = point_data[1]}, val + 1);
            } else {
                try p1.map.put(.{.x = point_data[0], .y = point_data[1]}, 1);
            }
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
    var p1 = Part1 {
        .map = std.AutoHashMap(Point, u8).init(&gpa.allocator),
    };
    defer p1.map.deinit();

    var parser = switch (part_type) {.part_one => part1_parser, .part_two => part2_parser};

    try readline.parse_file_line_by_line(Part1, "input.txt", parser, &p1);

    var count: u32 = 0;
    var iter = p1.map.iterator();
    while (iter.next()) |entry| {
        count += @boolToInt(entry.value_ptr.* > 1);
    }

    std.debug.print("count: {}\n", .{count});
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

// final comment -- sign calc, hashmap updates, and logic in line-type switch could be refactored
