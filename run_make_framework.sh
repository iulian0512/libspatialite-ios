rm -rf lib include libspatialite.xcframework
mkdir -p lib
mkdir -p include

# Copy includes
cp -v -R build/arm64-ios/include/geos include
cp -v -R build/arm64-ios/include/spatialite include
cp -v -R build/arm64-ios/include/unicode include
cp -v -R build/arm64-ios/include/proj include
cp -v -R build/arm64-ios/include/*.h include
# sqflite_darwin (SqfliteDarwinDB_SQLITE_STANDALONE) imports <sqlite3/sqlite3.h>
mkdir -p include/sqlite3
cp -v build/arm64-ios/include/sqlite3.h build/arm64-ios/include/sqlite3ext.h include/sqlite3

# Simulator libraries (arm64 only)
for file in build/arm64-sim/lib/*.a; \
    do name=$(basename $file .a); \
    cp -v build/arm64-sim/lib/$name.a lib/$name.a \
    ; \
    done;
./make-framework
