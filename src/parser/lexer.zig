const std = @import("std");

pub const Token = struct {
    token: []const u8,
    type: TokenType,
};

pub const TokenType = enum {
    command,
    numerical,
    name,
    operand,
    eof,
};

const default_commands = [_][]const u8{"SELECT"};
const operands = [_][]const u8{ "+", "-", "/", "*", ">", "<" };

pub fn cmd_lexer(buffer: []const u8, allocator: std.mem.Allocator) ![]Token {
    var tokens: std.ArrayList(Token) = .empty;
    var curr_token: std.ArrayList(u8) = .empty;

    for (buffer) |char| {
        if (char == ';') {
            try curr_token.append(allocator, char);
            const token_text = try curr_token.toOwnedSlice(allocator);
            try tokens.append(allocator, .{ .token = token_text, .type = get_type(token_text) });
            break;
        }
        if (char != ' ' and char != '\n') {
            try curr_token.append(allocator, char);
        } else {
            const token_text = try curr_token.toOwnedSlice(allocator);
            try tokens.append(allocator, .{ .token = token_text, .type = get_type(token_text) });
        }
    }

    if (curr_token.items.len > 0) {
        const token_text = try curr_token.toOwnedSlice(allocator);
        try tokens.append(allocator, .{ .token = token_text, .type = get_type(token_text) });
    }

    return try tokens.toOwnedSlice(allocator);
}

fn get_type(token: []const u8) TokenType {
    for (default_commands) |command| {
        if (std.mem.eql(u8, token, command)) {
            return TokenType.command;
        }
    }
    for (operands) |operand| {
        if (std.mem.eql(u8, token, operand)) {
            return TokenType.operand;
        }
    }

    if (std.ascii.isDigit(token[0])) {
        return TokenType.numerical;
    }

    if (token[0] == ';') {
        return TokenType.eof;
    }

    return TokenType.name;
}
