const std = @import("std");
const schema_structure = @import("schema_structure.zig");

pub fn create_schema(schema_name: []const u8, data_tables: *[]schema_structure.TableSchema, allcator: std.mem.Allocator) !*schema_structure.Schema {
    var schema = allcator.create(schema_structure.schema);

    schema.name = schema_name;
    schema.tables = data_tables;

    return schema;
}

fn create_table_schema(name: [][]const u8, items: *[]schema_structure.Data ,foregin_keys: ?[][]const u8, allocator: std.mem.Allocator) !*[]schema_structure.TableSchema {
    var table_schema = allocator.create(schema_structure.TableSchema);

    table_schema.name = name;

    if (foregin_keys) |fk| {
        table_schema.foreign_keys = fk;
    }

    table_schema.items = items;

    return table_schema;
}

fn create_data_entries(names: [][]const u8, types: []schema_structure.DataType, allocator: std.mem.Allocator) !*[]schema_structure.Data {
    if (names.len != types.len) {
        return error.bad_call;
    }
    var data_entries: std.ArrayList(*schema_structure.Data) = .empty;

    for (names, types) |name, entry_type| {
        var entry = try allocator.create(schema_structure.Data);
        entry.name = name;
        entry.type = entry_type;

        try data_entries.append(allocator, entry);
    }

    return data_entries.toOwnedSlice(allocator);
}
