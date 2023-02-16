//
//  ViewController.m
//  ThumbnailGenerator
//
//  Created by Daniel on 2023/02/15.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self extractImagesFromMovie];
    NSLog (@"Done.");
}

    
-(void)extractImagesFromMovie {
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"]];

    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES] ,
                                     AVURLAssetPreferPreciseDurationAndTimingKey ,
                                    [NSNumber numberWithInt:0],
                                    AVURLAssetReferenceRestrictionsKey, nil];

    AVURLAsset* avUrlAsset = [[AVURLAsset alloc] initWithURL:url options:dict];

    // set the generator
    AVAssetImageGenerator* generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:avUrlAsset];
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.maximumSize = CGSizeMake(192, 144);

    // look for the video track
    AVAssetTrack* videoTrack = nil;
    bool foundTrack = NO;

    for (AVAssetTrack* track in avUrlAsset.tracks) {
        if ([track.mediaType isEqualToString:@"vide"]) {
            if (foundTrack) {
                NSLog (@"Error - - - more than one video tracks");
                return;
            } else {
                videoTrack = track;
                foundTrack = YES;
            }
        }
    }
    
    if (videoTrack == nil) {
        NSLog (@"Error - - No Video Tracks at all");
        return;
    }

    // set the number of frames in the movie
    int frameRate = videoTrack.nominalFrameRate;
    float value = avUrlAsset.duration.value;
    float timeScale = avUrlAsset.duration.timescale;
    float totalSeconds = value / timeScale;
    int totalFrames = totalSeconds * frameRate;
    int timeValuePerFrame = avUrlAsset.duration.timescale / frameRate;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableArray *times=[[NSMutableArray alloc] init];

    // get each frame
    for (int k=1; k<=totalFrames; k++) {
        unsigned long timeValue = timeValuePerFrame * k;
        unsigned int timeStampMsec = timeValue*1000 / timeScale;

        // Set times every seconds : 1st frame + frame at 1000*n msec.
        if (k == 1 || timeStampMsec % 1000 == 0) {
            CMTime frameTime;
            frameTime.value = timeValue;
            frameTime.timescale = timeScale;
            frameTime.flags = avUrlAsset.duration.flags;
            frameTime.epoch = avUrlAsset.duration.epoch;
            NSLog (@"Set time at Frame %d Time Stamp %lld", k, frameTime.value*1000/frameTime.timescale);
            [times addObject:[NSValue valueWithCMTime:frameTime]];
        }
    }
    
    [generator generateCGImagesAsynchronouslyForTimes:times
                                    completionHandler:^(CMTime requestedTime,
                                                        CGImageRef image,
                                                        CMTime actualTime,
                                                        AVAssetImageGeneratorResult result,
                                                        NSError *error) {
        NSString *requestedTimeString = (__bridge NSString *) CMTimeCopyDescription (NULL, requestedTime);
        NSString *actualTimeString = (__bridge NSString *) CMTimeCopyDescription(NULL, actualTime);

        if (result == AVAssetImageGeneratorSucceeded) {
            if (actualTime.value != requestedTime.value) {
                UIImage *img = [UIImage imageWithCGImage:image];
                NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld_sec.png",requestedTime.value/requestedTime.timescale]];
    
                NSData *data = [NSData dataWithData:UIImagePNGRepresentation(img)];
                NSError *writeError = nil;
    
                [data writeToFile:filePath options:NSDataWritingAtomic error:&writeError];
    
                if (writeError) {
                    NSLog(@"Error writing file: %@", writeError);
                } else {
                    NSLog(@"Generated '%lld_sec.png'", requestedTime.value/requestedTime.timescale);
                }
            }
        } else if (result == AVAssetImageGeneratorFailed) {
            NSLog(@"Failed with error: %@", [error localizedDescription]);
        } else if (result == AVAssetImageGeneratorCancelled) {
            NSLog(@"Canceled");
        }
    }];
}


@end
