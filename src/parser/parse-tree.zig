const std = @import("std");

const ParseTreeNode = struct {
    operator: []const u8,
    parent: ?*ParseTreeNode = null,
    children: ?*[]ParseTreeNode = null,
};

const StackItem = union(enum) {
    tree: ?*ParseTreeNode,
    string: ?[]const u8,
};

const SubState = struct{
    next_state: usize,
    action: ActionCode, 
    action_count: usize,
};

const ActionCode = enum 
{
    REDUCE,
    PUSH,
    EOF,
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

pub fn init_state_dictionary(allocator: std.mem.Allocator) !*StateDictionary {
    //init state tree
    var state_tree: StateDictionary = allocator.alloc(StateDictionary, 1);
    state_tree.num_states = 5;
    
    state_tree.state = allocator.alloc(State, state_tree.num_states);

    //init substates
    for (state_tree.state) |state| {
        state.sub_states = std.StringHashMap(SubState).init(allocator);
    }

    //populate state tree
    try state_tree.state[0].stubstates.put("SELECT", .{.next_state = 1, .action = ActionCode.PUSH, .action_count = 1});
    try state_tree.state[1].stubstates.put("<TABLE>", .{.next_state = 2, .action = ActionCode.PUSH, .action_count = 1}); 
    try state_tree.state[2].stubstates.put("FROM", .{.next_state = 3, .action = ActionCode.PUSH, .action_count = 1});
    try state_tree.state[2].stubstates.put("<NUM>", .{.next_state = 3, .action = ActionCode.REDUCE, .action_count = 3});
    try state_tree.state[3].stubstates.put("<NUM>", .{.next_state = 4, .action = ActionCode.PUSH, .action_count = 1});
    try state_tree.state[4].stubstates.put("<OPERATOR>", .{.next_state = 0, .action = ActionCode.PUSH, .action_count = 1});


    return state_tree;
}

pub fn free_parse_tree(root: *ParseTreeNode, allocator: std.mem.Allocator) void{
    for (root.children) |child|{
        free_parse_tree(child, allocator);
    }

    allocator.destroy(root);
}

pub fn free_state_dictionary(state_dictionary: *StateDictionary, allocator: std.mem.Allocator) void {
    for (state_dictionary.state) |state| {
        state.sub_states.deinit();
    }

    allocator.destroy(state_dictionary);
}
