const std = @import("std");

pub fn cmd_lexer(buffer: []const u8, allocator : std.mem.Allocator) ![][]const u8 {
    var tokens: std.ArrayList([]const u8) = .empty;
    var curr_token: std.ArrayList(u8) = .empty;

    for (buffer) |char| {

        if (char != ' ' and char != '\n') { 
           try curr_token.append(allocator, char); 
        }else {
           try tokens.append(allocator, try curr_token.toOwnedSlice(allocator));
        } 
    }
    
    if (curr_token.items.len > 0) {
         try tokens.append(allocator, try curr_token.toOwnedSlice(allocator));
    }

    return try tokens.toOwnedSlice(allocator);
}
