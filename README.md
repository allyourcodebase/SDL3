# SDL3 Zig

SDL3 ported to the Zig build system.

# Dependencies

By default, SDL3 loads its dependencies at runtime, so most of the time you won't need to install anything extra on your system.

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
    alsa-lib
    libusb1
    libxkbcommon
    vulkan-validation-layers
    wayland
    xorg.libX11
    xorg.libXext
    xorg.libXi
  ];
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
    alsa-lib
    libusb1
    libxkbcommon
    vulkan-loader
    wayland
    xorg.libX11
    xorg.libXext
    xorg.libXi
  ]);
}
```

On Linux, you can force Wayland/X11 via the environment variable `SDL_VIDEODRIVER`.

# Platform Support

* [x] Linux
	* [-] Steam Deck (should work, but not yet tested)
* [ ] Windows
* [ ] macOS (help wanted!)
* [ ] Consoles (help wanted!)

If you're interested in adding build support for other operating systems or consoles, contributions are welcome! See `src/linux.zig` for an example of how to configure support for a new platform.

When adding support for a new platform, please follow the existing conventions around dependencies:
* SDL typically supports loading dependencies at runtime rather than linking with them directly
* This repo pulls dependencies in via Zig's build system instead of vendoring them where possible, placing sources in `/deps` is a last resort
* Cross compilation should be possible unless licensing restrictions forbid it

# Updating SDL

* Modify `build.zig.zon` to point to the desired SDL version
* If you get linker errors or missing headers relating to Wayland protocols, new Wayland protocols were added upstream. You can fix this by running `zig build wayland-scanner` with `wayland-scanner`.
* If you get any other linker errors or missing files, sources were added or renamed upstream, and you need to update `src/sdl.zon`.

# Updating Other Dependencies

This should rarely be necessary. If it is, you can update their version in `build.zig.zon`, and then double check if any manual work was done to get them to build in `deps`.

# TODO
* [ ] dynapi toggle
* [ ] consider support for outputting a shared library
* [ ] test cross compiling
* [ ] add build options for enabling/disabling subsystems, and changing so names
* [ ] allow using system versions of dependencies if specified as build flag
* [ ] examples
