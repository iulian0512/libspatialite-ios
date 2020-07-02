# libspatialite-ios

A Makefile for automatically downloading and compiling [libspatialite](https://www.gaia-gis.it/fossil/libspatialite/index) (including its dependencies [SQLite](https://sqlite.org/index.html), [GEOS](https://trac.osgeo.org/geos/) and [PROJ.4](https://trac.osgeo.org/proj/)) statically for iOS.

The resulting library is a "fat" library suitable for multiple architectures. This includes:

- armv7 (iOS)
- armv7s (iOS)
- arm64 (iOS)
- i386 (iOS Simulator)
- x86_64 (iOS Simulator)

## Requirements

Xcode 11 with Command Line Tools installed.

## Installation

Simply run

```
git submodule init
git submodule update
export MACOSX_DEPLOYMENT_TARGET="10.14.1"
make
```

## Making cocoapods package

TBD