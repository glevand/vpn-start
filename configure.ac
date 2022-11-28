## configure.ac -- Process this file with autoconf to produce configure

AC_INIT([AUDX],
    [m4_esyscmd_s([./version.sh])],
    [Geoff Levand <geoff@infradead.org>],
    [vpn-start],
    [https://github.com/glevand/vpn-start])

AC_USE_SYSTEM_EXTENSIONS
AC_CONFIG_MACRO_DIR([m4])
AC_PREFIX_DEFAULT([/usr/local])
AC_PROG_INSTALL

AM_INIT_AUTOMAKE

AM_SILENT_RULES([yes])

AC_SUBST([DESTDIR])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([Makefile])

AC_OUTPUT
