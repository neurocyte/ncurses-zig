const std = @import("std");
const ncurses_sources = @import("ncurses.sources.zig");

const flags = [_][]const u8{};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const gpm_dep = b.dependency("gpm", .{
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addStaticLibrary(.{
        .name = "ncurses",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();
    lib.linkLibrary(gpm_dep.artifact("gpm"));
    lib.addIncludePath(.{ .path = "include" });
    // lib.addIncludePath(.{ .path = "install/include" });
    lib.addIncludePath(.{ .path = "ncurses" });
    addSources(lib);

    b.installArtifact(lib);
    installHeaders(lib, b);
}

fn addSources(self: *std.Build.Step.Compile) void {
    for (ncurses_sources.source_files) |file| {
        self.addCSourceFiles(.{ .files = &[_][]const u8{file}, .flags = &flags });
    }
}

fn installHeaders(self: *std.Build.Step.Compile, b: *std.Build) void {
    for (ncurses_sources.header_files) |file| {
        const path = std.fs.path.join(b.allocator, &.{ "install", "include", file }) catch unreachable;
        self.installHeader(.{ .path = path }, file);
        b.allocator.free(path);
    }
}
