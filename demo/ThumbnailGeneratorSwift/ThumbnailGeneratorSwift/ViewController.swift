//
//  ViewController.swift
//  ThumbnailGeneratorSwift
//
//  Created by Daniel on 2023/02/16.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    var imageView = UIImageView()
    var thumbnailImageWidth = CGFloat(192)
    var thumbnailImageHeight = CGFloat(144)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.imageView.frame = CGRectMake((self.view.frame.size.width / 2) - (self.thumbnailImageWidth / 2),
                                          (self.view.frame.size.height / 2) - (self.thumbnailImageHeight / 2),
                                          self.thumbnailImageWidth,
                                          self.thumbnailImageHeight);
        self.view.addSubview(imageView)
        test()
    }

    func test() {
        Task {
            await extractImagesFromavAsset()
        }
    }
    
    func extractImagesFromavAsset() async {
        let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "test", ofType: "mp4") ?? "")
        let avAsset = AVAsset(url: videoURL)

        // set the generator
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        generator.maximumSize = CGSize(width: self.thumbnailImageWidth, height: self.thumbnailImageHeight)
        
        // look for the video track
        let tracks = try? await avAsset.load(.tracks)
        var foundTrack : AVAssetTrack? = nil;
        for i in 0..<Int(tracks!.count) {
            if tracks![i].mediaType.rawValue == "vide" {
                foundTrack = tracks![i]
                break
            }
        }

        if foundTrack == nil {
            print("Error - - No Video Tracks")
            return
        }

        // set the information about frames in the avAsset
        let frameRate = try? await Int(foundTrack?.load(.nominalFrameRate) ?? 0)

        let value = try? await Float(avAsset.load(.duration).value)
        let timeScale = try? await Float(avAsset.load(.duration).timescale)
        let flags = try? await avAsset.load(.duration).flags
        let epoch = try? await avAsset.load(.duration).epoch

        let totalSeconds = value! / timeScale!
        let totalFrames = Int(totalSeconds * Float(frameRate!))
        let timeValuePerFrame = Int(timeScale!) / frameRate!
        
        print("total frames \(totalFrames)")
        
        // get each frame
        var times: [NSValue] = []
        for k in 1...totalFrames {
            let timeValue = UInt(timeValuePerFrame * k)
            let timeStampMsec = UInt(timeValue * 1000) / UInt(timeScale!)

            // Set times every seconds : 1st frame + frame at 1000*n msec.
            if k == 1 || timeStampMsec % 1000 == 0 {
                var frameTime: CMTime! = CMTime()
                frameTime.value = CMTimeValue(timeValue)
                frameTime.timescale = CMTimeScale(timeScale!)
                frameTime.flags = flags!
                frameTime.epoch = epoch!
                print(String(format: "Set time at Frame %d Time Stamp %lld", k, CMTimeScale(frameTime.value * 1000) / frameTime.timescale))
                times.append(NSValue(time: frameTime))
            }
        }

        // Show & store thumbnails every seconds.
        let storePaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
        generator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, image, actualTime, result, error) in
            if result == .succeeded && actualTime.value != requestedTime.value {
                let img = UIImage(cgImage: image!)
                // Show thumbnail
                DispatchQueue.main.async {
                    self.imageView.image = img
                }
                // Store thumbnail
                if let data = img.pngData() {
                    let fileName = String(format: "%lld_sec.png", requestedTime.value / Int64(requestedTime.timescale))
                    let filePath = URL(fileURLWithPath: storePaths[0]).appendingPathComponent(fileName)
                    try? data.write(to: filePath)
                    print("Store file : \(fileName)")
                }
            }
        }
    }

}

