Pod::Spec.new do |s|
  s.name             = 'DDThumbnailMaker'
  s.version          = '0.3.1'
  s.summary          = 'DDThumbnailMaker is making thumbnail images by msec or frame.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  '''
  // init DDThumbnailMaker
  let thumbnailMaker = DDThumbnailMaker.init(<URL>)

  // Or you init DDThumbnailMaker by setting your cutstomized AVAsset
  let thumbnailMaker = DDThumbnailMaker.init(<AVAsset>)

  // Set configuration - image size of output thumbnail
  thumbnailMaker.thumbnailImageSize = CGSize(width: <width>, height: <height>)

  // Set configuration - interval of Msec.
  thumbnailMaker.intervalMsec = 1000

  // Set configuration - interval of the number of frame. This ignores the settings of intervalMesec.
  thumbnailMaker.intervalFrame = 60

  // Set target duration - the specific time range of the video. Below is an example for setting targetDuration from 3.5sec to 5.2sec
  let startTime = CMTime(seconds: 3.5, preferredTimescale: CMTimeScale(NSEC_PER_MSEC))
  let endTime = CMTime(seconds: 5.2, preferredTimescale: CMTimeScale(NSEC_PER_MSEC))
  thumbnailMaker.targetDuration = CMTimeRange(start: startTime, end: endTime)

  // Generate thumbnails.
  thumbnailMaker.generate { requestedTime, image, actualTime, result, error in
      // Do something when a thumbnail frame generated.
  } completion: {
      // Do something when generate completed.
  }
  '''
  DESC

  s.homepage         = 'https://github.com/moxieDani/DDThumbnailMaker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'moxieDani' => 'moxie2ks@gmail.com' }
  s.source           = { :git => 'https://github.com/moxieDani/DDThumbnailMaker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '16.0'

  s.source_files = 'DDThumbnailMaker/Classes/**/*'
  s.swift_version = '5.0'
  # s.resource_bundles = {
  #   'DDThumbnailMaker' => ['DDThumbnailMaker/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
