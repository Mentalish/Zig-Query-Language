const std = @import("std");

const Types = enum {
    MATH,
    SCHEMA,

};

const ParseTreeNode = struct {
    operator: []const u8,
    type: 
    children: *ParseTreeNode,
};


pub fn createParseTree(buffer: [][]const u8, allocator: std.mem.Allocator) !*ParseTreeNode {
    for (buffer) |token| {
        //push token
        //check what the token was
        //act based on rules
    }
}
