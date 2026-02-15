const std = @import("std");
const schemastore = @import("store-tree-stuctures.zig");

pub fn findEntry(root: *schemastore.StoreTree, current_node: *schemastore.EntryNode, target_id: usize) ?*schemastore.EntryNode {
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

fn binarySearch(children: *[]schemastore.EntryNode, target_id: usize) ?usize {
    var high = children.*.len - 1;
    var low = 0;
    var center: usize = (high - low) / 2;
    while (center > 0 and center < children.*.len) {
        if (target_id == children[center].*.primary_key) {
            return center;
        }

        if (target_id < children[center].*.primary_key) {
            high = center;
        } else {
            low = center;
        }

        center = (high - low) / 2;
    }

    return null;
}
