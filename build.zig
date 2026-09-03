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

    const ncurses_mod = b.addModule("ncurses", .{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    ncurses_mod.linkLibrary(gpm_dep.artifact("gpm"));

    ncurses_mod.addIncludePath(b.path("include"));
    ncurses_mod.addIncludePath(b.path("ncurses"));
    ncurses_mod.addCSourceFiles(.{
        .files = &ncurses_sources.source_files,
        .flags = &flags,
    });

    const lib = b.addLibrary(.{
        .name = "ncurses",
        .linkage = .static,
        .root_module = ncurses_mod,
    });
    b.installArtifact(lib);
    lib.installHeader(b.path("install/include/curses.h"), "curses.h");
    lib.installHeader(b.path("install/include/ncurses.h"), "ncurses.h");
    lib.installHeader(b.path("install/include/term.h"), "term.h");
    lib.installHeadersDirectory(b.path("install/include"), "", .{});
}
