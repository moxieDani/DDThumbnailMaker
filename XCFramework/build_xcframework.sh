rm -rf ./DDThumbnailMaker.xcframework

xcodebuild archive -scheme DDThumbnailMaker -archivePath './build/DDThumbnailMaker.xcarchive' -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme DDThumbnailMaker -archivePath './build/DDThumbnailMaker_sim.xcarchive' -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
    -framework "./build/DDThumbnailMaker.xcarchive/Products/Library/Frameworks/DDThumbnailMaker.framework" \
    -framework "./build/DDThumbnailMaker_sim.xcarchive/Products/Library/Frameworks/DDThumbnailMaker.framework" \
    -output "./DDThumbnailMaker.xcframework"

rm -rf build