# DDThumbnailMaker

[![CI Status](https://img.shields.io/travis/moxieDani/DDThumbnailMaker.svg?style=flat)](https://travis-ci.org/moxieDani/DDThumbnailMaker)
[![Version](https://img.shields.io/cocoapods/v/DDThumbnailMaker.svg?style=flat)](https://cocoapods.org/pods/DDThumbnailMaker)
[![License](https://img.shields.io/cocoapods/l/DDThumbnailMaker.svg?style=flat)](https://cocoapods.org/pods/DDThumbnailMaker)
[![Platform](https://img.shields.io/cocoapods/p/DDThumbnailMaker.svg?style=flat)](https://cocoapods.org/pods/DDThumbnailMaker)

## Example

To run the example project, clone the repo, and run `pod install` from the `Example` directory first.

## Installation

DDThumbnailMaker is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DDThumbnailMaker'
```

## Available XCFramework
DDThumbnailMaker is available for XCFramework.  
1. execute `sh build_xcframework.sh` from the `XCFramework` directory.
2. Drag & drop `DDThumbnailMaker.xcframework` into your project.
3. Set `Embeded & Sign` on the `Project -> general -> Frameworks, Libraries, and Embeded Content`

## How to use
```swift
  import DDThumbnailMaker
  import CoreMedia
  ....

  // init DDThumbnailMaker
  let thumbnailMaker = DDThumbnailMaker.init(<URL>)

  // Or you init DDThumbnailMaker by setting your cutstomized AVAsset
  let thumbnailMaker = DDThumbnailMaker.init(<AVAsset>)

  // Set configuration - image size of output thumbnail
  thumbnailMaker.thumbnailImageSize = CGSize(width: <width>, height: <height>)

  // Set configuration - interval of Msec.
  thumbnailMaker.intervalMsec = 1000 //1000 mesc

  // Set configuration - interval of the number of frame. This ignores the settings of intervalMesec.
  thumbnailMaker.intervalFrame = 60 //60 frames

  // Set target duration - the specific time range of the video. Below is an example for setting targetDuration from 3.5sec to 5.2sec
  let startTime = CMTime(seconds: 3.5, preferredTimescale: CMTimeScale(NSEC_PER_MSEC))
  let endTime = CMTime(seconds: 5.2, preferredTimescale: CMTimeScale(NSEC_PER_MSEC))
  self.targetDuration = CMTimeRange(start: startTime, end: endTime)

  // Generate thumbnails.
  thumbnailMaker.generate { requestedTime, image, actualTime, result, error in
      // Do something when a thumbnail frame generated.
  } completion: {
      // Do something when generate completed.
  }
  
  ....
```
## Author

moxieDani, moxie2ks@gmail.com

## License

DDThumbnailMaker is available under the MIT license. See the LICENSE file for more info.
