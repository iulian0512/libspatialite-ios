libspatialite-ios
=================

A Makefile for automatically downloading and compiling [libspatialite](https://www.gaia-gis.it/fossil/libspatialite/index) (including its dependencies [SQLite](http://sqlite.org/index.html), [GEOS](http://trac.osgeo.org/geos/), [PROJ](https://proj.org), librttopo and ICU) statically for iOS, packed as `libspatialite.xcframework` for the sqflite fork (`iulian0512/sqflite`, `sqflite_darwin`).

Versions (set at the top of the Makefile): SQLite 3.54.0 (with `patches/sqlite_3540000_custom.patch`: `remove_accents()`, load extension enabled), spatialite 5.1.0, PROJ 9.9.0, GEOS 3.15.0, librttopo 1.1.0, ICU 78.3. iconv comes from the iOS SDK.

Slices:

- arm64 (iOS device)
- arm64 (iOS Simulator)

Minimum iOS: `IOS_MIN` in the Makefile (15.5).

Requirements
------------

Xcode with Command Line Tools, Homebrew `cmake`, `autoconf`, `automake`, `pkg-config`, `gnu-sed` (`gsed`).

Installation
------------

	make clean
	make
	zip -r -y -X libspatialite_<name>.xcframework.zip libspatialite.xcframework -x '*.DS_Store'
