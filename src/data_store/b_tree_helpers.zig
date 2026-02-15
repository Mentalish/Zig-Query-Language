const std = @import("std");
const schemastore = @import("store-tree-stuctures.zig");

pub fn findEntry(root: *schemastore.StoreTree, current_node: *schemastore.EntryNode, target_id: u64) ?*schemastore.EntryNode {
    if (current_node.children) |children| {
        if (binarySearch(children, target_id)) |return_index| {
            return children[return_index];
        }

        for (current_node.children) |child| {
            if (findEntry(root, child, target_id)) |return_value| {
                return return_value;
            }
        }
    }
    return null;
}

fn binarySearch(node: *schemastore.EntryNode, target_id: u64) ?usize {}
