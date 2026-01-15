const std = @import("std");
const zql = @import("Zig_Query_Language");

pub fn main() !void {
    var in_buffer: [1024]u8 = undefined;
    var out_buffer: [1024]u8 = undefined;

    var stdin_reader = std.fs.File.stdin().reader(&in_buffer);
    const stdin: *std.io.Reader = &stdin_reader.interface;
    
    var stdout_writer = std.fs.File.stdout().writer(&out_buffer);
    const stdout: *std.io.Writer = &stdout_writer.interface;
    while (true) { 
        try stdout.print("Enter the Query: \n", .{});
        try stdout.flush();

        const buffer = try stdin.takeDelimiter('\n') orelse "";

        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const base_allocator = gpa.allocator();
        defer _ = gpa.deinit();

        var arena_allocator = std.heap.ArenaAllocator.init(base_allocator);
        defer arena_allocator.deinit();

        const tokens: [][]const u8 = zql.lexer.cmd_lexer(buffer, arena_allocator.allocator()) catch &[_][]const u8{};

        for (tokens) |token| {
            try stdout.print("{s} ", .{token});
        }
        
        try stdout.print("\n", .{});
        try stdout.flush();
    }
}
