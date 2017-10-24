// A simple LD_PRELOAD wrapper around getnameinfo that unconditionally sets
// NI_NUMERICHOST and NI_NUMERICSERV flags.

#include <netdb.h>
#define __USE_GNU
#include <dlfcn.h>

// NOTE: on CentOS 6, the flags parameter is declared as unsigned.
#ifdef __i386__
int getnameinfo(
    const struct sockaddr *sa,
    socklen_t salen, char *host,
    socklen_t hostlen, char *serv,
    socklen_t servlen, unsigned int flags) {
#else
int getnameinfo(
    const struct sockaddr *sa,
    socklen_t salen, char *host,
    socklen_t hostlen, char *serv,
    socklen_t servlen, int flags) {
#endif
  if (res_init () < 0) {
      return -1;
  }
  int (*f)() = dlsym (RTLD_NEXT, "getnameinfo");
  return f(sa, salen, host, hostlen, serv, servlen, flags|NI_NUMERICHOST|NI_NUMERICSERV);
}
