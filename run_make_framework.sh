mkdir -p lib
mkdir -p include

# Copy includes
cp -v -R build/arm64-ios/include/geos include
cp -v -R build/arm64-ios/include/spatialite include
cp -v -R build/arm64-ios/include/unicode include
cp -v -R build/arm64-ios/include/proj include
cp -v -R build/arm64-ios/include/*.h include

# Make fat libraries for Simulator architectures 
for file in build/arm64-sim/lib/*.a; \
    do name=$(basename $file .a); \
    lipo -create \
        -arch arm64 build/arm64-sim/lib/$name.a \
        -output lib/$name.a \
    ; \
    done;
./make-framework