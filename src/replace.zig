const runtimes = @import("runtimes.zig");
const assert = std.debug.assert;
const std = @import("std");

fn getOffset(path: []const u8) !u64 {
    var file = try std.fs.cwd().openFile(path, .{});
    try file.seekFromEnd(-8);

    var buffer: [8]u8 = undefined;
    assert(try file.readAll(&buffer) == 8);

    return std.mem.readInt(u64, buffer[0..8], std.builtin.Endian.big);
}

pub fn main() !void {
    var args = std.process.args();
    assert(args.skip());
    const rawPath = args.next();
    const rawPathOutput = args.next();

    if (rawPath) |path| {
        if (rawPathOutput) |path_output| {

    const offset = try getOffset(path);

    const readFile = try std.fs.cwd().openFile(path, .{});
    const writeFile = try std.fs.cwd().createFile(path_output, .{});

    try writeFile.writeAll(runtimes.runtime_content_x86_64);
    const len_to_write = try readFile.getEndPos() - offset - 8;
    const len_written = try std.fs.File.copyRange(readFile, offset, writeFile, try writeFile.getPos(), len_to_write);
    assert(len_to_write == len_written);

    try writeFile.seekFromEnd(0);
    try writeFile.writeAll(&runtimes.runtime_content_len_u64_x86_64);
    try writeFile.chmod(0o755);


    writeFile.close();
    readFile.close();
        }
    }
}