const std = @import("std");

const ParseTreeNode = struct {
    operator: []const u8,
    parent: ?*ParseTreeNode = null,
    children: ?*[]ParseTreeNode = null,
};

const StackItem = union(enum){
    tree: ?*ParseTreeNode,
    string: ?[]const u8,
};

pub fn createParseTree(buffer: [][]const u8, allocator: std.mem.Allocator) !*ParseTreeNode {
    var node: *ParseTreeNode = undefined;
    var token_stack = std.BoundedArray(StackItem, buffer.len);

    var i = 0;
    query: while (i < buffer.len) {
        if (std.ascii.eqlIgnoreCase(buffer[i], "SELECT")) {
            token_stack.append(.{.string = .{buffer[i]}});
            i += 1;

            while (std.ascii.isAlphabetic(buffer[i])) {
                token_stack.append(.{.string = .{buffer[i]}});
                i += 1;
                break: query;
            }
        } else if (std.ascii.eqlIgnoreCase(buffer[i], "FROM")) {
            token_stack.append(.{.string = .{buffer[i]}});
            i += 1;
            break: query;
        } else if (std.ascii.eqlIgnoreCase(buffer[i], "WHERE")) {
            //grab operators
        } else {
            unreachable; //bad operator
        }
    }

    return node;
}
