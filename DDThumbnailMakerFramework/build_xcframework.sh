xcodebuild archive -scheme DDThumbnailMakerFramework -archivePath './build/DDThumbnailMakerFramework.xcarchive' -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme DDThumbnailMakerFramework -archivePath './build/DDThumbnailMakerFramework_sim.xcarchive' -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
    -framework "./build/DDThumbnailMakerFramework.xcarchive/Products/Library/Frameworks/DDThumbnailMakerFramework.framework" \
    -framework "./build/DDThumbnailMakerFramework_sim.xcarchive/Products/Library/Frameworks/DDThumbnailMakerFramework.framework" \
    -output "./build/DDThumbnailMakerFramework.xcframework"
