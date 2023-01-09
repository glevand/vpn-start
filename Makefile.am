AUTOMAKE_OPTIONS = foreign

ACLOCAL_AMFLAGS = -I m4

composed_bin_scripts = \
	find-host.sh \
	vpn-start.sh \
	vpn-start-lib.sh

lib_scripts = \
	vpnc-script

nobase_bin_SCRIPTS = 

config_files = \
	vpn-start.conf.sample \
	find-host.conf.sample

bin_SCRIPTS = $(composed_bin_scripts) $(lib_scripts)

edit = sed \
	-e 's|@PACKAGE\@|$(PACKAGE)|g' \
	-e 's|@PACKAGE_BUGREPORT\@|$(PACKAGE_BUGREPORT)|g' \
	-e 's|@PACKAGE_NAME\@|$(PACKAGE_NAME)|g' \
	-e 's|@PACKAGE_URL\@|$(PACKAGE_URL)|g' \
	-e 's|@PACKAGE_VERSION\@|$(PACKAGE_VERSION)|g' \
	-e 's|@datadir\@|$(pkgdatadir)|g' \
	-e 's|@libexecdir\@|$(libexecdir)|g' \
	-e 's|@prefix\@|$(prefix)|g'

$(composed_bin_scripts): % : Makefile $(srcdir)/%.in
	rm -f $@ $@.tmp
	mkdir -p $$(dirname $@)
	$(edit) $(srcdir)/$@.in > $@.tmp
	chmod +x $@.tmp
	mv $@.tmp $@

test_files = $(srcdir)/tests/*

EXTRA_DIST = bootstrap configure.ac COPYING m4 mit-plus-license.txt README.md \
	version.sh $(addsuffix .in, $(composed_bin_scripts)) $(lib_scripts) \
	$(nobase_bin_SCRIPTS) $(config_files) $(test_files)

CLEANFILES = $(composed_bin_scripts)

MAINTAINERCLEANFILES = aclocal.m4 compile config.h* config.log config.status \
configure configure~ depcomp find-host.sh install-sh Makefile Makefile.in \
missing stamp-h1 vpn-start.sh $(PACKAGE)-*.gz

maintainer-clean-local:
	rm -rf m4 .deps autom4te.cache install

.PHONY: help

help:
	@echo "Targets:"
	@echo "  make install"
	@echo "  make dist"
	@echo "  make distcheck"
	@echo "  make distclean"
	@echo "  make maintainer-clean"
