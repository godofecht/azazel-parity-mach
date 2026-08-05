const std = @import("std");

// A pure-Zig slice: mach's mpsc consumed through the standard Zig build graph
// Zaza is built on. mpsc is std-only, so Zaza's C/C++ target DSL does not apply.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mpsc = b.createModule(.{
        .root_source_file = b.path("vendor/mpsc.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "mpsc_consumer",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.root_module.addImport("mpsc", mpsc);
    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    const run_step = b.step("run", "Build the mpsc consumer and run it");
    run_step.dependOn(&run.step);
}
