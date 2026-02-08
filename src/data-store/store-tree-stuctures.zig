const schema = @import("../schema/schema_structure.zig");

const StoreTree = struct {
    root: *[]EntryNode,
    max_children: usize,
    min_children: usize
};

const EntryNode = struct {
    primary_key: u64,
    data: *[]Data,
    children: ?*[]EntryNode
};

const Data = struct {
    key: []const u8,
    value: anyopaque,
    type: schema.DataType
};
