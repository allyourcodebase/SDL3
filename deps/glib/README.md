# Generated glib headers

`glib` generates some headers in a way that's annoying to fully replicate automatically, so some manual is done here. These header may need to be updated if glib is updated.

## glibconfig.h.in

This was copied verbatim from glib, but each `#mesondefine` was renamed to `#cmakedefine` to make it easier to use with Zig's build system.

## glib_versions.h

This file is generated in a fairly straightforward way that we could automate, but haven't yet. It's just a list of macros for a list of glib version names. For now we just have the hard coded result for the current version. It's not inside of `include` as it's not actually exported as a public header.


## include

These were taken directly from the result of building glib from source. They aren't host dependent, so including them as is should be fine.
