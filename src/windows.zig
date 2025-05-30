const std = @import("std");
const build_zon = @import("../build.zig.zon");
const sources = @import("sdl.zon");

pub fn build(
    b: *std.Build,
    lib: *std.Build.Step.Compile,
    config: *std.Build.Step.ConfigHeader,
) void {
    const upstream = b.dependency("sdl", .{});

    // Provide upstream headers that don't require any special handling
    lib.addIncludePath(b.dependency("egl", .{}).path("api"));
    lib.addIncludePath(b.dependency("opengl", .{}).path("api"));

    lib.addCSourceFiles(.{
        .files = &sources.windows,
        .root = upstream.path("src"),
    });

    lib.linkSystemLibrary("kernel32");
    lib.linkSystemLibrary("user32");
    lib.linkSystemLibrary("gdi32");
    lib.linkSystemLibrary("winmm");
    lib.linkSystemLibrary("imm32");
    lib.linkSystemLibrary("ole32");
    lib.linkSystemLibrary("oleaut32");
    lib.linkSystemLibrary("version");
    lib.linkSystemLibrary("uuid");
    lib.linkSystemLibrary("advapi32");
    lib.linkSystemLibrary("setupapi");
    lib.linkSystemLibrary("shell32");

    config.addValues(.{
        .HAVE_GCC_ATOMICS = true,

        .HAVE_DDRAW_H = true,
        .HAVE_DINPUT_H = true,
        .HAVE_DSOUND_H = true,
        .HAVE_DXGI_H = true,
        .HAVE_XINPUT_H = true,
        .HAVE_DXGI1_6_H = true,
        .HAVE_D3D11_H = true,
        .HAVE_ROAPI_H = true,
        .HAVE_SHELLSCALINGAPI_H = true,

        .HAVE_MMDEVICEAPI_H = true,
        .HAVE_AUDIOCLIENT_H = true,
        .HAVE_TPCSHRD_H = true,
        .HAVE_SENSORSAPI_H = true,

        .HAVE_LIBC = true,

        // Useful headers
        .HAVE_FLOAT_H = true,
        .HAVE_LIMITS_H = true,
        .HAVE_MATH_H = true,
        .HAVE_SIGNAL_H = true,
        .HAVE_STDARG_H = true,
        .HAVE_STDDEF_H = true,
        .HAVE_STDIO_H = true,
        .HAVE_STDLIB_H = true,
        .HAVE_STRING_H = true,
        .HAVE_WCHAR_H = true,

        // C library functions
        .HAVE_MALLOC = true,
        .HAVE_ABS = true,
        .HAVE_MEMSET = true,
        .HAVE_MEMCPY = true,
        .HAVE_MEMMOVE = true,
        .HAVE_MEMCMP = true,
        .HAVE_STRLEN = true,
        .HAVE__STRREV = true,
        .HAVE_STRCHR = true,
        .HAVE_STRRCHR = true,
        .HAVE_STRSTR = true,
        .HAVE_STRTOL = true,
        .HAVE_STRTOUL = true,
        .HAVE_STRTOD = true,
        .HAVE_ATOI = true,
        .HAVE_ATOF = true,
        .HAVE_STRCMP = true,
        .HAVE_STRNCMP = true,
        .HAVE_STRPBRK = true,
        .HAVE_VSSCANF = true,
        .HAVE_VSNPRINTF = true,
        .HAVE_ACOS = true,
        .HAVE_ASIN = true,
        .HAVE_ATAN = true,
        .HAVE_ATAN2 = true,
        .HAVE_CEIL = true,
        .HAVE_COS = true,
        .HAVE_EXP = true,
        .HAVE_FABS = true,
        .HAVE_FLOOR = true,
        .HAVE_FMOD = true,
        .HAVE_ISINF = true,
        .HAVE_ISINF_FLOAT_MACRO = true,
        .HAVE_ISNAN = true,
        .HAVE_ISNAN_FLOAT_MACRO = true,
        .HAVE_LOG = true,
        .HAVE_LOG10 = true,
        .HAVE_POW = true,
        .HAVE_SIN = true,
        .HAVE_SQRT = true,
        .HAVE_TAN = true,
        .HAVE_ACOSF = true,
        .HAVE_ASINF = true,
        .HAVE_ATANF = true,
        .HAVE_ATAN2F = true,
        .HAVE_CEILF = true,
        .HAVE__COPYSIGN = true,
        .HAVE_COSF = true,
        .HAVE_EXPF = true,
        .HAVE_FABSF = true,
        .HAVE_FLOORF = true,
        .HAVE_FMODF = true,
        .HAVE_LOGF = true,
        .HAVE_LOG10F = true,
        .HAVE_POWF = true,
        .HAVE_SINF = true,
        .HAVE_SQRTF = true,
        .HAVE_TANF = true,
        .HAVE_STRTOLL = true,
        .HAVE_STRTOULL = true,
        .HAVE_LROUND = true,
        .HAVE_LROUNDF = true,
        .HAVE_ROUND = true,
        .HAVE_ROUNDF = true,
        .HAVE_SCALBN = true,
        .HAVE_SCALBNF = true,
        .HAVE_TRUNC = true,
        .HAVE_TRUNCF = true,
        .HAVE__FSEEKI64 = true,

        // Enable various audio drivers
        .SDL_AUDIO_DRIVER_WASAPI = true,
        .SDL_AUDIO_DRIVER_DSOUND = true,
        .SDL_AUDIO_DRIVER_DISK = true,
        .SDL_AUDIO_DRIVER_DUMMY = true,

        // Enable various input drivers
        .SDL_JOYSTICK_DINPUT = true,
        .SDL_JOYSTICK_HIDAPI = true,
        .SDL_JOYSTICK_RAWINPUT = true,
        .SDL_JOYSTICK_VIRTUAL = true,
        .SDL_JOYSTICK_XINPUT = true,
        .SDL_HAPTIC_DINPUT = true,

        // Enable various process implementations
        .SDL_PROCESS_WINDOWS = true,

        // Enable the sensor driver
        .SDL_SENSOR_WINDOWS = true,

        // Enable various shared object loading systems
        .SDL_LOADSO_WINDOWS = true,

        // Enable various threading systems
        .SDL_THREAD_GENERIC_COND_SUFFIX = true,
        .SDL_THREAD_GENERIC_RWLOCK_SUFFIX = true,
        .SDL_THREAD_WINDOWS = true,

        // Enable RTC system
        .SDL_TIME_WINDOWS = true,

        // Enable various timer systems
        .SDL_TIMER_WINDOWS = true,

        // Enable various video drivers
        .SDL_VIDEO_DRIVER_DUMMY = true,
        .SDL_VIDEO_DRIVER_OFFSCREEN = true,
        .SDL_VIDEO_DRIVER_WINDOWS = true,
        .SDL_VIDEO_RENDER_D3D = true,
        .SDL_VIDEO_RENDER_D3D11 = true,
        .SDL_VIDEO_RENDER_D3D12 = true,

        // Enable OpenGL support
        .SDL_VIDEO_OPENGL = true,
        .SDL_VIDEO_OPENGL_WGL = true,
        .SDL_VIDEO_RENDER_OGL = true,
        .SDL_VIDEO_RENDER_OGL_ES2 = true,
        .SDL_VIDEO_OPENGL_ES2 = true,
        .SDL_VIDEO_OPENGL_EGL = true,

        // Enable Vulkan support
        .SDL_VIDEO_VULKAN = true,
        .SDL_VIDEO_RENDER_VULKAN = true,

        // Enable GPU support
        .SDL_GPU_D3D11 = true,
        .SDL_GPU_D3D12 = true,
        .SDL_GPU_VULKAN = true,
        .SDL_VIDEO_RENDER_GPU = true,

        // Enable system power support
        .SDL_POWER_WINDOWS = true,

        // Enable filesystem support
        .SDL_FILESYSTEM_WINDOWS = true,
        .SDL_FSOPS_WINDOWS = true,

        // Enable the camera driver
        .SDL_CAMERA_DRIVER_MEDIAFOUNDATION = true,
        .SDL_CAMERA_DRIVER_DUMMY = true,

        // Enable Steam storage
        .SDL_STORAGE_STEAM = true,

        // Supporting these input drivers requires the winrt headers when cross compiling, which is
        // a bit annoying for cross compilation as Microsoft doesn't make the license on these very
        // clear. In practice they don't seem to do too much that they other input drivers don't
        // already do.
        .HAVE_WINDOWS_GAMING_INPUT_H = false
        .HAVE_GAMEINPUT_H = false

        // Unused
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
