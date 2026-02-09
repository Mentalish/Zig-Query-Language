const std = @import("std");
const schemastore = @import("store-tree-stuctures.zig");

pub fn findEntry(root: *schemastore.StoreTree, current_node: *schemastore.EntryNode, target: usize) ?*schemastore.EntryNode {
    if (current_node.children) |children| {
        if (binarySearch(children, target)) |return_index| {
            return current_node.children[return_index];
        }

        for (current_node.children) |child| {
            if (findEntry(root, child, target)) |return_value| {
                return return_value;
            }
        }
    }
    return;
}

fn binarySearch(node: *schemastore.EntryNode, target: usize) ?usize {
   
}
