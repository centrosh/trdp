# -----------------------------------------------------------------------------
# Builds the TRDP library
# Author: rsd
# -----------------------------------------------------------------------------


ifdef linux
   IMPORT_CPPFLAGS+=-DPOSIX
   IMPORT_CPPFLAGS+=-D_GNU_SOURCE
endif

# Set compiler flags
IMPORT_CPPFLAGS+=-DMD_SUPPORT=1 -DHAS_UUID

# Force endianness
ifdef big_endian
   IMPORT_CPPFLAGS+=-DO_BE
else
   IMPORT_CPPFLAGS+=-DO_LE
endif

# For auto padding for the MD
ifdef trdp.md.autopad
   IMPORT_CPPFLAGS+=-DTRDP_MD_AUTOPAD
endif

ifdef trdp.soa.support
   IMPORT_CPPFLAGS+=-DSOA_SUPPORT=1
endif


#### TRDP CORE ####
# Create a static library of the TRDP core (for single process)
MAKE_LIB+=trdp_core

# Add all source files (c and cpp files) the current dir and subdirs
trdp_core.CSRCS+= \
	$(wildcard trdp/src/common/*.c) \
	$(wildcard trdp/src/vos/common/*.c) \
	trdp/src/vos/posix/vos_shared_mem.c \
	trdp/src/vos/posix/vos_sock.c \
	trdp/src/vos/posix/vos_thread.c

EXT_LIBS+=uuid

# -----------------------------------------------------------------------------
# Tools for testing
# -----------------------------------------------------------------------------

EXT_LIBS+=rt m

# Tool testing xml configuration parsing (and start TRDP stack)
MAKE_BIN+=trdp-xmlpd-test
trdp-xmlpd-test.CSRCS=./trdp/test/xml/trdp-xmlpd-test.c
trdp-xmlpd-test.PACKAGES=trdp_core libxml2/xml2 zlib/z

# Tool testing xml configuration parsing (print configuration to stdout)
MAKE_BIN+=trdp-xmlprint
trdp-xmlprint.CSRCS=./trdp/test/xml/trdp-xmlprint-test.c
trdp-xmlprint.PACKAGES=trdp_core libxml2/xml2 zlib/z

# Tool testing PD with patterns
MAKE_BIN+=trdp-pd-test
trdp-pd-test.CSRCS=./trdp/test/pdpatterns/trdp-pd-test.c
trdp-pd-test.PACKAGES=trdp_core
