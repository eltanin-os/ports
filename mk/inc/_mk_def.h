#include "_mk_posix.h"

/* TODO: ORGANIZE LATER */
#if defined(_MK_LC_MUSL) || defined(_MK_LC_GLIBC)
	#define getprogname( ) __setprogname
	#define setprogname(x) __setprogname = (x)
	#define HAVE_GETPROGNAME 1
	#define HAVE_SETPROGNAME 1
	#define HAVE_STRCASESTR 1
	#define HAVE_STRSEP 1
	#define HAVE_VASPRINTF 1
#endif

#ifdef _MK_LC_MUSL
	#define HAVE_STRLCPY 1
	#define HAVE_STRLCAT 1
#endif