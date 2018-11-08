#include <_mk_def.h>

#define CURL_CA_FALLBACK 1
#define CURL_DISABLE_LDAP 1
#define CURL_DISABLE_LDAPS 1
#define CURL_EXTERN_SYMBOL __attribute__ ((__visibility__ ("default")))
#define CURL_SA_FAMILY_T sa_family_t
#define ENABLE_IPV6 1
#define GETHOSTNAME_TYPE_ARG2 size_t
#define GETSERVBYPORT_R_ARGS 6
#define GETSERVBYPORT_R_BUFSIZE 4096
#define HAVE_ALLOCA_H 1
#define HAVE_ARPA_INET_H 1
#define HAVE_ARPA_TFTP_H 1
#define HAVE_ASSERT_H 1
#define HAVE_BOOL_T 1
#define HAVE_CLOCK_GETTIME_MONOTONIC 1
#define HAVE_DECL_GETPWUID_R 1
#define HAVE_DLFCN_H 1
#define HAVE_ENGINE_CLEANUP 1
#define HAVE_ERRNO_H 1
#define HAVE_FCNTL_H 1
#define HAVE_FCNTL_O_NONBLOCK 1
#define HAVE_FREEIFADDRS 1
#define HAVE_FSETXATTR 1
#define HAVE_FSETXATTR_5 1
#define HAVE_GETADDRINFO_THREADSAFE 1
#define HAVE_GETHOSTBYADDR 1
#define HAVE_GETHOSTBYADDR_R 1
#define HAVE_GETHOSTBYADDR_R_8 1
#define HAVE_GETHOSTBYNAME 1
#define HAVE_GETHOSTBYNAME_R 1
#define HAVE_GETHOSTBYNAME_R_6 1
#define HAVE_GETIFADDRS 1
#define HAVE_GETSERVBYPORT_R 1
#define HAVE_IFADDRS_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_IOCTL_FIONBIO 1
#define HAVE_IOCTL_SIOCGIFADDR 1
#define HAVE_LDAP_SSL 1
#define HAVE_LIBGEN_H 1
#define HAVE_LIBRESSL 1
#define HAVE_LIBSSL 1
#define HAVE_LIBZ 1
#define HAVE_LINUX_TCP_H 1
#define HAVE_LL 1
#define HAVE_LOCALE_H 1
#define HAVE_LONGLONG 1
#define HAVE_MALLOC_H 1
#define HAVE_MEMORY_H 1
#define HAVE_MSG_NOSIGNAL 1
#define HAVE_NETDB_H 1
#define HAVE_NETINET_IN_H 1
#define HAVE_NETINET_TCP_H 1
#define HAVE_NET_IF_H 1
#define HAVE_OPENSSL_CRYPTO_H 1
#define HAVE_OPENSSL_ERR_H 1
#define HAVE_OPENSSL_PEM_H 1
#define HAVE_OPENSSL_RSA_H 1
#define HAVE_OPENSSL_SSL_H 1
#define HAVE_OPENSSL_X509_H 1
#define HAVE_POLL_FINE 1
#define HAVE_POLL_H 1
#define HAVE_POSIX_STRERROR_R 1
#define HAVE_PTHREAD_H 1
#define HAVE_PWD_H 1
#define HAVE_SETJMP_H 1
#define HAVE_SIGNAL_H 1
#define HAVE_SIG_ATOMIC_T 1
#define HAVE_SOCKADDR_IN6_SIN6_SCOPE_ID 1
#define HAVE_SSL_GET_SHUTDOWN 1
#define HAVE_STDBOOL_H 1
#define HAVE_STDINT_H 1
#define HAVE_STDIO_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRINGS_H 1
#define HAVE_STRING_H 1
#define HAVE_STROPTS_H 1
#define HAVE_STRUCT_SOCKADDR_STORAGE 1
#define HAVE_STRUCT_TIMEVAL 1
#define HAVE_SYS_IOCTL_H 1
#define HAVE_SYS_PARAM_H 1
#define HAVE_SYS_POLL_H 1
#define HAVE_SYS_RESOURCE_H 1
#define HAVE_SYS_SELECT_H 1
#define HAVE_SYS_SOCKET_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TIME_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_SYS_UIO_H 1
#define HAVE_SYS_UN_H 1
#define HAVE_SYS_WAIT_H 1
#define HAVE_SYS_XATTR_H 1
#define HAVE_TERMIOS_H 1
#define HAVE_TIME_H 1
#define HAVE_UNISTD_H 1
#define HAVE_UTIME_H 1
#define HAVE_VARIADIC_MACROS_C99 1
#define HAVE_VARIADIC_MACROS_GCC 1
#define HAVE_ZLIB_H 1
#define LT_OBJDIR ".libs/"
#define NTLM_WB_ENABLED 1
#define NTLM_WB_FILE "/usr/bin/ntlm_auth"
#define OS "glacies"
#define PACKAGE "curl"
#define PACKAGE_BUGREPORT "a suitable curl mailing list: https://curl.haxx.se/mail/"
#define PACKAGE_NAME "curl"
#define PACKAGE_STRING "curl -"
#define PACKAGE_TARNAME "curl"
#define PACKAGE_URL ""
#define PACKAGE_VERSION "-"
#define RANDOM_FILE "/dev/urandom"
#define RECV_TYPE_ARG1 int
#define RECV_TYPE_ARG2 void *
#define RECV_TYPE_ARG3 size_t
#define RECV_TYPE_ARG4 int
#define RECV_TYPE_RETV ssize_t
#define RETSIGTYPE void
#define SELECT_QUAL_ARG5
#define SELECT_TYPE_ARG1 int
#define SELECT_TYPE_ARG234 fd_set *
#define SELECT_TYPE_ARG5 struct timeval *
#define SELECT_TYPE_RETV int
#define SEND_QUAL_ARG2 const
#define SEND_TYPE_ARG1 int
#define SEND_TYPE_ARG2 void *
#define SEND_TYPE_ARG3 size_t
#define SEND_TYPE_ARG4 int
#define SEND_TYPE_RETV ssize_t
#define STRERROR_R_TYPE_ARG3 size_t
#define TIME_WITH_SYS_TIME 1
#define USE_OPENSSL 1
#define USE_THREADS_POSIX 1
#define USE_UNIX_SOCKETS 1
#define VERSION "-"

#ifndef _DARWIN_USE_64_BIT_INODE
#define _DARWIN_USE_64_BIT_INODE 1
#endif

/* The values were defined based on the minimum expected by C99
 * SIZE_T is treated as long
 * OFF_T  is treated as long
 * TIME_T is treated as long
 */
#define SIZEOF_CURL_OFF_T 4
#define SIZEOF_INT 2
#define SIZEOF_LONG 4
#define SIZEOF_OFF_T 4
#define SIZEOF_SHORT 2
#define SIZEOF_SIZE_T 4
#define SIZEOF_TIME_T 4
