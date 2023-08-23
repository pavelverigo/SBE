const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "SBE",
        .target = target,
        .optimize = optimize,
    });

    // Code uses &b->ins[b->nins], when b->ins == NULL, this causes sanitizer to catch undefined behaviour
    exe.addCSourceFiles(&src_files, &[_][]const u8{ "-std=c99", "-fno-sanitize=undefined" });
    exe.linkLibC();

    exe.defineCMacro("ZIG_BUILD", "");

    const t = exe.target_info.target; // TODO: get it from target directly?
    exe.defineCMacro("Deftgt", switch (t.os.tag) {
        .macos => switch (t.cpu.arch) {
            .aarch64 => "T_arm64_apple",
            .x86_64 => "T_amd64_apple",
            else => "T_unknown",
        },
        else => switch (t.cpu.arch) {
            .aarch64 => "T_arm64",
            .x86_64 => "T_amd64_sysv",
            .riscv64 => "T_rv64",
            else => "T_unknown",
        },
    });

    b.installArtifact(exe);
}

const src_files = [_][]const u8{
    "abi.c",
    "alias.c",
    "cfg.c",
    "copy.c",
    "emit.c",
    "fold.c",
    "live.c",
    "load.c",
    "main.c",
    "mem.c",
    "parse.c",
    "rega.c",
    "simpl.c",
    "spill.c",
    "ssa.c",
    "util.c",

    "amd64/emit.c",
    "amd64/isel.c",
    "amd64/sysv.c",
    "amd64/targ.c",

    "arm64/abi.c",
    "arm64/emit.c",
    "arm64/isel.c",
    "arm64/targ.c",

    "rv64/abi.c",
    "rv64/emit.c",
    "rv64/isel.c",
    "rv64/targ.c",
};
