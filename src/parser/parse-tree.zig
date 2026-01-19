const std = @import("std");
const typ = @import("lexer.zig");

pub const ParseTreeNode = struct {
    operator: []const u8,
    parent: ?*ParseTreeNode = null,
    children: ?*[]ParseTreeNode = null,
};

const StackItem = union(enum) {
    tree: ?*ParseTreeNode,
    string: ?[]const u8,
};

pub const SubState = struct {
    next_state: usize,
    action: ActionCode,
    action_count: usize,
};

const ActionCode = enum {
    reduce,
    push,
    eof,
    @"error",
};

const StateDictionary = struct { state: []State, num_states: usize };

const State = struct { sub_states: std.StringHashMap([]const u8) };

pub fn create_parse_tree(buffer: [][]const u8, state_tree: []State, allocator: std.mem.Allocator) !*ParseTreeNode {
    var node_stack: std.ArrayList(StackItem) = {};
    node_stack.append(try create_node(buffer[0], allocator));
    var i: usize = 1;
    var current_state: usize = 0;
    while (i < buffer.len) {
        var opcode: ActionCode = try state_tree.state[current_state].get(peak(node_stack)) orelse break;
        //do actions based on code
        //push next thing to the stack
        node_stack.append(create_node(buffer[i], allocator));
        i += 1;
    }
}

fn create_node(operator: []const u8, allocator: std.mem.Allocator) !*ParseTreeNode {
    var node: *ParseTreeNode = try allocator.create(ParseTreeNode);
    node.operator = operator;
    return node;
}

fn peak(stack: std.ArrayList(StackItem)) ?[]const u8 {
    if (stack.len != 0) {
        return stack[stack.len - 1].operator;
    }
}

const state_dictionary = [_]?[]const SubState{
    state_0: {
        var tmp_row = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            @typeInfo(typ.TokenType).@"enum".fields.len;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.command)] = .{ .next_state = 1, .action = ActionCode.push, .action_count = 1 }; //select
        const final = tmp_row;
        break :state_0 &final;
    },
    state_1: {
        var tmp_row = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            @typeInfo(typ.TokenType).@"enum".fields.len;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.name)] = .{ .next_state = 2, .action = ActionCode.push, .action_count = 1 };
        const final = tmp_row;
        break :state_1 &final;
    },
    state_2: {
        var tmp_row = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            @typeInfo(typ.TokenType).@"enum".fields.len;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.command)] = .{ .next_state = 3, .action = ActionCode.push, .action_count = 1 }; //from
        tmp_row[@intFromEnum(typ.TokenType.numerical)] = .{ .next_state = 3, .action = ActionCode.push, .action_count = 1 };
        const final = tmp_row;
        break :state_2 &final;
    },
    state_3: {
        var tmp_row = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            @typeInfo(typ.TokenType).@"enum".fields.len;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.command)] = .{ .next_state = 1, .action = ActionCode.push, .action_count = 1 };
        const final = tmp_row;
        break :state_3 &final;
    },
    state_4: {
        var tmp_row = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            @typeInfo(typ.TokenType).@"enum".fields.len;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.command)] = .{ .next_state = 1, .action = ActionCode.push, .action_count = 1 };
        const final = tmp_row;
        break :state_4 &final;
    },
};

pub fn free_parse_tree(root: *ParseTreeNode, allocator: std.mem.Allocator) void {
    for (root.children) |child| {
        free_parse_tree(child, allocator);
    }

    allocator.destroy(root);
}
