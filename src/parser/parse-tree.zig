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

pub fn create_parse_tree(buffer: [][]const u8, state_tree: []State, allocator: std.mem.Allocator) !*ParseTreeNode {
    var node_stack: std.ArrayList(StackItem) = {};
    node_stack.append(try create_node(buffer[0], allocator));
    var i: usize = 1;
    var current_state: usize = 0;
    while (i < buffer.len) {
        node_stack.append(create_node(buffer[i], allocator));
        var opcode: []const u8 = try state_tree.state[current_state].get(peak(node_stack)) orelse break;
        //do actions based on code
        
        //push next thing to the stack
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

const StateDictionary = struct { state: []State, num_states: usize };

const State = struct { sub_states: std.StringHashMap([]const u8) };

pub fn init_state_dictionary(allocator: std.mem.Allocator) !*StateDictionary {
    //init state tree
    var state_tree: StateDictionary = allocator.alloc(StateDictionary, 1);
    state_tree.num_states = 5;
    
    state_tree.state = allocator.alloc(State, state_tree.num_states);

    //init substates
    for (state_tree.state) |state| {
        state.sub_states = std.StringHashMap([]const u8).init(allocator);
    }

    //populate state tree
    try state_tree.state[0].stubstates.put("SELECT", "s2p1");
    try state_tree.state[1].stubstates.put("<TABLE>", "s3p1");
    try state_tree.state[2].stubstates.put("FROM", "s4p1");
    try state_tree.state[2].stubstates.put("<NUM>", "s4r3");
    try state_tree.state[3].stubstates.put("<NUM>", "s5p1");
    try state_tree.state[4].stubstates.put("<OPERATOR>", "s3");


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
