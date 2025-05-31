# SDL3 Zig

SDL3 ported to the Zig build system.

# Setup

You can add SDL3 to your project like this by updating `build.zig.zon` from the command line:
```sh
zig fetch --save <url-of-this-repo>
```

Adding SDL3 to `build.zig`:
```zig
const sdl = b.dependency("sdl", .{
    .optimize = optimize,
    .target = target,
});
exe.linkLibrary(sdl.artifact("SDL3"));
```

And then using it's C API from Zig:
```zig
const c = @import("c.zig");
if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
    panic("SDL_Init failed: {?s}\n", .{c.SDL_GetError()});
}
defer c.SDL_Quit();
```

If this fails, SDL likely failed to find your video drivers. Keep in mind that it's not linking with them, it's loading them at runtime from your library path, so this can be a problem on platforms like like NixOS that don't expose all installed libraries this way by default.

Here's a `shell.nix` for a Vulkan app as an example of running an SDL application on NixOS with either X11 or Wayland:
```
{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  packages = with pkgs; [
    vulkan-validation-layers
  ];
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
    alsa-lib
    libdecor
    libusb1
    libxkbcommon
    vulkan-loader
    wayland
    xorg.libX11
    xorg.libXext
    xorg.libXi
    udev
  ]);
}

```

Note that on Linux, you can force `wayland`/`x11` via the environment variable `SDL_VIDEODRIVER`.

# Target Configuration

Provides a default configuration for common targets:
* [x] Linux
  * [-] Steam Deck (should work, but not yet tested)
* [x] Windows
* [ ] macOS (help wanted!)
* [ ] Consoles (help wanted!)
* [ ] Emscripten (help wanted!)

You can override this by setting `default_target_config` to `false` and then providing your own configuration, this is typically only necessary when your platform doesn't yet have a default configuration:
```zig
const sdl = b.dependency("sdl", .{
    .optimize = optimize,
    .target = target,
    .default_target_config = false,
});
const sdl_lib = sdl.artifact("SDL3");
sdl_lib.addIncludePath(...); // Path to your `SDL_build_config.h`, see `windows.zig` for an example of generating this
```

Any other necessary tweaks such as turning of linking with libc, linking with dependencies, or adding other headers can be done here.

If you're interested in adding default configuration for additional targets, contributions are welcome! See `src/linux.zig` or `src/windows.zig` for examples of how this works.

When adding support for a new target:
* Mimic the default SDL configuration for the target as closely as possible (e.g. if SDL defaults to loading dependencies at runtime, the added configuration should too)
* When possible, pull dependencies in via the build system rather than vendoring them. Vendoring deps in `/deps` is a last resort, anything added here should include a README explaining why it couldn't be pulled in via the build system and licensing information.
* Cross compilation to all targets should be possible unless forbidden by licensing.

# Updating SDL

* Modify `build.zig.zon` to point to the desired SDL version
* If you get linker errors or missing headers relating to Wayland protocols on Linux, new Wayland protocols were added upstream. You can fix this by running `zig build wayland-scanner` with `wayland-scanner`.
* If you get any other linker errors or missing files, sources were added or renamed upstream, and you need to update `src/sdl.zon`.

# Updating Dependencies

This should rarely be necessary. When it is, you can update their version in `build.zig.zon` if present, and any relevant files in `/deps` if present.

# TODO
* [ ] why is rpi disabled
* [ ] enable glx
* [ ] consider allow using system versions of dependencies if specified as build flag
* [ ] cross as gnu vs msvc vs neither?
* [ ] examples
* [ ] test on steam deck
