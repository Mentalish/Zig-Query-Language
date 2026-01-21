const std = @import("std");
const zql = @import("Zig_Query_Language");

pub fn main() !void {
    var in_buffer: [1024]u8 = undefined;
    var out_buffer: [1024]u8 = undefined;

    var stdin_reader = std.fs.File.stdin().reader(&in_buffer);
    const stdin: *std.io.Reader = &stdin_reader.interface;

    var stdout_writer = std.fs.File.stdout().writer(&out_buffer);
    const stdout: *std.io.Writer = &stdout_writer.interface;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const base_allocator = gpa.allocator();
    defer _ = gpa.deinit();

    while (true) {
        try stdout.print("Enter the Query: \n", .{});
        try stdout.flush();

        const buffer = try stdin.takeDelimiter('\n') orelse "";

        var arena_allocator = std.heap.ArenaAllocator.init(base_allocator);
        defer arena_allocator.deinit();

        const tokens: []zql.lexer.Token = zql.lexer.cmd_lexer(buffer, arena_allocator.allocator()) catch continue;

        for (tokens) |token| {
            try stdout.print("{s} {} ", .{ token.token, token.type });
        }

        try stdout.flush();

        const query_parse_tree: *zql.parse.ParseTreeNode = zql.parse.create_parse_tree(tokens, arena_allocator.allocator()) catch |err|
            switch (@as(anyerror, err)) {
                error.InvalidToken => {
                    try stdout.print("\nInvalid Query\n", .{});
                    try stdout.flush();
                    continue;
                },
                else => {
                    try stdout.print("Invalid Memory allocation\n", .{});
                    try stdout.flush();
                    continue;
                },
            };

        try stdout.print("\n{s}", .{query_parse_tree.operator});

        try stdout.print("\n", .{});
        try stdout.flush();
    }
}
