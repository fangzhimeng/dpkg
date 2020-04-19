# This Makefile fragment (since dpkg 1.16.1) includes all the Makefile
# fragments that define variables that can be useful within debian/rules.

dpkg_datadir = $(srcdir)/mk
include $(dpkg_datadir)/architecture.mk
include $(dpkg_datadir)/buildflags.mk
include $(dpkg_datadir)/pkg-info.mk
include $(dpkg_datadir)/vendor.mk
