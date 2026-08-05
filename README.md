# SDL2 for Zig

This is a fork of [SDL2](https://www.libsdl.org/), packaged for [Zig](https://ziglang.org).
Unnecessary files have been deleted, and the build system has been replaced with `build.zig`.

SDL2 is in maintenance mode and will eventually be retired. The newer SDL3 can be found on
the `main` branch.

## Getting started

### Linking SDL2 to your project

Fetch SDL and add to your `build.zig.zon` :
```bash
zig fetch --save=SDL git+https://github.com/allyourcodebase/SDL#SDL2
```

Add this to your `build.zig` :
```zig
const sdl_dep = b.dependency("SDL", .{
    .optimize = .ReleaseFast,
    .target = target,
});
exe.linkLibrary(sdl_dep.artifact("SDL2"));
```
