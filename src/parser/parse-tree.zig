const std = @import("std");
const typ = @import("lexer.zig");

pub const ParseTreeNode = struct {
    operator: []const u8,
    type_code: typ.TokenType,
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

pub fn create_parse_tree(tokens: []typ.Token, allocator: std.mem.Allocator) !*ParseTreeNode {
    var node_stack: std.ArrayList(ParseTreeNode) = {};
    node_stack.append(try create_node(tokens[0], allocator));
    var i: usize = 1;
    var j: usize = 0;
    var current_state: usize = 0;
    while (i < tokens.len) {
        const action_code: typ.TokenType = try get_action_code(node_stack);
        const action: SubState = state_dictionary[current_state][action_code];

        const opcode = action.action;
        const action_count = action.action_count;
        current_state = action.next_state;
        switch (opcode) {
            .push => {
                while (i < action_count) : (j += 1) {
                    node_stack.append(create_node(tokens[i], allocator));
                    i += 1;
                }
                j = 0;
            },
            .reduce => {
                while (i < action_count) : (j += 1) {}
                j = 0;
            },
            .eof => {},
            .@"error" => return error.Invalid_Token,
            else => unreachable,
        }
    }
}

fn create_node(tokens: typ.Token, allocator: std.mem.Allocator) !*ParseTreeNode {
    var node: *ParseTreeNode = try allocator.create(ParseTreeNode);
    node.operator = tokens.token;
    node.type_code = tokens.type;
    return node;
}

fn get_action_code(stack: std.ArrayList(ParseTreeNode)) ?ActionCode {
    if (stack.len != 0) {
        return stack[stack.len - 1].type_code;
    }
}

pub fn free_parse_tree(root: *ParseTreeNode, allocator: std.mem.Allocator) void {
    for (root.children) |child| {
        free_parse_tree(child, allocator);
    }

    allocator.destroy(root);
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
