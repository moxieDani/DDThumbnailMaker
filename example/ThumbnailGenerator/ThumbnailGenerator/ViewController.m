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
    NSURL* movURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"]];

    NSMutableDictionary* myDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES] ,
                                     AVURLAssetPreferPreciseDurationAndTimingKey ,
                                    [NSNumber numberWithInt:0],
                                    AVURLAssetReferenceRestrictionsKey, nil];

    AVURLAsset* movie = [[AVURLAsset alloc] initWithURL:movURL options:myDict];

    // set the generator
    AVAssetImageGenerator* generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:movie];
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.maximumSize = CGSizeMake(192, 144);
    // look for the video track
    AVAssetTrack* videoTrack;
    bool foundTrack = NO;

    for (AVAssetTrack* track in movie.tracks) {
        if ([track.mediaType isEqualToString:@"vide"]) {
            if (foundTrack) {
                NSLog (@"Error - - - more than one video tracks");
                return;
            }
            else {
                videoTrack = track;
                foundTrack = YES;
            }
        }
    }
    
    if (foundTrack == NO) {
        NSLog (@"Error - - No Video Tracks at all");
        return;
    }

    // set the number of frames in the movie
    int frameRate = videoTrack.nominalFrameRate;
    float value = movie.duration.value;
    float timeScale = movie.duration.timescale;
    float totalSeconds = value / timeScale;
    int totalFrames = totalSeconds * frameRate;
    int timeValuePerFrame = movie.duration.timescale / frameRate;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableArray *times=[[NSMutableArray alloc] init];

    // get each frame
    for (int k=0; k< totalFrames; k++) {
        int timeValue = timeValuePerFrame * k;
        CMTime frameTime;
        frameTime.value = timeValue;
        frameTime.timescale = movie.duration.timescale;
        frameTime.flags = movie.duration.flags;
        frameTime.epoch = movie.duration.epoch;
        NSLog (@"Frame %d Time Stamp %lld", k, frameTime.value*1000/frameTime.timescale);
        [times addObject:[NSValue valueWithCMTime:frameTime]];
    }
    
    
    [generator generateCGImagesAsynchronouslyForTimes:times
                                    completionHandler:^(CMTime requestedTime,
                                                        CGImageRef image,
                                                        CMTime actualTime,
                                                        AVAssetImageGeneratorResult result,
                                                        NSError *error) {
        NSString *requestedTimeString = (__bridge NSString *) CMTimeCopyDescription (NULL, requestedTime);
        NSString *actualTimeString = (__bridge NSString *) CMTimeCopyDescription(NULL, actualTime);
        NSLog(@"Requested: %@; actual %@", requestedTimeString, actualTimeString);

        if (result == AVAssetImageGeneratorSucceeded) {
            if (actualTime.value != requestedTime.value) {
                UIImage *img = [UIImage imageWithCGImage:image];
                NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"test_%lld.png",actualTime.value*1000/actualTime.timescale]];
    
                NSData *data = [NSData dataWithData:UIImagePNGRepresentation(img)];
                NSError *writeError = nil;
    
                [data writeToFile:filePath options:NSDataWritingAtomic error:&writeError];
    
                if (writeError) {
                  NSLog(@"Error writing file: %@", writeError);
                }
            }
        }

        if (result == AVAssetImageGeneratorFailed) {
          NSLog(@"Failed with error: %@", [error localizedDescription]);
        }

        if (result == AVAssetImageGeneratorCancelled) {
          NSLog(@"Canceled");
        }
    }];
}


@end
