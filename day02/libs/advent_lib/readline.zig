const std = @import("std");

pub fn LineHandler(comptime T: type) type {
    return fn (line: []u8, data: *T) anyerror!void;
} 

pub fn parse_file_line_by_line(comptime T: type, path: []const u8, parser: LineHandler(T), state: *T) anyerror!void {
    var input_file = try std.fs.cwd().openFile(path, .{});
    defer input_file.close();

    var buf_reader = std.io.bufferedReader(input_file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try parser(line, state);
    }
}