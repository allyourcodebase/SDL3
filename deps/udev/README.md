# udev

The contents of `include` come from [here](https://github.com/systemd/systemd/releases/tag/v257.6), see [licenses](https://github.com/systemd/systemd/tree/00a12c234e2506f5cab683460199575f13c454db/LICENSES).

The required headers had to be vendored, as the parent repo contains paths that aren't supported on Windows, which breaks cross compilation.
