////////////////////////////////////////////////////////////////////////////////////////////////////
// asoundlib-head.h:
////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef __ASOUNDLIB_H
#define __ASOUNDLIB_H

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <string.h>
#include <fcntl.h>
#include <assert.h>
#include <poll.h>
#include <errno.h>
#include <stdarg.h>
#include <stdint.h>
#include <time.h>

////////////////////////////////////////////////////////////////////////////////////////////////////
// Manual recreation of the generated body
////////////////////////////////////////////////////////////////////////////////////////////////////

// Replicate the logic from alsa's bound system with __has_include
#if __has_include(<sys/endian.h>)
	#include <sys/endian.h>
	#ifndef __BYTE_ORDER
		#define __BYTE_ORDER BYTE_ORDER
	#endif
	#ifndef __LITTLE_ENDIAN
		#define __LITTLE_ENDIAN LITTLE_ENDIAN
	#endif
	#ifndef __BIG_ENDIAN
		#define __BIG_ENDIAN BIG_ENDIAN
	#endif
#else
	#include <endian.h>
#endif

#ifndef DOC_HIDDEN
	#ifndef __GNUC__
		#define __inline__ inline
	#endif
#endif /* DOC_HIDDEN */

// The official build then includes a few headers unconditionally. We've removed the ones that
// aren't needed by SDL.
#include <alsa/asoundef.h>
#include <alsa/global.h>
#include <alsa/input.h>
#include <alsa/output.h>
#include <alsa/conf.h>

// The build system then conditionally includes headers based on which features are enabled. SDL
// currently only requires these two.
#include <alsa/pcm.h>
#include <alsa/control.h>

////////////////////////////////////////////////////////////////////////////////////////////////////
// asoundlib-tail.h
////////////////////////////////////////////////////////////////////////////////////////////////////

#endif /* __ASOUNDLIB_H */
