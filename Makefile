XCODE_DEVELOPER = $(shell xcode-select --print-path)
#used for selecting the sdk dir
IOS_PLATFORM ?= iPhoneOS

# Pick latest SDK in the directory
IOS_PLATFORM_DEVELOPER = ${XCODE_DEVELOPER}/Platforms/${IOS_PLATFORM}.platform/Developer
IOS_SDK = ${IOS_PLATFORM_DEVELOPER}/SDKs/$(shell ls ${IOS_PLATFORM_DEVELOPER}/SDKs | sort -r | head -n1)


all: build_arches
	${CURDIR}/./run_make_framework.sh
	
# Build separate architectures
# see https://www.innerfence.com/howto/apple-ios-devices-dates-versions-instruction-sets
build_arches:
	${MAKE} arch IOS_ARCH=arm64 IOS_PLATFORM=iPhoneOS IOS_HOST=arm-apple-darwin IOS_TARGET=arm64-apple-ios17.0 IOS_ARCH_DIR=arm64-ios
	${MAKE} arch IOS_ARCH=arm64 IOS_PLATFORM=iPhoneSimulator IOS_HOST=arm-apple-darwin IOS_TARGET=arm64-apple-ios17.0-simulator IOS_ARCH_DIR=arm64-sim
	${MAKE} arch IOS_ARCH=arm64 IOS_PLATFORM=iPhoneSimulator IOS_HOST=arm-apple-darwin IOS_TARGET=arm64-apple-ios17.0-simulator IOS_ARCH_DIR=arm64-sim



BUILD_DIR = ${CURDIR}/build
PREFIX = ${BUILD_DIR}/${IOS_ARCH_DIR}
LIBDIR = ${PREFIX}/lib
BINDIR = ${PREFIX}/bin
INCLUDEDIR = ${PREFIX}/include
UTHASHDIR = ${CURDIR}/uthash

CXX = ${XCODE_DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++
CC = ${XCODE_DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
CFLAGS =-target ${IOS_TARGET} -isysroot ${IOS_SDK} -I${IOS_SDK}/usr/include -I${INCLUDEDIR} -I${UTHASHDIR} -mios-version-min=17.0 -Os -fembed-bitcode
CXXFLAGS =-target ${IOS_TARGET} -stdlib=libc++ -std=c++11 -isysroot ${IOS_SDK} -I${IOS_SDK}/usr/include -I${INCLUDEDIR} -I${UTHASHDIR} -mios-version-min=17.0 -Os -fembed-bitcode
LDFLAGS =-stdlib=libc++ -isysroot ${IOS_SDK} -L${LIBDIR} -L${IOS_SDK}/usr/lib -arch ${IOS_ARCH} -mios-version-min=17.0

arch: ${LIBDIR}/libspatialite.a

${LIBDIR}/libspatialite.a: ${LIBDIR}/libsqlite3.a ${LIBDIR}/libproj.a ${LIBDIR}/libgeos.a ${LIBDIR}/rttopo.a ${CURDIR}/spatialite
	cd spatialite && env \
	CXX=${CXX} \
	CC=${CC} \
	CFLAGS="${CFLAGS}" \
	CXXFLAGS="${CXXFLAGS}" \
	LDFLAGS="${LDFLAGS} -liconv -lgeos -lgeos_c -lc++ -licudata -licui18n -licuuc -lsqlite3" \
	./configure --host=${IOS_HOST} \
	--prefix=${PREFIX} \
	--with-geosconfig=${BINDIR}/geos-config \
	--disable-freexl \
    --disable-minizip \
    --disable-gcov \
    --disable-examples \
    --disable-libxml2 \
    --disable-shared \
	&& make clean install-strip

${CURDIR}/spatialite:
	curl http://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-5.1.0.tar.gz > spatialite.tar.gz
	tar -xzf spatialite.tar.gz
	rm spatialite.tar.gz
	mv libspatialite-5.1.0 spatialite
	./patch-spatialite
	./change-deployment-target spatialite

${CURDIR}/rttopo:
	curl -L https://download.osgeo.org/librttopo/src/librttopo-1.1.0.tar.gz > rttopo.tar.gz
	tar -xzf rttopo.tar.gz
	rm rttopo.tar.gz
	mv librttopo-1.1.0 rttopo
	./change-deployment-target rttopo

${LIBDIR}/rttopo.a: ${CURDIR}/rttopo
	cd rttopo && env \
	CXX=${CXX} \
	CC=${CC} \
	CFLAGS="${CFLAGS}" \
	CXXFLAGS="${CXXFLAGS}" \
	LDFLAGS="${LDFLAGS} -liconv -lgeos -lgeos_c -lc++" \
	./configure --host=${IOS_HOST} \
	--prefix=${PREFIX} \
	--disable-shared \
	--with-geosconfig=${BINDIR}/geos-config \
	&& make clean install


${LIBDIR}/libproj.a: ${CURDIR}/proj
	cd proj && cmake \
	-DCMAKE_SYSTEM_NAME=iOS \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
	-DCMAKE_OSX_ARCHITECTURES=${IOS_ARCH} \
	-DCMAKE_OSX_SYSROOT:PATH="${IOS_SDK}" \
	-DBUILD_APPS=OFF \
	-DBUILD_SHARED_LIBS=OFF \
	-DBUILD_TESTING=OFF \
	-DENABLE_CURL=OFF \
	-DENABLE_TIFF=OFF \
	-DSQLITE3_INCLUDE_DIR=${INCLUDEDIR} \
	-DSQLITE3_LIBRARY=${LIBDIR}/libsqlite3.a \
	&& cmake --build . --target clean && cmake  --build . --config Release && cmake --install . --config Release

${CURDIR}/proj:
	curl -L https://download.osgeo.org/proj/proj-9.2.1.tar.gz > proj.tar.gz
	tar -xzf proj.tar.gz
	rm proj.tar.gz
	mv proj-9.2.1 proj

${LIBDIR}/libgeos.a: ${CURDIR}/geos
	cd geos && cmake \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
	-DCMAKE_OSX_ARCHITECTURES=${IOS_ARCH} \
	-DCMAKE_OSX_SYSROOT:PATH="${IOS_SDK}" -DBUILD_GEOSOP:BOOL=OFF -DBUILD_SHARED_LIBS:BOOL=OFF -DBUILD_TESTING:BOOL=OFF \
	&& cmake --build . --target clean && cmake  --build . --config Release && cmake --install . --config Release

${CURDIR}/geos:
	curl https://download.osgeo.org/geos/geos-3.12.0.tar.bz2 > geos.tar.bz2
	tar -xzf geos.tar.bz2
	rm geos.tar.bz2
	mv geos-3.12.0 geos



SQLITE_FLAGS=-DNDEBUG=1 \
	-DHAVE_USLEEP=1 \
	-DSQLITE_HAVE_ISNAN \
	-DSQLITE_DEFAULT_JOURNAL_SIZE_LIMIT=1048576 \
	-DSQLITE_THREADSAFE=2 \
	-DSQLITE_TEMP_STORE=3 \
	-DSQLITE_POWERSAFE_OVERWRITE=1 \
	-DSQLITE_DEFAULT_FILE_FORMAT=4 \
	-DSQLITE_DEFAULT_AUTOVACUUM=1 \
	-DSQLITE_ENABLE_MEMORY_MANAGEMENT=1 \
	-DSQLITE_ENABLE_FTS3 \
	-DSQLITE_ENABLE_FTS4 \
	-DSQLITE_ENABLE_JSON1 \
	-DSQLITE_OMIT_BUILTIN_TEST \
	-DSQLITE_OMIT_COMPILEOPTION_DIAGS \
	-DSQLITE_DEFAULT_FILE_PERMISSIONS=0600 \
	-DSQLITE_ENABLE_RTREE \
	-DSQLITE_ENABLE_ICU \
	-DSQLITE_ENABLE_LOAD_EXTENSION
${LIBDIR}/libsqlite3.a: ${CURDIR}/sqlite3 ${LIBDIR}/libicu.a
	cd sqlite3 && \
	LIBTOOL=${XCODE_DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/libtool \
	CXX=${CXX} \
	CC=${CC} \
	CFLAGS="${CFLAGS}" \
	CXXFLAGS="${CXXFLAGS}" \
	LDFLAGS="-Wl,-arch -Wl,${IOS_ARCH} -arch_only ${IOS_ARCH} ${LDFLAGS} -licudata -licui18n -licuuc" \
	${CC} -c sqlite3.c ${CFLAGS} ${SQLITE_FLAGS} -o "${LIBDIR}/libsqlite3.a"
	cp -f -v "${CURDIR}/sqlite3/"*.h ${INCLUDEDIR}

${CURDIR}/sqlite3:
	curl -L https://www.sqlite.org/2023/sqlite-amalgamation-3430200.zip -o sqlite3.zip
	unzip sqlite3.zip
	rm sqlite3.zip
	mv sqlite-amalgamation-3430200 sqlite3
	./patch-sqlite3
	touch sqlite3

${LIBDIR}/libicu.a: ${CURDIR}/icu
	mkdir -p "${CURDIR}/icu/build/${IOS_ARCH_DIR}" && cd "${CURDIR}/icu/build/${IOS_ARCH_DIR}" && \
	CXX=${CXX} \
	CC=${CC} \
	CFLAGS="${CFLAGS}" \
	CXXFLAGS="${CXXFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	${CURDIR}/icu/source/./runConfigureICU MacOSX \
	--host="arm-64-linux" \
	--prefix="${PREFIX}" \
	--with-cross-build="${CURDIR}/icu/build/intermediate_osx" \
	--enable-static \
	--enable-shared=no \
	--enable-extras=no \
	--enable-strict=no \
	--enable-icuio=no \
	--enable-layout=no \
	--enable-layoutex=no \
	--enable-tools=no \
	--enable-tests=no \
	--enable-samples=no \
	--enable-dyload=no \
	--with-data-packaging=archive \
	&& make clean install

${CURDIR}/icu:
	curl -L https://github.com/unicode-org/icu/releases/download/release-73-2/icu4c-73_2-src.tgz -o icu.tgz
	tar -xzf icu.tgz
	rm icu.tgz
	ICU_INSTALL_DIR="${CURDIR}/icu" \
	./build_icu_intermediate.sh 



clean:
	rm -rf build geos proj spatialite include lib rttopo sqlite3 LibSpatialite.xcframework icu
