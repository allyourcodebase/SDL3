const std = @import("std");
const build_zon = @import("../build.zig.zon");
const sources = @import("sdl.zon");
const root = @import("../build.zig");
const Subsystems = root.Subsystems;
const AllDrivers = root.Drivers;

pub fn build(
    b: *std.Build,
    target: std.Target,
    lib: *std.Build.Step.Compile,
    build_config_h: *std.Build.Step.ConfigHeader,
) void {
    _ = target;

    const upstream = b.dependency("sdl", .{});

    // Add the platform specific dependency include paths
    lib.addIncludePath(b.dependency("egl", .{}).path("api"));
    lib.addIncludePath(b.dependency("opengl", .{}).path("api"));

    // Link with the platform specific system libraries
    lib.root_module.linkFramework("CoreMedia", .{});
    lib.root_module.linkFramework("CoreVideo", .{});
    lib.root_module.linkFramework("Cocoa", .{});
    lib.root_module.linkFramework("UniformTypeIdentifiers", .{ .weak = true });
    lib.root_module.linkFramework("IOKit", .{});
    lib.root_module.linkFramework("ForceFeedback", .{});
    lib.root_module.linkFramework("Carbon", .{});
    lib.root_module.linkFramework("CoreAudio", .{});
    lib.root_module.linkFramework("AudioToolbox", .{});
    lib.root_module.linkFramework("AVFoundation", .{});
    lib.root_module.linkFramework("Foundation", .{});
    lib.root_module.linkFramework("GameController", .{});
    lib.root_module.linkFramework("Metal", .{});
    lib.root_module.linkFramework("QuartzCore", .{});
    lib.root_module.linkFramework("CoreHaptics", .{ .weak = true });

    const flags = &.{
        "-Wall",
        "-Wundef",
        "-Wfloat-conversion",
        "-Wshadow",
        "-Wno-unused-local-typedefs",
        "-Wimplicit-fallthrough",
        "-fno-strict-aliasing",
        // "-fvisibility=hidden",
        "-pthread",
        "-fobjc-arc",
        "-ObjC",
    };

    // Compile the generic ndd the platform specific sources
    lib.addCSourceFiles(.{
        .files = &(sources.generic ++ sources.darwin ++ sources.mac ++ sources.pthread),
        .root = upstream.path("src"),
        .flags = flags,
    });

    // Set the platform specific build config
    build_config_h.addValues(.{
        // Useful headers
        .HAVE_ALLOCA_H = 1,
        .HAVE_FLOAT_H = 1,
        .HAVE_INTTYPES_H = 1,
        .HAVE_LIMITS_H = 1,
        .HAVE_MATH_H = 1,
        .HAVE_SIGNAL_H = 1,
        .HAVE_STDARG_H = 1,
        .HAVE_STDDEF_H = 1,
        .HAVE_STDINT_H = 1,
        .HAVE_STDIO_H = 1,
        .HAVE_STDLIB_H = 1,
        .HAVE_STRING_H = 1,
        .HAVE_SYS_TYPES_H = 1,
        .HAVE_WCHAR_H = 1,

        // C library functions
        .HAVE_LIBC = 1,
        .HAVE_DLOPEN = 1,
        .HAVE_MALLOC = 1,
        .HAVE_GETENV = 1,
        .HAVE_GETHOSTNAME = 1,
        .HAVE_SETENV = 1,
        .HAVE_PUTENV = 1,
        .HAVE_UNSETENV = 1,
        .HAVE_ABS = 1,
        .HAVE_BCOPY = 1,
        .HAVE_MEMSET = 1,
        .HAVE_MEMCPY = 1,
        .HAVE_MEMMOVE = 1,
        .HAVE_MEMCMP = 1,
        .HAVE_STRLEN = 1,
        .HAVE_STRLCPY = 1,
        .HAVE_STRLCAT = 1,
        .HAVE_STRPBRK = 1,
        .HAVE_STRCHR = 1,
        .HAVE_STRRCHR = 1,
        .HAVE_STRSTR = 1,
        .HAVE_STRTOK_R = 1,
        .HAVE_STRTOL = 1,
        .HAVE_STRTOUL = 1,
        .HAVE_STRTOLL = 1,
        .HAVE_STRTOULL = 1,
        .HAVE_STRTOD = 1,
        .HAVE_ATOI = 1,
        .HAVE_ATOF = 1,
        .HAVE_STRCMP = 1,
        .HAVE_STRNCMP = 1,
        .HAVE_VSSCANF = 1,
        .HAVE_VSNPRINTF = 1,
        .HAVE_ACOS = 1,
        .HAVE_ACOSF = 1,
        .HAVE_ASIN = 1,
        .HAVE_ASINF = 1,
        .HAVE_ATAN = 1,
        .HAVE_ATANF = 1,
        .HAVE_ATAN2 = 1,
        .HAVE_ATAN2F = 1,
        .HAVE_CEIL = 1,
        .HAVE_CEILF = 1,
        .HAVE_COPYSIGN = 1,
        .HAVE_COPYSIGNF = 1,
        .HAVE_COS = 1,
        .HAVE_COSF = 1,
        .HAVE_EXP = 1,
        .HAVE_EXPF = 1,
        .HAVE_FABS = 1,
        .HAVE_FABSF = 1,
        .HAVE_FLOOR = 1,
        .HAVE_FLOORF = 1,
        .HAVE_FMOD = 1,
        .HAVE_FMODF = 1,
        .HAVE_ISINF = 1,
        .HAVE_ISINF_FLOAT_MACRO = 1,
        .HAVE_ISNAN = 1,
        .HAVE_ISNAN_FLOAT_MACRO = 1,
        .HAVE_LOG = 1,
        .HAVE_LOGF = 1,
        .HAVE_LOG10 = 1,
        .HAVE_LOG10F = 1,
        .HAVE_LROUND = 1,
        .HAVE_LROUNDF = 1,
        .HAVE_MODF = 1,
        .HAVE_MODFF = 1,
        .HAVE_POW = 1,
        .HAVE_POWF = 1,
        .HAVE_ROUND = 1,
        .HAVE_ROUNDF = 1,
        .HAVE_SCALBN = 1,
        .HAVE_SCALBNF = 1,
        .HAVE_SIN = 1,
        .HAVE_SINF = 1,
        .HAVE_SQRT = 1,
        .HAVE_SQRTF = 1,
        .HAVE_TAN = 1,
        .HAVE_TANF = 1,
        .HAVE_TRUNC = 1,
        .HAVE_TRUNCF = 1,
        .HAVE_SIGACTION = 1,
        .HAVE_SETJMP = 1,
        .HAVE_NANOSLEEP = 1,
        .HAVE_GMTIME_R = 1,
        .HAVE_LOCALTIME_R = 1,
        .HAVE_NL_LANGINFO = 1,
        .HAVE_SYSCONF = 1,
        .HAVE_SYSCTLBYNAME = 1,

        // #if defined(__has_include) && (defined(__i386__) || defined(__x86_64))
        // # if !__has_include(<immintrin.h>)
        .SDL_DISABLE_AVX = 1,
        // # endif
        // #endif

        // #if (MAC_OS_X_VERSION_MAX_ALLOWED >= 1070)
        .HAVE_O_CLOEXEC = 1,
        // #endif

        .HAVE_GCC_ATOMICS = 1,

        // Enable various audio drivers
        .SDL_AUDIO_DRIVER_COREAUDIO = 1,
        .SDL_AUDIO_DRIVER_DISK = 1,
        .SDL_AUDIO_DRIVER_DUMMY = 1,

        // Enable various input drivers
        .SDL_JOYSTICK_HIDAPI = 1,
        .SDL_JOYSTICK_IOKIT = 1,
        .SDL_JOYSTICK_VIRTUAL = 1,
        .SDL_HAPTIC_IOKIT = 1,

        // The MFI controller support requires ARC Objective C runtime
        //#if MAC_OS_X_VERSION_MIN_REQUIRED >= 1080 && !defined(__i386__)
        .SDL_JOYSTICK_MFI = 1,
        //#endif

        // Enable various process implementations
        .SDL_PROCESS_POSIX = 1,

        // Enable the dummy sensor driver
        .SDL_SENSOR_DUMMY = 1,

        // Enable various shared object loading systems
        .SDL_LOADSO_DLOPEN = 1,

        // Enable various threading systems
        .SDL_THREAD_PTHREAD = 1,
        .SDL_THREAD_PTHREAD_RECURSIVE_MUTEX = 1,

        // Enable various RTC system
        .SDL_TIME_UNIX = 1,

        // Enable various timer systems
        .SDL_TIMER_UNIX = 1,

        // Enable various video drivers
        .SDL_VIDEO_DRIVER_COCOA = 1,
        .SDL_VIDEO_DRIVER_DUMMY = 1,
        .SDL_VIDEO_DRIVER_OFFSCREEN = 1,
        // .SDL_VIDEO_DRIVER_X11 = 0,
        // .SDL_VIDEO_DRIVER_X11_DYNAMIC = "/opt/X11/lib/libX11.6.dylib",
        // .SDL_VIDEO_DRIVER_X11_DYNAMIC_XEXT = "/opt/X11/lib/libXext.6.dylib",
        // .SDL_VIDEO_DRIVER_X11_DYNAMIC_XINPUT2 = "/opt/X11/lib/libXi.6.dylib",
        // .SDL_VIDEO_DRIVER_X11_DYNAMIC_XRANDR = "/opt/X11/lib/libXrandr.2.dylib",
        // .SDL_VIDEO_DRIVER_X11_DYNAMIC_XSS = "/opt/X11/lib/libXss.1.dylib",
        // .SDL_VIDEO_DRIVER_X11_XDBE = 1,
        // .SDL_VIDEO_DRIVER_X11_XRANDR = 1,
        // .SDL_VIDEO_DRIVER_X11_XSCRNSAVER = 1,
        // .SDL_VIDEO_DRIVER_X11_XSHAPE = 1,
        // .SDL_VIDEO_DRIVER_X11_HAS_XKBLOOKUPKEYSYM = 1,

        // #ifdef MAC_OS_X_VERSION_10_8
        // No matter the versions targeted, this is the 10.8 or later SDK, so you have
        //  to use the external Xquartz, which is a more modern Xlib. Previous SDKs
        //  used an older Xlib.
        // .SDL_VIDEO_DRIVER_X11_XINPUT2 = 1,
        // .SDL_VIDEO_DRIVER_X11_SUPPORTS_GENERIC_EVENTS = 1,
        // #endif

        .SDL_VIDEO_RENDER_OGL = 1,
        .SDL_VIDEO_RENDER_OGL_ES2 = 1,

        // Metal only supported on 64-bit architectures with 10.11+
        // #if TARGET_RT_64_BIT && (MAC_OS_X_VERSION_MAX_ALLOWED >= 101100)
        .SDL_PLATFORM_SUPPORTS_METAL = 1,
        // #endif

        // #ifdef SDL_PLATFORM_SUPPORTS_METAL
        .SDL_VIDEO_RENDER_METAL = 1,
        // #endif

        // Enable OpenGL support
        .SDL_VIDEO_OPENGL = 1,
        .SDL_VIDEO_OPENGL_ES2 = 1,
        .SDL_VIDEO_OPENGL_EGL = 1,
        .SDL_VIDEO_OPENGL_CGL = 1,
        .SDL_VIDEO_OPENGL_GLX = 1,

        // Enable Vulkan and Metal support
        // #ifdef SDL_PLATFORM_SUPPORTS_METAL
        .SDL_VIDEO_METAL = 1,
        .SDL_GPU_METAL = 1,
        .SDL_VIDEO_VULKAN = 1,
        .SDL_GPU_VULKAN = 1,
        .SDL_VIDEO_RENDER_GPU = 1,
        // #endif

        // Enable system power support
        .SDL_POWER_MACOSX = 1,

        // enable filesystem support
        .SDL_FILESYSTEM_COCOA = 1,
        .SDL_FSOPS_POSIX = 1,

        // enable camera support
        .SDL_CAMERA_DRIVER_COREMEDIA = 1,
        .SDL_CAMERA_DRIVER_DUMMY = 1,

        // Enable assembly routines
        // #ifdef __ppc__
        // .SDL_ALTIVEC_BLITTERS = 1,
        // #endif

        // Unused
        .SDL_STORAGE_STEAM = 0,
        .SDL_AUDIO_DRIVER_ALSA_DYNAMIC = "",
        .SDL_AUDIO_DRIVER_JACK_DYNAMIC = "",
        .SDL_AUDIO_DRIVER_PIPEWIRE_DYNAMIC = "",
        .SDL_AUDIO_DRIVER_PULSEAUDIO_DYNAMIC = "",
        .SDL_AUDIO_DRIVER_SNDIO_DYNAMIC = "",
        .SDL_LIBUSB_DYNAMIC = "",
        .SDL_UDEV_DYNAMIC = "",
        .SDL_VIDEO_DRIVER_KMSDRM_DYNAMIC = "",
        .SDL_VIDEO_DRIVER_KMSDRM_DYNAMIC_GBM = "",
        .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC = "",
        .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_CURSOR = "",
        .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_EGL = "",
        .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_LIBDECOR = "",
        .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_XKBCOMMON = "",
        .SDL_VIDEO_DRIVER_X11_DYNAMIC = "",
        .SDL_VIDEO_DRIVER_X11_DYNAMIC_XCURSOR = "",
        .SDL_VIDEO_DRIVER_X11_DYNAMIC_XEXT = "",
        .SDL_VIDEO_DRIVER_X11_DYNAMIC_XFIXES = "",
        .SDL_VIDEO_DRIVER_X11_DYNAMIC_XINPUT2 = "",
        .SDL_VIDEO_DRIVER_X11_DYNAMIC_XRANDR = "",
        .SDL_VIDEO_DRIVER_X11_DYNAMIC_XSS = "",
        .SDL_CAMERA_DRIVER_PIPEWIRE_DYNAMIC = "",
        .SDL_LIBDECOR_VERSION_MAJOR = "",
        .SDL_LIBDECOR_VERSION_MINOR = "",
        .SDL_LIBDECOR_VERSION_PATCH = "",
    });
}
