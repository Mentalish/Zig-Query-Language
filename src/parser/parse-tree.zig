const std = @import("std");
const typ = @import("lexer.zig");

pub const ParseTreeNode = struct {
    operator: []const u8,
    type_code: typ.TokenType,
    children: ?[]*ParseTreeNode,
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
    var node_stack: std.ArrayList(*ParseTreeNode) = .empty;

    var i: usize = 0;
    var j: usize = 0;
    var current_state: usize = 0;
    while (i < tokens.len) {
        try node_stack.append(allocator, try create_node(tokens[i], allocator));
        i += 1;

        const action_code: typ.TokenType = try get_action_code(node_stack);
        const action: SubState = state_dictionary[current_state][@intFromEnum(action_code)];

        const opcode = action.action;
        const action_count = action.action_count;
        current_state = action.next_state;
        switch (opcode) {
            .push => {},
            .reduce => {
                var popped_nodes: std.ArrayList(*ParseTreeNode) = .empty;
                defer popped_nodes.deinit(allocator);
                while (j < action_count and j < node_stack.items.len) : (j += 1) {
                    try popped_nodes.append(allocator, node_stack.pop().?);
                }
                j = 0;

                const parent_index: usize = popped_nodes.items.len / 2;
                if (parent_index != 0 and parent_index != popped_nodes.items.len) {
                    try reduce_tree(popped_nodes.items[parent_index], popped_nodes.items[0..parent_index], popped_nodes.items[(parent_index + 1)..], allocator);
                } else {
                    try reduce_tree(popped_nodes.items[parent_index], popped_nodes.items[0..parent_index], null, allocator);
                }

                try node_stack.append(allocator, popped_nodes.items[parent_index]);
            },
            .eof => break,
            .@"error" => return error.Invalid_Token,
        }
    }

    return node_stack.items[0];
}

fn create_node(tokens: typ.Token, allocator: std.mem.Allocator) !*ParseTreeNode {
    var node: *ParseTreeNode = try allocator.create(ParseTreeNode);
    node.operator = tokens.token;
    node.type_code = tokens.type;
    return node;
}

fn get_action_code(stack: std.ArrayList(*ParseTreeNode)) !typ.TokenType {
    if (stack.items.len != 0) {
        return stack.items[stack.items.len - 1].type_code;
    }

    return error.NoType;
}

fn reduce_tree(parent: *ParseTreeNode, left_children: ?[]*ParseTreeNode, right_children: ?[]*ParseTreeNode, allocator: std.mem.Allocator) !void {
    var new_children: std.ArrayList(*ParseTreeNode) = .empty;

    if (parent.children) |children| {
        try new_children.appendSlice(allocator, children);
    }

    if (left_children) |children| {
        try new_children.appendSlice(allocator, children);
    }

    if (right_children) |children| {
        try new_children.appendSlice(allocator, children);
    }

    parent.children = try new_children.toOwnedSlice(allocator);
}

const num_commands = @typeInfo(typ.TokenType).@"enum".fields.len;

const state_dictionary = [_][num_commands]SubState{
    state_0: {
        var tmp_row: [num_commands]SubState = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            num_commands;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.select)] = .{ .next_state = 1, .action = ActionCode.push, .action_count = 1 };
        tmp_row[@intFromEnum(typ.TokenType.where)] = .{ .next_state = 4, .action = ActionCode.push, .action_count = 1 };
        tmp_row[@intFromEnum(typ.TokenType.eof)] = .{ .next_state = 999, .action = ActionCode.eof, .action_count = 1 };
        break :state_0 tmp_row;
    },
    state_1: {
        var tmp_row = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            @typeInfo(typ.TokenType).@"enum".fields.len;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.name)] = .{ .next_state = 2, .action = ActionCode.reduce, .action_count = 2 };
        break :state_1 tmp_row;
    },
    state_2: {
        var tmp_row = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            @typeInfo(typ.TokenType).@"enum".fields.len;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.separator)] = .{ .next_state = 1, .action = ActionCode.push, .action_count = 1 };
        tmp_row[@intFromEnum(typ.TokenType.from)] = .{ .next_state = 3, .action = ActionCode.push, .action_count = 1 };
        break :state_2 tmp_row;
    },
    state_3: {
        var tmp_row = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            @typeInfo(typ.TokenType).@"enum".fields.len;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.name)] = .{ .next_state = 0, .action = ActionCode.reduce, .action_count = 2 };
        break :state_3 tmp_row;
    },
    state_4: {
        var tmp_row = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            @typeInfo(typ.TokenType).@"enum".fields.len;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.numerical)] = .{ .next_state = 5, .action = ActionCode.push, .action_count = 1 };
        break :state_4 tmp_row;
    },
    state_5: {
        var tmp_row = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            @typeInfo(typ.TokenType).@"enum".fields.len;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.operand)] = .{ .next_state = 4, .action = ActionCode.push, .action_count = 1 };
        tmp_row[@intFromEnum(typ.TokenType.eof)] = .{ .next_state = 999, .action = ActionCode.eof, .action_count = 1 };
        break :state_5 tmp_row;
    },
};
