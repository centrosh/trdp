SHELL := /bin/bash
# Determine whether we need to prepare the extracted sources
ifeq ($(MAKECMDGOALS),)
PREPARE_SOURCES := yes
else ifneq ($(filter-out clean distclean help,$(MAKECMDGOALS)),)
PREPARE_SOURCES := yes
else
PREPARE_SOURCES := no
endif
ifeq ($(PREPARE_SOURCES),yes)
PREPARE_WORK := $(shell tools/prepare_sources.sh)
endif
BUILD_DIR := build
SRC_DIR := $(BUILD_DIR)/trdp
TRDP_TREE := $(SRC_DIR)
OBJ_DIR := $(BUILD_DIR)/obj
LIB_DIR := $(BUILD_DIR)/lib
BIN_DIR := $(BUILD_DIR)/bin
ifeq ($(PREPARE_SOURCES),yes)
LIBXML2_CFLAGS := $(shell pkg-config --cflags libxml-2.0 2>/dev/null)
LIBXML2_LIBS := $(shell pkg-config --libs libxml-2.0 2>/dev/null)
ifeq ($(strip $(LIBXML2_CFLAGS)),)
LIBXML2_CFLAGS := $(shell xml2-config --cflags 2>/dev/null)
LIBXML2_LIBS := $(shell xml2-config --libs 2>/dev/null)
endif
ifeq ($(strip $(LIBXML2_CFLAGS)),)
LIBXML2_CFLAGS := -I/usr/include/libxml2
LIBXML2_LIBS := -lxml2
endif
else
LIBXML2_CFLAGS :=
LIBXML2_LIBS :=
endif
CC ?= gcc
AR ?= ar
CFLAGS ?= -O2 -g
CPPFLAGS += -DMD_SUPPORT=1 -DHAS_UUID -DPOSIX -D_GNU_SOURCE -DO_LE -DTRDP_MD_AUTOPAD
CPPFLAGS += -I$(TRDP_TREE)/src/api -I$(TRDP_TREE)/src/common -I$(TRDP_TREE)/src/vos/api \
-I$(TRDP_TREE)/src/vos/posix -I$(TRDP_TREE)/src/vos/common $(LIBXML2_CFLAGS)
COMMON_LIBS := -lpthread -lrt -lm -luuid
TRDP_CORE_SRCS := $(wildcard $(TRDP_TREE)/src/common/*.c) \
$(wildcard $(TRDP_TREE)/src/vos/common/*.c) \
$(TRDP_TREE)/src/vos/posix/vos_shared_mem.c \
$(TRDP_TREE)/src/vos/posix/vos_sock.c \
$(TRDP_TREE)/src/vos/posix/vos_thread.c
TRDP_CORE_OBJS := $(patsubst $(TRDP_TREE)/%.c,$(OBJ_DIR)/%.o,$(TRDP_CORE_SRCS))
CORE_LIB := $(LIB_DIR)/libtrdp_core.a
XMLPD_TEST := $(BIN_DIR)/trdp-xmlpd-test
XMLPD_TEST_SRCS := $(TRDP_TREE)/test/xml/trdp-xmlpd-test.c
XMLPD_TEST_OBJS := $(patsubst $(TRDP_TREE)/%.c,$(OBJ_DIR)/%.o,$(XMLPD_TEST_SRCS))
XMLPRINT := $(BIN_DIR)/trdp-xmlprint
XMLPRINT_SRCS := $(TRDP_TREE)/test/xml/trdp-xmlprint-test.c
XMLPRINT_OBJS := $(patsubst $(TRDP_TREE)/%.c,$(OBJ_DIR)/%.o,$(XMLPRINT_SRCS))
PDPATTERN := $(BIN_DIR)/trdp-pd-test
PDPATTERN_SRCS := $(TRDP_TREE)/test/pdpatterns/trdp-pd-test.c
PDPATTERN_OBJS := $(patsubst $(TRDP_TREE)/%.c,$(OBJ_DIR)/%.o,$(PDPATTERN_SRCS))
PROGRAMS := $(XMLPD_TEST) $(XMLPRINT) $(PDPATTERN)
.PHONY: all clean distclean help prepare
all: $(PROGRAMS)
prepare:
	tools/prepare_sources.sh
$(CORE_LIB): $(TRDP_CORE_OBJS) | $(LIB_DIR)
	$(AR) rcs $@ $^
$(XMLPD_TEST): $(XMLPD_TEST_OBJS) $(CORE_LIB) | $(BIN_DIR)
	$(CC) $(CFLAGS) -o $@ $(XMLPD_TEST_OBJS) $(CORE_LIB) $(LIBXML2_LIBS) -lz $(COMMON_LIBS)
$(XMLPRINT): $(XMLPRINT_OBJS) $(CORE_LIB) | $(BIN_DIR)
	$(CC) $(CFLAGS) -o $@ $(XMLPRINT_OBJS) $(CORE_LIB) $(LIBXML2_LIBS) -lz $(COMMON_LIBS)
$(PDPATTERN): $(PDPATTERN_OBJS) $(CORE_LIB) | $(BIN_DIR)
	$(CC) $(CFLAGS) -o $@ $(PDPATTERN_OBJS) $(CORE_LIB) $(COMMON_LIBS)
$(OBJ_DIR)/%.o: $(TRDP_TREE)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@
$(LIB_DIR) $(BIN_DIR):
	@mkdir -p $@
clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR) $(LIB_DIR)
distclean: clean
	rm -rf $(BUILD_DIR)
help:
	@echo "Available targets:"
	@echo "  make           Build the TRDP core library and test tools"
	@echo "  make clean     Remove compiled objects and binaries"
	@echo "  make distclean Remove all generated files including the extracted sources"
	@echo "  make prepare   (Re)extract and patch the TRDP sources"
