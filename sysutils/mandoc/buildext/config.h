#include <sys/types.h>

#define MAN_CONF_FILE "/etc/man.conf"
#define MANPATH_BASE "/usr/share/man:/usr/X11R6/man"
#define MANPATH_DEFAULT "/share/man"
#define UTF8_LOCALE "pt_BR.utf8"
#define EFTYPE EINVAL
#define HAVE_CMSG_XPG42 0
#define HAVE_DIRENT_NAMLEN 0
#define HAVE_ENDIAN 1
#define HAVE_ERR 1
#define HAVE_FTS 0
#define HAVE_FTS_COMPARE_CONST 0
#define HAVE_GETLINE 1
#define HAVE_GETSUBOPT 1
#define HAVE_ISBLANK 1
#define HAVE_MKDTEMP 1
#define HAVE_NTOHL 1
#define HAVE_PLEDGE 0
#define HAVE_PROGNAME 0
#define HAVE_REALLOCARRAY 0
#define HAVE_RECALLOCARRAY 0
#define HAVE_REWB_BSD 0
#define HAVE_REWB_SYSV 1
#define HAVE_SANDBOX_INIT 0
#define HAVE_STRCASESTR 1
#define HAVE_STRINGLIST 0
#define HAVE_STRLCAT 1
#define HAVE_STRLCPY 1
#define HAVE_STRPTIME 1
#define HAVE_STRSEP 1
#define HAVE_STRTONUM 0
#define HAVE_SYS_ENDIAN 0
#define HAVE_VASPRINTF 1
#define HAVE_WCHAR 1
#define HAVE_OHASH 0

#define BINM_APROPOS "apropos"
#define BINM_CATMAN "catman"
#define BINM_MAKEWHATIS "makewhatis"
#define BINM_MAN "man"
#define BINM_SOELIM "soelim"
#define BINM_WHATIS "whatis"

extern 	const char *getprogname(void);
extern	void	  setprogname(const char *);
extern	void	 *reallocarray(void *, size_t, size_t);
extern	void	 *recallocarray(void *, size_t, size_t, size_t);
extern	long long strtonum(const char *, long long, long long, const char **);
