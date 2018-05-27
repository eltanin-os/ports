#include <sys/types.h>
#include <_mk_def.h>

#define EFTYPE          EINVAL
#define HAVE_ENDIAN     1
#define HAVE_REWB_SYSV  1

#ifndef HAVE_WCHAR_H
#define HAVE_WCHAR 0
#else
#define HAVE_WCHAR 1
#endif

extern void       *reallocarray(void *, size_t, size_t);
extern void       *recallocarray(void *, size_t, size_t, size_t);
extern long long   strtonum(const char *, long long, long long, const char **);
