//
//  ViewController.swift
//  ThumbnailGeneratorSwift
//
//  Created by Daniel on 2023/02/16.
//

import UIKit
import AVKit

class ViewController: UIViewController {
    
    var imageView = UIImageView(frame: CGRectMake(0,0,0,0))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imageView.backgroundColor = UIColor.black
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
        generator.maximumSize = CGSize(width: 192, height: 144)
        
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
        var times: [AnyHashable] = []
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
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
        if let times = times as? [NSValue] {
            generator.generateCGImagesAsynchronously(forTimes: times) {
                requestedTime, image, actualTime, result, error in
                    if result == .succeeded && actualTime.value != requestedTime.value {
                        var img: UIImage? = nil
                        if let image {
                            img = UIImage(cgImage: image)
                            if let data = img?.pngData() {
                                // Show thumbnail
                                DispatchQueue.main.async {
                                    self.imageView.frame = CGRectMake((self.view.frame.size.width / 2) - (img!.size.width / 2), (self.view.frame.size.height / 2) - (img!.size.height / 2), img!.size.width, img!.size.height);
                                    self.imageView.image = img
                                }
                                // Store thumbnail
                                let fileName = String(format: "%lld_sec.png", requestedTime.value / Int64(requestedTime.timescale))
                                let filePath = URL(fileURLWithPath: paths[0]).appendingPathComponent(fileName)
                                try? data.write(to: filePath)
                                print("Store file : \(fileName)")
                            }
                        }
                    }
            }
        }
    }

}

