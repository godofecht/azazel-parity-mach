//! Consumer of mach's mpsc: instantiates the Pool and Queue generics at
//! comptime, forcing mach's multi-producer/single-consumer datastructure to
//! compile. (Runtime use needs a std.Io event loop; comptime instantiation
//! proves the code compiles without it.)
const std = @import("std");
const mpsc = @import("mpsc");

comptime {
    _ = mpsc.Pool(u64);
    _ = mpsc.Queue(u64);
}

pub fn main() void {
    std.debug.print("mach mpsc: Pool and Queue generics compiled\n", .{});
}
