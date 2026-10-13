XCODE_DEVELOPER = $(shell xcode-select --print-path)
#used for selecting the sdk dir
IOS_PLATFORM ?= iPhoneOS
#minimum iOS version of every library (xportal_mobile targets 15.5)
IOS_MIN ?= 15.5
JOBS ?= $(shell sysctl -n hw.ncpu)

SQLITE_VERSION = 3540000
SQLITE_YEAR = 2026
ICU_VERSION = 78.3
PROJ_VERSION = 9.9.0
GEOS_VERSION = 3.15.0
RTTOPO_VERSION = 1.1.0
SPATIALITE_VERSION = 5.1.0

# Pick latest SDK in the directory
IOS_PLATFORM_DEVELOPER = ${XCODE_DEVELOPER}/Platforms/${IOS_PLATFORM}.platform/Developer
IOS_SDK = ${IOS_PLATFORM_DEVELOPER}/SDKs/$(shell ls ${IOS_PLATFORM_DEVELOPER}/SDKs | sort -r | head -n1)


all: build_arches
	${CURDIR}/./run_make_framework.sh

# Build separate architectures
# see https://www.innerfence.com/howto/apple-ios-devices-dates-versions-instruction-sets
build_arches:
	${MAKE} arch IOS_ARCH=arm64 IOS_PLATFORM=iPhoneOS IOS_HOST=arm-apple-darwin IOS_TARGET=arm64-apple-ios${IOS_MIN} IOS_ARCH_DIR=arm64-ios
	${MAKE} arch IOS_ARCH=arm64 IOS_PLATFORM=iPhoneSimulator IOS_HOST=arm-apple-darwin IOS_TARGET=arm64-apple-ios${IOS_MIN}-simulator IOS_ARCH_DIR=arm64-sim



BUILD_DIR = ${CURDIR}/build
PREFIX = ${BUILD_DIR}/${IOS_ARCH_DIR}
LIBDIR = ${PREFIX}/lib
BINDIR = ${PREFIX}/bin
INCLUDEDIR = ${PREFIX}/include
UTHASHDIR = ${CURDIR}/uthash

CXX = ${XCODE_DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++
CC = ${XCODE_DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
CFLAGS =-target ${IOS_TARGET} -isysroot ${IOS_SDK} -I${IOS_SDK}/usr/include -I${INCLUDEDIR} -I${UTHASHDIR} -Os
CXXFLAGS =-target ${IOS_TARGET} -stdlib=libc++ -std=c++17 -isysroot ${IOS_SDK} -I${IOS_SDK}/usr/include -I${INCLUDEDIR} -I${UTHASHDIR} -Os
LDFLAGS =-target ${IOS_TARGET} -stdlib=libc++ -isysroot ${IOS_SDK} -L${LIBDIR} -L${IOS_SDK}/usr/lib

#cmake settings shared by geos and proj (out of source build dir per arch)
CMAKE_IOS = -DCMAKE_SYSTEM_NAME=iOS \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_COMPILER="${CXX}" \
	-DCMAKE_C_COMPILER="${CC}" \
	-DCMAKE_C_FLAGS="${CFLAGS}" \
	-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
	-DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
	-DCMAKE_OSX_ARCHITECTURES=${IOS_ARCH} \
	-DCMAKE_OSX_DEPLOYMENT_TARGET=${IOS_MIN} \
	-DCMAKE_OSX_SYSROOT:PATH="${IOS_SDK}" \
	-DBUILD_SHARED_LIBS=OFF \
	-DBUILD_TESTING=OFF

arch: ${LIBDIR}/libspatialite.a

${LIBDIR}/libspatialite.a: ${LIBDIR}/libsqlite3.a ${LIBDIR}/libproj.a ${LIBDIR}/libgeos.a ${LIBDIR}/librttopo.a ${CURDIR}/spatialite
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
	&& make clean && make -j${JOBS} && make install-strip

${CURDIR}/spatialite:
	curl -L http://www.gaia-gis.it/gaia-sins/libspatialite-sources/libspatialite-${SPATIALITE_VERSION}.tar.gz > spatialite.tar.gz
	tar -xzf spatialite.tar.gz
	rm spatialite.tar.gz
	mv libspatialite-${SPATIALITE_VERSION} spatialite
	./patch-spatialite
	./change-deployment-target spatialite

${CURDIR}/rttopo:
	curl -L https://download.osgeo.org/librttopo/src/librttopo-${RTTOPO_VERSION}.tar.gz > rttopo.tar.gz
	tar -xzf rttopo.tar.gz
	rm rttopo.tar.gz
	mv librttopo-${RTTOPO_VERSION} rttopo
	./change-deployment-target rttopo

${LIBDIR}/librttopo.a: ${CURDIR}/rttopo ${LIBDIR}/libgeos.a
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
	&& make clean && make -j${JOBS} && make install


${LIBDIR}/libproj.a: ${CURDIR}/proj ${LIBDIR}/libsqlite3.a
	rm -rf proj/build-${IOS_ARCH_DIR} && mkdir -p proj/build-${IOS_ARCH_DIR} && cd proj/build-${IOS_ARCH_DIR} && cmake \
	${CMAKE_IOS} \
	-DBUILD_APPS=OFF \
	-DENABLE_CURL=OFF \
	-DENABLE_TIFF=OFF \
	-DEXE_SQLITE3=/usr/bin/sqlite3 \
	-DSQLite3_INCLUDE_DIR=${INCLUDEDIR} \
	-DSQLite3_LIBRARY=${LIBDIR}/libsqlite3.a \
	.. && cmake --build . --config Release -j ${JOBS} && cmake --install . --config Release

${CURDIR}/proj:
	curl -L https://download.osgeo.org/proj/proj-${PROJ_VERSION}.tar.gz > proj.tar.gz
	tar -xzf proj.tar.gz
	rm proj.tar.gz
	mv proj-${PROJ_VERSION} proj

${LIBDIR}/libgeos.a: ${CURDIR}/geos
	rm -rf geos/build-${IOS_ARCH_DIR} && mkdir -p geos/build-${IOS_ARCH_DIR} && cd geos/build-${IOS_ARCH_DIR} && cmake \
	${CMAKE_IOS} \
	-DBUILD_GEOSOP:BOOL=OFF \
	-DBUILD_DOCUMENTATION=OFF \
	.. && cmake --build . --config Release -j ${JOBS} && cmake --install . --config Release

${CURDIR}/geos:
	curl -L https://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2 > geos.tar.bz2
	tar -xjf geos.tar.bz2
	rm geos.tar.bz2
	mv geos-${GEOS_VERSION} geos



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
${LIBDIR}/libsqlite3.a: ${CURDIR}/sqlite3 ${LIBDIR}/libicuuc.a
	cd sqlite3 && \
	${CC} -c sqlite3.c ${CFLAGS} ${SQLITE_FLAGS} -o "${BUILD_DIR}/${IOS_ARCH_DIR}-sqlite3.o" && \
	rm -f "${LIBDIR}/libsqlite3.a" && \
	${XCODE_DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/libtool -static -o "${LIBDIR}/libsqlite3.a" "${BUILD_DIR}/${IOS_ARCH_DIR}-sqlite3.o"
	cp -f -v "${CURDIR}/sqlite3/"*.h ${INCLUDEDIR}

${CURDIR}/sqlite3:
	curl -L https://www.sqlite.org/${SQLITE_YEAR}/sqlite-amalgamation-${SQLITE_VERSION}.zip -o sqlite3.zip
	unzip sqlite3.zip
	rm sqlite3.zip
	mv sqlite-amalgamation-${SQLITE_VERSION} sqlite3
	./patch-sqlite3
	touch sqlite3

${LIBDIR}/libicuuc.a: ${CURDIR}/icu
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
	&& make clean && make -j${JOBS} && make install

${CURDIR}/icu:
	curl -L https://github.com/unicode-org/icu/releases/download/release-${ICU_VERSION}/icu4c-${ICU_VERSION}-sources.tgz -o icu.tgz
	tar -xzf icu.tgz
	rm icu.tgz
	ICU_INSTALL_DIR="${CURDIR}/icu" \
	./build_icu_intermediate.sh



clean:
	rm -rf build geos proj spatialite include lib rttopo sqlite3 libspatialite.xcframework icu
