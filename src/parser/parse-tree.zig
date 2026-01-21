const std = @import("std");
const typ = @import("lexer.zig");

pub const ParseTreeNode = struct {
    operator: []const u8,
    type_code: typ.TokenType,
    parent: ?*ParseTreeNode = null,
    children: ?[]*ParseTreeNode,
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
    var node_stack: std.ArrayList(*ParseTreeNode) = .empty;

    try node_stack.append(allocator, try create_node(tokens[0], allocator));
    var i: usize = 1;
    var j: usize = 0;
    var current_state: usize = 0;
    while (i < tokens.len) {
        const action_code: typ.TokenType = try get_action_code(node_stack);
        const action: SubState = state_dictionary[current_state][@intFromEnum(action_code)];

        const opcode = action.action;
        const action_count = action.action_count;
        current_state = action.next_state;
        switch (opcode) {
            .push => {
                while (j < action_count and i < tokens.len) : (j += 1) {
                    try node_stack.append(allocator, try create_node(tokens[i], allocator));
                    i += 1;
                }
                j = 0;
            },
            .reduce => {
                var popped_nodes: std.ArrayList(*ParseTreeNode) = .empty;
                defer popped_nodes.deinit(allocator);
                while (j < action_count) : (j += 1) {
                    try popped_nodes.append(allocator, node_stack.pop().?);
                }
                j = 0;

                const parent_index: usize = popped_nodes.items.len / 2;

                try reduce_tree(popped_nodes.items[parent_index], popped_nodes.items[0..parent_index], popped_nodes.items[(parent_index + 1)..popped_nodes.items.len], allocator);
                try node_stack.append(allocator, popped_nodes.items[parent_index]);
            },
            .eof => break,
            .@"error" => return error.Invalid_Token,
        }
    }

    //reduce all

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

fn reduce_tree(parent: *ParseTreeNode, left_children: []*ParseTreeNode, right_children: []*ParseTreeNode, allocator: std.mem.Allocator) !void {
    parent.children = try allocator.alloc(*[]ParseTreeNode, left_children.len + right_children.len);
    for (left_children, 0..left_children.len) |child, i| {
        parent.children.?[i] = child;
    }

    for (right_children, left_children.len..right_children.len) |child, j| {
        parent.children.?[j] = child;
    }
}

const state_dictionary = [_][]const SubState{
    state_0: {
        var tmp_row = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            @typeInfo(typ.TokenType).@"enum".fields.len;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.select)] = .{ .next_state = 1, .action = ActionCode.push, .action_count = 1 };
        tmp_row[@intFromEnum(typ.TokenType.where)] = .{ .next_state = 4, .action = ActionCode.push, .action_count = 0 };
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
        tmp_row[@intFromEnum(typ.TokenType.separator)] = .{ .next_state = 2, .action = ActionCode.push, .action_count = 1 };
        tmp_row[@intFromEnum(typ.TokenType.from)] = .{ .next_state = 3, .action = ActionCode.push, .action_count = 1 };
        const final = tmp_row;
        break :state_2 &final;
    },
    state_3: {
        var tmp_row = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            @typeInfo(typ.TokenType).@"enum".fields.len;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.name)] = .{ .next_state = 0, .action = ActionCode.push, .action_count = 1 };
        const final = tmp_row;
        break :state_3 &final;
    },
    state_4: {
        var tmp_row = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            @typeInfo(typ.TokenType).@"enum".fields.len;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.numerical)] = .{ .next_state = 5, .action = ActionCode.push, .action_count = 1 };
        const final = tmp_row;
        break :state_4 &final;
    },
    state_5: {
        var tmp_row = [_]SubState{.{ .next_state = 999, .action = ActionCode.@"error", .action_count = 0 }} **
            @typeInfo(typ.TokenType).@"enum".fields.len;
        //put fields here
        tmp_row[@intFromEnum(typ.TokenType.operand)] = .{ .next_state = 4, .action = ActionCode.push, .action_count = 1 };
        tmp_row[@intFromEnum(typ.TokenType.eof)] = .{ .next_state = 999, .action = ActionCode.eof, .action_count = 1 };
        const final = tmp_row;
        break :state_5 &final;
    },
};
