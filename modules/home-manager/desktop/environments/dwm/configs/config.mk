# dwm-titus version
VERSION = 0.7.2

# paths
PREFIX ?= /usr/local
MANPREFIX ?= ${PREFIX}/share/man
PKG_CONFIG ?= pkg-config

# Xinerama
XINERAMALIBS  = -lXinerama
XINERAMAFLAGS = -DXINERAMA

# Portable X11 and library discovery
PKG_MODULES = x11 xft xinerama xrender imlib2 x11-xcb xcb xcb-res fontconfig freetype2
INCS = $(shell ${PKG_CONFIG} --cflags ${PKG_MODULES})
LIBS = $(shell ${PKG_CONFIG} --libs ${PKG_MODULES})

OPTIMISATIONS ?= -O2

# flags
CPPFLAGS += -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_XOPEN_SOURCE=700L -DVERSION=\"${VERSION}\" ${XINERAMAFLAGS} ${INCS}
CFLAGS ?= ${OPTIMISATIONS} -std=c99 -pedantic -Wall -Wno-deprecated-declarations
LDLIBS += ${LIBS}

# compiler and linker
CC ?= cc
