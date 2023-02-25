//
//  DDThumbnailMaker.swift
//  DDThumbnailMaker
//
//  Created by Daniel on 2023/02/22.
//

import Foundation
import UIKit
import AVKit

public class DDThumbnailMaker {
    public var avAsset : AVAsset? = nil
    public var intervalMsec: UInt? = 1000
    public var intervalFrame: UInt? = 0
    public var thumbnailImageSize: CGSize? = CGSize(width: 192, height: 144)
    
    private var generator : AVAssetImageGenerator? = nil

    public init(_ avAsset: AVAsset) {
        self.avAsset = avAsset
    }
    
    public init(_ url:URL) {
        self.avAsset = AVAsset(url: url)
    }
    
    public func generate(_ completionHandler:@escaping (CMTime, CGImage?, CMTime, AVAssetImageGenerator.Result, NSError?) ->Void) {
        Task {
            await generateInternal(completionHandler)
        }
    }
    
    private func generateInternal(_ completionHandler:@escaping (CMTime, CGImage?, CMTime, AVAssetImageGenerator.Result, NSError?) ->Void) async {
        // Get requested asset times
        let times = await getRequestedAssetTimes(self.avAsset!)

        // AVAssetImageGenerator work
        let generator = getAVAssetImageGenerator(self.avAsset!)
        generator.generateCGImagesAsynchronously(forTimes: times) { (requestedTime, image, actualTime, result, error) in
            completionHandler(requestedTime, image, actualTime, result, error as NSError?)
        }
    }
    
    private func getAVAssetImageGenerator(_ avAsset: AVAsset) -> AVAssetImageGenerator {
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        generator.maximumSize = self.thumbnailImageSize!
        
        return generator
    }
    
    private func getRequestedAssetTimes(_ avAsset: AVAsset) async -> [NSValue] {
        // Get information about avAsset
        let videoTracks = try! await avAsset.loadTracks(withMediaType: .video)
        let frameRate = videoTracks.count > 0 ? try! await Int(videoTracks[0].load(.nominalFrameRate)) : 0

        let value = try? await Float(avAsset.load(.duration).value)
        let timeScale = try? await Float(avAsset.load(.duration).timescale)
        let flags = try? await avAsset.load(.duration).flags
        let epoch = try? await avAsset.load(.duration).epoch

        let durationTimeMesc = Int(value!)*1000 / Int(timeScale!)
        let numberOfFrames = Int(durationTimeMesc * frameRate)/1000
        let timeValuePerFrame = Int(timeScale!) / frameRate
        
        var times: [NSValue] = []
        for i in 1...numberOfFrames {
            let timeValue = UInt(timeValuePerFrame * i)
            let timeStampMsec = UInt(timeValue * 1000) / UInt(timeScale!)

            var shouldAppend = false
            if self.intervalFrame! > 0 {
                shouldAppend = (UInt(i) % self.intervalFrame! == 0)
            } else {
                shouldAppend = (timeStampMsec % self.intervalMsec! == 0)
            }
            
            if i == 1 || shouldAppend {
                let frameTime = CMTime(value: CMTimeValue(timeValue), timescale: CMTimeScale(timeScale!), flags: flags!, epoch: epoch!)
                times.append(NSValue(time: frameTime))
            }
        }

        return times
    }
}


