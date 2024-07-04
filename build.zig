const std = @import("std");

pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    //const lib = b.addStaticLibrary(.{
    //    .name = "zbor",
    //    .root_source_file = .{ .path = "src/main.zig" },
    //    .target = target,
    //    .optimize = optimize,
    //});

    //// This declares intent for the library to be installed into the
    //// standard location when the user invokes the "install" step (the default
    //// step when running `zig build`).
    //lib.install();

    const zbor_module = b.addModule("zbor", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    try b.modules.put(b.dupe("zbor"), zbor_module);

    // Creates a step for unit testing.
    const lib_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&b.addRunArtifact(lib_tests).step);

    // Creates a step for fuzz testing.
    const fuzz_tests = b.addTest(.{
        .root_source_file = b.path("src/fuzz.zig"),
        .target = target,
        .optimize = optimize,
    });

    const fuzz_test_step = b.step("fuzz", "Run fuzz tests");
    fuzz_test_step.dependOn(&b.addRunArtifact(fuzz_tests).step);

    // Examples
    // ---------------------------------------------------
    const examples: [2][2][]const u8 = .{
        .{ "examples/manual_serialization.zig", "manual_serialization" },
        .{ "examples/automatic_serialization.zig", "automatic_serialization" },
    };

    for (examples) |entry| {
        const path, const name = entry;

        const example = b.addExecutable(.{
            .name = name,
            .root_source_file = b.path(path),
            .target = target,
            .optimize = optimize,
        });
        example.root_module.addImport("zbor", zbor_module);
        //example.addModule("zbor", zbor_module);
        b.installArtifact(example);
    }
}
