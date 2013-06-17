# Makefile for winetricks - a script for working around common problems in wine
#
# Copyright (C) 2013 Dan Kegel.  See also copyright notice in src/winetricks.
#
# winetricks comes with ABSOLUTELY NO WARRANTY.
#
# This is free software, placed under the terms of the
# GNU Lesser Public License version 2.1, as published by the Free Software
# Foundation. Please see the file src/COPYING for details.
#
# Web Page: http://winetricks.org
#
# Maintainers:
# Dan Kegel <dank!kegel.com>, Austin English <austinenglish!gmail.com>

INSTALL = install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644
SOURCES = Makefile src tests

version=$(shell grep '^WINETRICKS_VERSION' < src/winetricks | sed 's/.*=//')

PREFIX = /usr

all:
	@ echo "Nothing to compile. Use: check, clean, cleanup, dist, install"

# Editor backup files etc.
clean:
	find . -name "*[#~]" \
		-o -name "*.\#*" \
		-o -name "*.orig" \
		-o -name "*.porig" \
		-o -name "*.rej" \
		-o -name "*.log" \
		-o -name "*.out" \
		-o -name "*.verbs" \
	| xargs --no-run-if-empty rm
	rm -rf src/df-* src/measurements

# Remove trailing whitespaces
cleanup:
	sed --in-place 's,[ \t]\+$$,,' $$(find $(SOURCES) -type f)

dist: clean $(SOURCES)
	tar --exclude='*.patch' --exclude=measurements --exclude=.svn \
		--exclude-backups \
		-czvf winetricks-$(version).tar.gz $(SOURCES)

install:
	$(INSTALL_PROGRAM) -D src/winetricks $(DESTDIR)$(PREFIX)/bin/winetricks
	$(INSTALL_DATA) -D src/winetricks.1 $(DESTDIR)$(PREFIX)/share/man/man1/winetricks.1

check:
	echo 'This verifies that most DLL verbs, plus flash, install ok.'
	echo 'It should take about an hour to run with a fast connection.'
	echo 'If you want to test a particular version of wine, do e.g.'
	echo 'export WINE=$$HOME/wine-git/wine first.'
	echo 'On 64 bit systems, you probably want export WINEARCH=win32.'
	echo 'Winetricks does not work completely in non-English locales.'
	echo ''
	echo 'Current Environment:'
	echo 'DISPLAY is currently "$(DISPLAY)".'
	echo 'LANG is currently "$(LANG)".'
	echo 'WINEARCH is currently "$(WINEARCH)".'
	echo 'WINE is currently "$(WINE)".'
	echo 'XAUTHORITY is currently "$(XAUTHORITY)".'
	echo ''
	echo 'If running this as part of debuild, you might need to use'
	echo 'debuild --preserve-envvar=LANG --preserve-envvar=WINE --preserve-envvar=WINEARCH --preserve-envvar=DISPLAY --preserve-envvar=XAUTHORITY'
	echo 'To suppress tests in debuild, export DEB_BUILD_OPTIONS=nocheck'
	echo ''
	echo 'FIXME: this should kill stray wine processes before and after, but some leak through, you might need to kill them.'
	rm -rf ~/winetrickstest-prefixes
	cd src; sh ../tests/winetricks-test quick