# glib 2.85.0

The required headers are vendored into `upstream` from [here](https://gitlab.gnome.org/GNOME/glib/-/tags/2.85.0). We can't pull them in via the build system because the original package contains symlinks, which breaks cross compiling from Windows.

If updating, keep `info.zon` in sync. See also the rest of this file for an explanation of hte files in `cached`.

## Generated glib headers

`glib` generates some headers in a way that's annoying to fully replicate automatically, so some manual is done here. These header may need to be updated if glib is updated.

### glibconfig.h.in

This was copied verbatim from glib, but each `#mesondefine` was renamed to `#cmakedefine` to make it easier to use with Zig's build system.

### glib_versions.h

This file is generated in a fairly straightforward way that we could automate, but haven't yet. It's just a list of macros for a list of glib version names. For now we just have the hard coded result for the current version. It's not inside of `include` as it's not actually exported as a public header.
