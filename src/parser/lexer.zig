const std = @import("std");

pub const Token = struct {
    token: []const u8,
    type: TokenType,
};

//note: make sure all commands are at the begining of the enum and make sure they match the default_commands array
pub const TokenType = enum {
    select,
    from,
    where,
    join,
    separator,
    numerical,
    name,
    operand,
    eof,
};

const default_commands = [_][]const u8{ "SELECT", "FROM", "WHERE", "JOIN" };
const operands = [_][]const u8{ "+", "-", "/", "*", ">", "<" };

pub fn cmd_lexer(buffer: []const u8, allocator: std.mem.Allocator) ![]Token {
    var tokens: std.ArrayList(Token) = .empty;
    var curr_token: std.ArrayList(u8) = .empty;

    for (buffer) |char| {
        if (char != ' ' and char != '\n') {
            if (char == ',' or char == ';') {
                //flush current token
                const prev_token_text = try curr_token.toOwnedSlice(allocator);
                try curr_token.append(allocator, char);

                if (prev_token_text.len != 0) {
                    try tokens.append(allocator, .{ .token = prev_token_text, .type = get_type(prev_token_text) });
                }
                if (char == ';') {
                    break;
                }
            }
            try curr_token.append(allocator, char);
        } else if (curr_token.items.len != 0) {
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
    for (default_commands, 0..default_commands.len) |command, i| {
        if (std.mem.eql(u8, token, command)) {
            const tok_type: TokenType = @enumFromInt(i);
            return tok_type;
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
    if (token[0] == ',') {
        return TokenType.separator;
    }
    if (token[0] == ';') {
        return TokenType.eof;
    }

    return TokenType.name;
}
