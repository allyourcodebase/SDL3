const std = @import("std");
const sources = @import("src/sdl.zon");
const linux = @import("src/linux.zig");

pub fn build(b: *std.Build) !void {
    // Get the upstream source and build options
    const upstream = b.dependency("sdl", .{});
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create and install the library and it's headers
    const lib = b.addStaticLibrary(.{
        .name = "SDL3",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib.installHeadersDirectory(upstream.path("include/SDL3"), "SDL3", .{});
    b.installArtifact(lib);

    // Set the include path
    lib.addIncludePath(upstream.path("include"));
    lib.addIncludePath(upstream.path("src"));

    // Compile the generic sources
    lib.addCSourceFiles(.{
        .files = &sources.generic,
        .root = upstream.path("src"),
    });

    // Set up the build configuration
    const config = b.addConfigHeader(.{
        .style = .{ .cmake = upstream.path("include/build_config/SDL_build_config.h.cmake") },
        .include_path = "SDL_build_config.h",
    }, .{});
    lib.addConfigHeader(config);

    // Set the assert level, this logic mirrors the default SDL options with release safe added.
    // https://wiki.libsdl.org/SDL3/SDL_ASSERT_LEVEL
    switch (optimize) {
        .Debug, .ReleaseSafe => config.addValues(.{
            .SDL_DEFAULT_ASSERT_LEVEL_CONFIGURED = true,
            .SDL_DEFAULT_ASSERT_LEVEL = 2,
        }),
        .ReleaseSmall, .ReleaseFast => config.addValues(.{
            .SDL_DEFAULT_ASSERT_LEVEL_CONFIGURED = true,
            .SDL_DEFAULT_ASSERT_LEVEL = 1,
        }),
    }

    // Configure the build for the target platform
    switch (target.result.os.tag) {
        .linux => linux.build(b, lib, config, target.result),
        else => @panic("target not yet supported"),
    }

    // A build step for updating the cached Wayland protocols. This isn't built into the the normal
    // build process to avoid having to build the wayland-scanner and its dependencies from source,
    // instead you must have `wayland-scanner` available on your path when you update Wayland or to
    // a version of SDL that requires new Wayland protocols.
    {
        const update_wayland_protocols = b.addUpdateSourceFiles();
        const generate_wayland_protocols = b.step(
            "wayland-scanner",
            "Regenerate the required Wayland protocols.",
        );
        generate_wayland_protocols.dependOn(&update_wayland_protocols.step);

        for (@as([]const []const u8, &sources.wayland_protocols)) |xml| {
            const generate_header = b.addSystemCommand(&.{ "wayland-scanner", "client-header" });
            generate_header.addFileArg(upstream.path(b.pathJoin(&.{ "wayland-protocols", xml })));
            const header_name = b.fmt("{s}-client-protocol.h", .{std.fs.path.stem(xml)});
            const header = generate_header.addOutputFileArg(header_name);
            update_wayland_protocols.addCopyFileToSource(header, b.pathJoin(&.{
                "deps",
                "wayland",
                "protocols",
                header_name,
            }));

            const generate_source = b.addSystemCommand(&.{ "wayland-scanner", "private-code" });
            generate_source.addFileArg(upstream.path(b.pathJoin(&.{ "wayland-protocols", xml })));
            const source_name = b.fmt("{s}-client.c", .{std.fs.path.stem(xml)});
            const source = generate_source.addOutputFileArg(source_name);
            update_wayland_protocols.addCopyFileToSource(source, b.pathJoin(&.{
                "deps",
                "wayland",
                "protocols",
                source_name,
            }));
        }
    }
}
