# alsa

Alsa normally generates `asoundlib.h` as part of its build process. Since the results are fairly straightforward, we've replicated them here rather than try to integrate directly with alsa's build system. An explanation of the choices made given in the header itself. It may need to be updated if alsa is updated, or if the surface area of the integration between SDL and alsa is increased.
