const std = @import("std");
const build_zon = @import("../build.zig.zon");
const sources = @import("sdl.zon");

pub fn build(
    b: *std.Build,
    lib: *std.Build.Step.Compile,
    config: *std.Build.Step.ConfigHeader,
    target: std.Target,
) void {
    const upstream = b.dependency("sdl", .{});

    // Provide the D-Bus headers
    {
        const dbus = b.dependency("dbus", .{});
        lib.addIncludePath(dbus.path("."));

        const version_string = build_zon.dependencies.dbus.version;
        const version = comptime std.SemanticVersion.parse(version_string) catch unreachable;
        std.debug.assert(target.cTypeByteSize(.short) == 2);
        std.debug.assert(target.cTypeByteSize(.int) == 4);
        const dbus_config = b.addConfigHeader(
            .{
                .style = .{ .autoconf_at = dbus.path("dbus/dbus-arch-deps.h.in") },
                .include_path = "dbus/dbus-arch-deps.h",
            },
            .{
                .DBUS_INT32_TYPE = "int",
                .DBUS_INT16_TYPE = "short",
                .DBUS_SIZEOF_VOID_P = target.ptrBitWidth() / 8,

                .DBUS_MAJOR_VERSION = @as(i64, version.major),
                .DBUS_MINOR_VERSION = @as(i64, version.minor),
                .DBUS_MICRO_VERSION = @as(i64, version.patch),
                .DBUS_VERSION = version_string,
            },
        );

        if (target.cTypeByteSize(.int) == 2) {
            dbus_config.addValues(.{
                .DBUS_INT16_TYPE = "int",
            });
        } else if (target.cTypeByteSize(.short) == 2) {
            dbus_config.addValues(.{
                .DBUS_INT16_TYPE = "short",
            });
        } else {
            @panic("Could not find a 16-bit integer type");
        }

        if (target.cTypeByteSize(.int) == 4) {
            dbus_config.addValues(.{
                .DBUS_INT32_TYPE = "int",
            });
        } else if (target.cTypeByteSize(.long) == 4) {
            dbus_config.addValues(.{
                .DBUS_INT32_TYPE = "long",
            });
        } else if (target.cTypeByteSize(.longlong) == 4) {
            dbus_config.addValues(.{
                .DBUS_INT32_TYPE = "long long",
            });
        } else {
            @panic("Could not find a 32-bit integer type");
        }

        if (target.cTypeByteSize(.int) == 8) {
            dbus_config.addValues(.{
                .DBUS_INT64_TYPE = "int",
                .DBUS_INT64_CONSTANT = "(val)",
                .DBUS_UINT64_CONSTANT = "(val##U)",
                .DBUS_INT64_MODIFIER = "",
            });
        } else if (target.cTypeByteSize(.long) == 8) {
            dbus_config.addValues(.{
                .DBUS_INT64_TYPE = "long",
                .DBUS_INT64_CONSTANT = "(val##L)",
                .DBUS_UINT64_CONSTANT = "(val##UL)",
                .DBUS_INT64_MODIFIER = "l",
            });
        } else if (target.cTypeByteSize(.longlong) == 8) {
            dbus_config.addValues(.{
                .DBUS_INT64_TYPE = "long long",
                .DBUS_INT64_CONSTANT = "(val##LL)",
                .DBUS_UINT64_CONSTANT = "(val##ULL)",
                .DBUS_INT64_MODIFIER = "ll",
            });
        } else {
            @panic("Could not find a 64-bit integer type");
        }

        lib.addConfigHeader(dbus_config);
    }

    // Provide the IBus headers
    {
        // The headers are here
        lib.addIncludePath(b.dependency("ibus", .{}).path("src"));

        // They depend on the GLib headers, which require some configuration
        lib.addIncludePath(b.path("deps/glib/upstream/include"));
        lib.addIncludePath(b.path("deps/glib/upstream/include/glib"));
        lib.addIncludePath(b.path("deps/glib/upstream/include/gmodule"));
        lib.addIncludePath(b.path("deps/glib/cached/include"));
        lib.addIncludePath(b.path("deps/glib/cached/include/glib"));
        lib.addIncludePath(b.path("deps/glib/cached/include/gmodule"));

        const glib_config = b.addConfigHeader(.{
            .style = .{ .cmake = b.path("deps/glib/glibconfig.h.in") },
            .include_path = "glibconfig.h",
        }, .{});
        lib.addConfigHeader(glib_config);

        // Configure glib
        {
            // Defines
            const version_string = @import("../deps/glib/info.zon").version;
            const version = comptime std.SemanticVersion.parse(version_string) catch unreachable;
            glib_config.addValues(.{
                .GLIB_HAVE_ALLOCA_H = true,
                .GLIB_USING_SYSTEM_PRINTF = true,
                // Shows up as empty instead of 0, but never referenced anyway
                .G_HAVE_GROWING_STACK = "0",
                .G_ATOMIC_LOCK_FREE = true,
                .G_HAVE_FREE_SIZED = true,
                .GLIB_MAJOR_VERSION = @as(i64, version.major),
                .GLIB_MINOR_VERSION = @as(i64, version.minor),
                .GLIB_MICRO_VERSION = @as(i64, version.patch),
                // Always the same on Linux
                .g_dir_separator = "/",
                .g_searchpath_separator = ":",
                .g_pid_type = "int",
                .g_pid_format = "i",
                .g_module_suffix = "so",
                // These are hard coded in the meson build
                .g_pollin = "1",
                .g_pollout = "4",
                .g_pollpri = "2",
                .g_pollhup = "16",
                .g_pollerr = "8",
                .g_pollnval = "32",
                // These are the values I got when building form source. I would expect them to be
                // the same for all Linux targets, but I'm not actually sure how they were
                // generated.
                .g_af_unix = "1",
                .g_af_inet = "2",
                .g_af_inet6 = "10",
                .g_msg_oob = "1",
                .g_msg_peek = "2",
                .g_msg_dontroute = "4",
            });

            // Integer sizes
            std.debug.assert(target.cTypeByteSize(.short) == 2);
            std.debug.assert(target.cTypeByteSize(.int) == 4);
            glib_config.addValues(.{
                .gint16 = "short",
                .gint16_modifier = "h",
                .gint16_format = "hi",
                .guint16_format = "hu",
                .gint32 = "int",
                .gint32_modifier = "",
                .gint32_format = "i",
                .guint32_format = "u",
            });
            if (target.cTypeByteSize(.int) == 8) {
                glib_config.addValues(.{
                    .glib_extension = "",
                    .gint64 = "int",
                    .gint64_constant = "(val)",
                    .guint64_constant = "(val##U)",
                    .gint64_modifier = "",
                    .gint64_format = "i",
                    .guint64_format = "u",
                });
            } else if (target.cTypeByteSize(.long) == 8) {
                glib_config.addValues(.{
                    .glib_extension = "",
                    .gint64 = "long",
                    .gint64_constant = "(val##L)",
                    .guint64_constant = "(val##UL)",
                    .gint64_modifier = "l",
                    .gint64_format = "li",
                    .guint64_format = "lu",
                });
            } else if (target.cTypeByteSize(.longlong) == 8) {
                glib_config.addValues(.{
                    .glib_extension = "",
                    .gint64 = "long long",
                    .gint64_constant = "(val##LL)",
                    .guint64_constant = "(val##ULL)",
                    .gint64_modifier = "ll",
                    .gint64_format = "lli",
                    .guint64_format = "llu",
                });
            } else {
                @panic("Could not find a 64-bit integer type");
            }
            if (target.cTypeBitSize(.int) == target.ptrBitWidth()) {
                glib_config.addValues(.{
                    .glib_size_type_define = "int",
                    .gsize_modifier = "u",
                    .gssize_modifier = "",
                    .gsize_format = "u",
                    .gssize_format = "i",
                    .glib_msize_type = "INT",
                    .g_pollfd_format = "%i",
                    .glib_gpi_cast = "(gint)",
                    .glib_gpui_cast = "(guint)",
                    .glib_intptr_type_define = "int",
                    .gintptr_modifier = "",
                    .gintptr_format = "i",
                    .guintptr_format = "u",
                });
            } else if (target.cTypeBitSize(.long) == target.ptrBitWidth()) {
                glib_config.addValues(.{
                    .glib_size_type_define = "long",
                    .gsize_modifier = "l",
                    .gssize_modifier = "l",
                    .gsize_format = "lu",
                    .gssize_format = "li",
                    .glib_msize_type = "LONG",
                    .g_pollfd_format = "%d",
                    .glib_gpi_cast = "(glong)",
                    .glib_gpui_cast = "(gulong)",
                    .glib_intptr_type_define = "long",
                    .gintptr_modifier = "l",
                    .gintptr_format = "li",
                    .guintptr_format = "lu",
                });
            } else {
                // Upstream doesn't have required typedefs for long long so that's not an option
                @panic("Could not find a pointer sized integer type");
            }
            glib_config.addValues(.{
                .glib_void_p = target.ptrBitWidth() / 8,
                .glib_long = target.cTypeByteSize(.long),
                .glib_size_t = target.ptrBitWidth() / 8,
                .glib_ssize_t = target.ptrBitWidth() / 8,
            });

            // Endianness
            const endianness = std.Target.Cpu.Arch.endian(target.cpu.arch);
            glib_config.addValues(.{
                .glib_os = "#define G_OS_UNIX",
                .glib_vacopy = "#define G_VA_COPY_AS_ARRAY 1",
                .g_threads_impl_def = "POSIX",
                .g_bs_native = switch (endianness) {
                    .little => "LE",
                    .big => "BE",
                },
                .g_bs_alien = switch (endianness) {
                    .little => "BE",
                    .big => "LE",
                },
                .glongbits = target.cTypeBitSize(.long),
                .gintbits = target.cTypeBitSize(.int),
                .gsizebits = target.ptrBitWidth(),
                .g_byte_order = switch (endianness) {
                    .little => "G_LITTLE_ENDIAN",
                    .big => "G_BIG_ENDIAN",
                },
            });
        }

        lib.addConfigHeader(b.addConfigHeader(.{
            .style = .{
                .autoconf_at = b.path("deps/glib/upstream/include/glib/gversionmacros.h.in"),
            },
            .include_path = "glib/gversionmacros.h",
        }, .{
            .GLIB_VERSIONS = @embedFile("../deps/glib/glib_versions.h"),
        }));

        lib.addIncludePath(b.path("deps/glib/include"));
    }

    // Provide the X11 headers
    {
        const x11 = b.dependency("x11", .{});

        lib.addIncludePath(x11.path("include"));

        lib.addConfigHeader(b.addConfigHeader(.{
            .style = .{ .autoconf_undef = x11.path("include/X11/XlibConf.h.in") },
            .include_path = "X11/XlibConf.h",
        }, .{
            .XTHREADS = true,
            .XUSE_MTSAFE_API = true,
        }));
    }

    // Provide the Xcursor headers
    {
        const xcursor = b.dependency("xcursor", .{});
        const version_string = build_zon.dependencies.xcursor.version;
        const version = comptime std.SemanticVersion.parse(version_string) catch unreachable;
        lib.addConfigHeader(b.addConfigHeader(.{
            .style = .{ .autoconf_undef = xcursor.path("include/X11/Xcursor/Xcursor.h.in") },
            .include_path = "X11/Xcursor/Xcursor.h",
        }, .{
            .XCURSOR_LIB_MAJOR = @as(i64, version.major),
            .XCURSOR_LIB_MINOR = @as(i64, version.minor),
            .XCURSOR_LIB_REVISION = @as(i64, version.patch),
        }));
    }

    // Provide the necessary parts of Wayland
    {
        // Fetch the upstream source
        const wayland = b.dependency("wayland", .{});

        // Provide the headers
        lib.addIncludePath(wayland.path("src"));
        lib.addIncludePath(wayland.path("cursor"));
        lib.addIncludePath(wayland.path("egl"));

        // Provide the config header
        const version_string = build_zon.dependencies.wayland.version;
        const version = comptime std.SemanticVersion.parse(version_string) catch unreachable;
        lib.addConfigHeader(b.addConfigHeader(.{
            .style = .{ .cmake = wayland.path("src/wayland-version.h.in") },
            .include_path = "wayland-version.h",
        }, .{
            .WAYLAND_VERSION_MAJOR = @as(i64, version.major),
            .WAYLAND_VERSION_MINOR = @as(i64, version.minor),
            .WAYLAND_VERSION_MICRO = @as(i64, version.patch),
            .WAYLAND_VERSION = version_string,
        }));

        // Provide the cached generated protocols
        lib.addIncludePath(b.path("deps/wayland/protocols"));
        for (@as([]const []const u8, &sources.wayland_protocols)) |xml| {
            lib.addCSourceFiles(.{
                .files = &.{b.fmt("{s}-client.c", .{std.fs.path.stem(xml)})},
                .root = b.path("deps/wayland/protocols"),
            });
        }
    }

    // Add the libdecor headers and set its version in SDL
    {
        lib.addIncludePath(b.dependency("decor", .{}).path("src"));
        const version_string = build_zon.dependencies.decor.version;
        const version = comptime std.SemanticVersion.parse(version_string) catch unreachable;
        config.addValues(.{
            .SDL_LIBDECOR_VERSION_MAJOR = @as(i64, version.major),
            .SDL_LIBDECOR_VERSION_MINOR = @as(i64, version.minor),
            .SDL_LIBDECOR_VERSION_PATCH = @as(i64, version.patch),
        });
    }

    // Provide the liburing headers
    {
        lib.addIncludePath(b.path("deps/liburing/include"));
        lib.addConfigHeader(b.addConfigHeader(.{
            .style = .{ .autoconf_undef = b.path("deps/liburing/compat.h.in") },
            .include_path = "liburing/compat.h",
        }, .{
            // Recent kernels should always have these features, so they're hard coded to true for
            // now, but this can be made more flexible in the future if needed.
            .HAS_KERNEL_RWF_T = true,
            .HAS_KERNEL_TIMESPEC = true,
            .HAS_OPENAT_2 = true,
            .HAS_SYS_STAT = true,
            .HAS_FUTEX_WAITV = true,
            .HAS_IDTYPE_T = true,
        }));
        const version_string = build_zon.dependencies.decor.version;
        const version = comptime std.SemanticVersion.parse(version_string) catch unreachable;
        lib.addConfigHeader(b.addConfigHeader(.{
            .style = .{ .autoconf_undef = b.path("deps/liburing/io_uring_version.h.in") },
            .include_path = "liburing/io_uring_version.h",
        }, .{
            .IO_URING_VERSION_MAJOR = @as(i64, version.major),
            .IO_URING_VERSION_MINOR = @as(i64, version.minor),
        }));
    }

    // Provide the pipewire headers
    {
        const pipewire = b.dependency("pipewire", .{});
        lib.addIncludePath(pipewire.path("spa/include"));
        lib.addIncludePath(pipewire.path("src"));
        const version_string = build_zon.dependencies.pipewire.version;
        const api_version_string = build_zon.dependencies.pipewire.api_version;
        const version = comptime std.SemanticVersion.parse(version_string) catch unreachable;
        lib.addConfigHeader(b.addConfigHeader(.{
            .style = .{ .autoconf_at = pipewire.path("src/pipewire/version.h.in") },
            .include_path = "pipewire/version.h",
        }, .{
            .PIPEWIRE_VERSION_MAJOR = @as(i64, version.major),
            .PIPEWIRE_VERSION_MINOR = @as(i64, version.minor),
            .PIPEWIRE_VERSION_MICRO = @as(i64, version.patch),
            .PIPEWIRE_API_VERSION = api_version_string,
        }));
    }

    // Provide the pulseaudio headers
    {
        @setEvalBranchQuota(2000);
        // Workaround for cross compilation, see comment in `build.zig.zon`
        const pulseaudio_name = switch (@import("builtin").os.tag) {
            .windows => "pulseaudio_windows",
            else => "pulseaudio",
        };
        if (b.lazyDependency(pulseaudio_name, .{})) |pulseaudio| {
            lib.addIncludePath(pulseaudio.path("src"));
            const version_string = build_zon.dependencies.pulseaudio.version;
            const version = comptime std.SemanticVersion.parse(version_string) catch unreachable;
            const api_version_string = build_zon.dependencies.pulseaudio.api_version;
            const api_version = comptime std.fmt.parseInt(u32, api_version_string, 10) catch unreachable;
            const protocol_version_string = build_zon.dependencies.pulseaudio.protocol_version;
            const protocol_version = comptime std.fmt.parseInt(u32, protocol_version_string, 10) catch unreachable;
            lib.addConfigHeader(b.addConfigHeader(.{
                .style = .{ .cmake = pulseaudio.path("src/pulse/version.h.in") },
                .include_path = "pulse/version.h",
            }, .{
                .PA_MAJOR = @as(i64, version.major),
                .PA_MINOR = @as(i64, version.minor),
                .PA_API_VERSION = api_version,
                .PA_PROTOCOL_VERSION = protocol_version,
            }));
        }
    }

    // Provide the direct rendering manager headers
    {
        lib.addIncludePath(b.path("deps/drm/include"));
        lib.addIncludePath(b.path("deps/drm/include/drm"));
        lib.addIncludePath(b.path("deps/gbm/include"));
    }

    // Provide the alsa headers
    {
        const alsa = b.dependency("alsa", .{});
        const alsa_include = b.addWriteFiles();
        _ = alsa_include.addCopyDirectory(alsa.path("include"), "alsa", .{
            .include_extensions = &.{".h"},
        });
        lib.addIncludePath(alsa_include.getDirectory());
        lib.addIncludePath(b.path("deps/alsa/include"));
    }

    // Provide upstream headers that don't require any special handling
    lib.addIncludePath(b.dependency("egl", .{}).path("api"));
    lib.addIncludePath(b.dependency("opengl", .{}).path("api"));
    lib.addIncludePath(b.dependency("xkbcommon", .{}).path("include"));
    lib.addIncludePath(b.dependency("xorgproto", .{}).path("include"));
    lib.addIncludePath(b.dependency("xext", .{}).path("include"));
    lib.addIncludePath(b.dependency("usb", .{}).path("libusb"));
    lib.addIncludePath(b.dependency("xi", .{}).path("include"));
    lib.addIncludePath(b.dependency("xfixes", .{}).path("include"));
    lib.addIncludePath(b.dependency("xrandr", .{}).path("include"));
    lib.addIncludePath(b.dependency("xrender", .{}).path("include"));
    lib.addIncludePath(b.dependency("xscrnsaver", .{}).path("include"));
    lib.addIncludePath(b.dependency("jack", .{}).path("common"));
    lib.addIncludePath(b.dependency("sndio", .{}).path("libsndio"));

    // Include vendored headers that don't require any special handling
    lib.addIncludePath(b.path("deps/xcb/include"));
    lib.addIncludePath(b.path("deps/udev/include"));

    // Add the Linux specific source files
    {
        lib.addCSourceFiles(.{
            .files = &sources.unix,
            .root = upstream.path("src"),
        });

        lib.addCSourceFiles(.{
            .files = &sources.linux,
            .root = upstream.path("src"),
        });
        lib.addCSourceFiles(.{
            .files = &sources.x11,
            .root = upstream.path("src"),
        });
    }

    // Configure SDL
    config.addValues(.{
        .HAVE_GCC_ATOMICS = true,

        // Useful headers
        .HAVE_FLOAT_H = true,
        .HAVE_STDARG_H = true,
        .HAVE_STDDEF_H = true,
        .HAVE_STDINT_H = true,
        .HAVE_LIBC = true,
        .HAVE_ALLOCA_H = true,
        .HAVE_ICONV_H = true,
        .HAVE_INTTYPES_H = true,
        .HAVE_LIMITS_H = true,
        .HAVE_MALLOC_H = true,
        .HAVE_MATH_H = true,
        .HAVE_MEMORY_H = true,
        .HAVE_SIGNAL_H = true,
        .HAVE_STDIO_H = true,
        .HAVE_STDLIB_H = true,
        .HAVE_STRINGS_H = true,
        .HAVE_STRING_H = true,
        .HAVE_SYS_TYPES_H = true,
        .HAVE_WCHAR_H = true,
        .HAVE_PTHREAD_NP_H = true,
        .HAVE_DLOPEN = true,
        .HAVE_MALLOC = true,
        .HAVE_FDATASYNC = true,
        .HAVE_GETENV = true,
        .HAVE_GETHOSTNAME = true,
        .HAVE_SETENV = true,
        .HAVE_PUTENV = true,
        .HAVE_UNSETENV = true,
        .HAVE_ABS = true,
        .HAVE_BCOPY = true,
        .HAVE_MEMSET = true,
        .HAVE_MEMCPY = true,
        .HAVE_MEMMOVE = true,
        .HAVE_MEMCMP = true,
        .HAVE_WCSLEN = true,
        .HAVE_WCSNLEN = true,
        .HAVE_WCSSTR = true,
        .HAVE_WCSCMP = true,
        .HAVE_WCSNCMP = true,
        .HAVE_WCSTOL = true,
        .HAVE_STRLEN = true,
        .HAVE_STRNLEN = true,
        .HAVE_STRPBRK = true,
        .HAVE_INDEX = true,
        .HAVE_RINDEX = true,
        .HAVE_STRCHR = true,
        .HAVE_STRRCHR = true,
        .HAVE_STRSTR = true,
        .HAVE_STRTOK_R = true,
        .HAVE_STRTOL = true,
        .HAVE_STRTOUL = true,
        .HAVE_STRTOLL = true,
        .HAVE_STRTOULL = true,
        .HAVE_STRTOD = true,
        .HAVE_ATOI = true,
        .HAVE_ATOF = true,
        .HAVE_STRCMP = true,
        .HAVE_STRNCMP = true,
        .HAVE_VSSCANF = true,
        .HAVE_VSNPRINTF = true,
        .HAVE_ACOS = true,
        .HAVE_ACOSF = true,
        .HAVE_ASIN = true,
        .HAVE_ASINF = true,
        .HAVE_ATAN = true,
        .HAVE_ATANF = true,
        .HAVE_ATAN2 = true,
        .HAVE_ATAN2F = true,
        .HAVE_CEIL = true,
        .HAVE_CEILF = true,
        .HAVE_COPYSIGN = true,
        .HAVE_COPYSIGNF = true,
        .HAVE__COPYSIGN = true,
        .HAVE_COS = true,
        .HAVE_COSF = true,
        .HAVE_EXP = true,
        .HAVE_EXPF = true,
        .HAVE_FABS = true,
        .HAVE_FABSF = true,
        .HAVE_FLOOR = true,
        .HAVE_FLOORF = true,
        .HAVE_FMOD = true,
        .HAVE_FMODF = true,
        .HAVE_ISINF = true,
        .HAVE_ISINFF = true,
        .HAVE_ISINF_FLOAT_MACRO = true,
        .HAVE_ISNAN = true,
        .HAVE_ISNANF = true,
        .HAVE_ISNAN_FLOAT_MACRO = true,
        .HAVE_LOG = true,
        .HAVE_LOGF = true,
        .HAVE_LOG10 = true,
        .HAVE_LOG10F = true,
        .HAVE_LROUND = true,
        .HAVE_LROUNDF = true,
        .HAVE_MODF = true,
        .HAVE_MODFF = true,
        .HAVE_POW = true,
        .HAVE_POWF = true,
        .HAVE_ROUND = true,
        .HAVE_ROUNDF = true,
        .HAVE_SCALBN = true,
        .HAVE_SCALBNF = true,
        .HAVE_SIN = true,
        .HAVE_SINF = true,
        .HAVE_SQRT = true,
        .HAVE_SQRTF = true,
        .HAVE_TAN = true,
        .HAVE_TANF = true,
        .HAVE_TRUNC = true,
        .HAVE_TRUNCF = true,
        .HAVE__FSEEKI64 = true,
        .HAVE_FOPEN64 = true,
        .HAVE_FSEEKO = true,
        .HAVE_FSEEKO64 = true,
        .HAVE_MEMFD_CREATE = true,
        .HAVE_POSIX_FALLOCATE = true,
        .HAVE_SIGACTION = true,
        .HAVE_SA_SIGACTION = true,
        .HAVE_ST_MTIM = true,
        .HAVE_SETJMP = true,
        .HAVE_NANOSLEEP = true,
        .HAVE_GMTIME_R = true,
        .HAVE_LOCALTIME_R = true,
        .HAVE_NL_LANGINFO = true,
        .HAVE_SYSCONF = true,
        .HAVE_CLOCK_GETTIME = true,
        .HAVE_GETPAGESIZE = true,
        .HAVE_ICONV = true,
        .SDL_USE_LIBICONV = true,
        .HAVE_PTHREAD_SETNAME_NP = true,
        .HAVE_PTHREAD_SET_NAME_NP = true,
        .HAVE_SEM_TIMEDWAIT = true,
        .HAVE_GETAUXVAL = true,
        .HAVE_ELF_AUX_INFO = true,
        .HAVE_POLL = true,
        .HAVE__EXIT = true,

        .HAVE_DBUS_DBUS_H = true,
        .HAVE_FCITX = true,
        .HAVE_IBUS_IBUS_H = true,
        .HAVE_INOTIFY_INIT1 = true,
        .HAVE_INOTIFY = true,
        .HAVE_LIBUSB = true,
        .HAVE_O_CLOEXEC = true,

        .HAVE_LINUX_INPUT_H = true,
        .HAVE_LIBUDEV_H = true,
        .HAVE_LIBDECOR_H = true,
        .HAVE_LIBURING_H = true,

        .USE_POSIX_SPAWN = true,

        .SDL_THREADS_DISABLED = true,

        // Enable various audio drivers
        .SDL_AUDIO_DRIVER_ALSA = true,
        .SDL_AUDIO_DRIVER_ALSA_DYNAMIC = "\"libasound.so\"",
        .SDL_AUDIO_DRIVER_DISK = true,
        .SDL_AUDIO_DRIVER_JACK = true,
        .SDL_AUDIO_DRIVER_JACK_DYNAMIC = "\"libjack.so\"",
        .SDL_AUDIO_DRIVER_OSS = true,
        .SDL_AUDIO_DRIVER_PIPEWIRE = true,
        .SDL_AUDIO_DRIVER_PIPEWIRE_DYNAMIC = "\"libpipewire-0.3.so\"",
        .SDL_AUDIO_DRIVER_PULSEAUDIO = true,
        .SDL_AUDIO_DRIVER_PULSEAUDIO_DYNAMIC = "\"libpulse.so\"",
        .SDL_AUDIO_DRIVER_SNDIO = true,
        .SDL_AUDIO_DRIVER_SNDIO_DYNAMIC = "\"libsndio.so\"",

        // Enable various input drivers
        .SDL_INPUT_LINUXEV = true,
        .SDL_INPUT_LINUXKD = true,
        .SDL_HAVE_MACHINE_JOYSTICK_H = true,
        .SDL_JOYSTICK_HIDAPI = true,
        .SDL_JOYSTICK_LINUX = true,
        .SDL_JOYSTICK_VIRTUAL = true,
        .SDL_HAPTIC_LINUX = true,

        .SDL_LIBUSB_DYNAMIC = "\"libusb-1.0.so\"",
        .SDL_UDEV_DYNAMIC = "\"libudev.so\"",

        // Enable various process implementations
        .SDL_PROCESS_POSIX = true,

        // Enable various sensor drivers
        .SDL_SENSOR_DUMMY = true,

        // Enable various shared object loading systems
        .SDL_LOADSO_DLOPEN = true,

        // Enable various threading systems
        .SDL_THREAD_PTHREAD = true,
        .SDL_THREAD_PTHREAD_RECURSIVE_MUTEX = true,
        .SDL_THREAD_PTHREAD_RECURSIVE_MUTEX_NP = true,

        // Enable various RTC systems
        .SDL_TIME_UNIX = true,

        // Enable various timer systems
        .SDL_TIMER_UNIX = true,

        // Enable various video drivers
        .SDL_VIDEO_DRIVER_KMSDRM = true,
        .SDL_VIDEO_DRIVER_KMSDRM_DYNAMIC = "\"libdrm.so\"",
        .SDL_VIDEO_DRIVER_KMSDRM_DYNAMIC_GBM = "\"libgbm.so\"",
        .SDL_VIDEO_DRIVER_OFFSCREEN = true,
        .SDL_VIDEO_DRIVER_ROCKCHIP = true,
        .SDL_VIDEO_DRIVER_RPI = false,
        .SDL_VIDEO_DRIVER_OPENVR = false, // https://github.com/libsdl-org/SDL/issues/11329
        .SDL_VIDEO_DRIVER_WAYLAND = true,
        .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC = "\"libwayland-client.so.0\"",
        .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_CURSOR = "\"libwayland-cursor.so\"",
        .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_EGL = "\"libwayland-egl.so\"",
        .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_LIBDECOR = "\"libdecor-0.so\"",
        .SDL_VIDEO_DRIVER_WAYLAND_DYNAMIC_XKBCOMMON = "\"libxkbcommon.so\"",
        .SDL_VIDEO_DRIVER_X11 = true,
        .SDL_VIDEO_DRIVER_X11_DYNAMIC = "\"libX11.so\"",
        .SDL_VIDEO_DRIVER_X11_DYNAMIC_XCURSOR = "\"libXcursor.so\"",
        .SDL_VIDEO_DRIVER_X11_DYNAMIC_XEXT = "\"libXext.so\"",
        .SDL_VIDEO_DRIVER_X11_DYNAMIC_XFIXES = "\"libXfixes.so\"",
        .SDL_VIDEO_DRIVER_X11_DYNAMIC_XINPUT2 = "\"libXi.so\"",
        .SDL_VIDEO_DRIVER_X11_DYNAMIC_XRANDR = "\"libXrandr.so\"",
        .SDL_VIDEO_DRIVER_X11_DYNAMIC_XSS = "\"libXss.so\"",
        .SDL_VIDEO_DRIVER_X11_HAS_XKBLOOKUPKEYSYM = true,
        .SDL_VIDEO_DRIVER_X11_SUPPORTS_GENERIC_EVENTS = true,
        .SDL_VIDEO_DRIVER_X11_XCURSOR = true,
        .SDL_VIDEO_DRIVER_X11_XDBE = true,
        .SDL_VIDEO_DRIVER_X11_XFIXES = true,
        .SDL_VIDEO_DRIVER_X11_XINPUT2 = true, // https://github.com/libsdl-org/SDL/pull/13148
        .SDL_VIDEO_DRIVER_X11_XINPUT2_SUPPORTS_MULTITOUCH = true,
        .SDL_VIDEO_DRIVER_X11_XRANDR = true,
        .SDL_VIDEO_DRIVER_X11_XSCRNSAVER = true,
        .SDL_VIDEO_DRIVER_X11_XSHAPE = true,
        .SDL_VIDEO_DRIVER_X11_XSYNC = true,

        .SDL_VIDEO_RENDER_GPU = true,
        .SDL_VIDEO_RENDER_VULKAN = true,
        .SDL_VIDEO_RENDER_OGL = true,
        .SDL_VIDEO_RENDER_OGL_ES2 = true,

        // Enable OpenGL support
        .SDL_VIDEO_OPENGL = true,
        .SDL_VIDEO_OPENGL_ES = true,
        .SDL_VIDEO_OPENGL_ES2 = true,
        .SDL_VIDEO_OPENGL_CGL = true,
        .SDL_VIDEO_OPENGL_GLX = false,
        .SDL_VIDEO_OPENGL_WGL = true,
        .SDL_VIDEO_OPENGL_EGL = true,

        // Enable Vulkan support
        .SDL_VIDEO_VULKAN = true,

        // Enable GPU support
        .SDL_GPU_VULKAN = true,

        // Enable system power support
        .SDL_POWER_LINUX = true,

        // Enable system filesystem support
        .SDL_FILESYSTEM_UNIX = true,

        // Enable system storage support
        .SDL_STORAGE_STEAM = true,

        // Enable system FSops support
        .SDL_FSOPS_POSIX = true,

        // Enable camera subsystem
        .SDL_CAMERA_DRIVER_V4L2 = true,
        .SDL_CAMERA_DRIVER_PIPEWIRE = true,
        .SDL_CAMERA_DRIVER_PIPEWIRE_DYNAMIC = "\"libpipewire-0.3.so\"",

        // Whether SDL_DYNAMIC_API needs dlopen
        .DYNAPI_NEEDS_DLOPEN = true,

        // Enable ime support
        .SDL_USE_IME = true,
    });
}
