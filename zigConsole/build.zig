const std = @import("std");
const Path = std.Build.LazyPath;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const binary = b.addExecutable(.{
        .name = "__change__",
        .root_source_file = Path.relative("src/main.zig"),
        // or (implicit LazyPath struct, w/ path field)
        // .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // build C and/or C++

    // Need use libc to C code build? uncomment below

    // binary.addIncludePath(Path.relative("myinclude"));
    // binary.addCSourceFile(.{ .file = Path.relative("src/main.c"), .flags = &.{ "-Wall", "-Wextra" } });
    // binary.addCSourceFiles(&.{ "foo.cc", "bar.cc" }, &.{ "-Wall", "-std=c++17" });

    // warning to mixing C and C++ code. Use same flags, but c++flags(exclusive) not working (e.g.: "-std=c++11")
    // binary.addCSourceFiles(&.{ "foo.cc", "bar.c" }, &.{ "-Wall", "-Werror" });

    // linking
    // binary.linklibC(); // get libc and c-stdlib
    // for C++
    // binary.linklibCpp(); // builtin llvm-libcxx/abi + libunwind (+ stl) + libc (avoid duplicate - no need linklibC())

    // copy binary from zig-cache to zig-out/bin [default]
    b.installArtifact(binary);
}
