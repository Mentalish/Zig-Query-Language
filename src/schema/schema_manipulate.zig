const std = @import("std");
const schema_structure = @import("schema_structure.zig");

pub fn create_schema(db_schema: *schema_structure.Schema, schema_name: []const u8, data_tables: *[]schema_structure.TableSchema, allcator: std.mem.Allocator) !*schema_structure.Schema {
    db_schema.tables = std.StringHashMap(*schema_structure.TableSchema).init(allcator);

    db_schema.name = schema_name;
    
    for (data_tables) |table| {
        try db_schema.tables.put(table.name, table);
    }
}

fn create_table_schema(table_schema: *schema_structure.TableSchema, name: [][]const u8, items: *[]schema_structure.Data ,foregin_keys: ?[][]const u8, allocator: std.mem.Allocator) !void {
    table_schema.items = std.StringHashMap(*schema_structure.Data).init(allocator);

    table_schema.name = name;

    if (foregin_keys) |fk| {
        table_schema.foreign_keys = fk;
    }

    for(items) |item|{
       try table_schema.items.put(item.name, item); 
    }
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
