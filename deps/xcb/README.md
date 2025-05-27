# xcb

There are two main ways to talk to X11: Xlib, and xcb.

SDL uses Xlib. However, when creating a Vulkan window with X11, one of the two following extensions must be used:

 1. VK_KHR_xlib_surface
 2. VK_KHR_xcb_surface

If only the second is present, then SDL needs access to a small number of xcb definitions. Actually building xcb from source is fairly involved, and the integration is so minimal that we're opting to just provide the relevant types here.
