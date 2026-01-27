const std = @import("std");

const Database = struct {
    name: []const u8,
    schemas: std.StringHashMap(*Schema),
};

const Schema = struct {
    name: []const u8,
    tables: std.StringHashMap(*TableSchema),
};

const TableSchema = struct {
    name: []const u8,
    items: std.StringHashMap(*Data),
    foreign_keys: ?[][]const u8 = null,
};

const Data = struct {
    name: []const u8,
    type: DataType,
};

const DataType = enum {
    INT,
    FLOAT,
    STRING,
};
