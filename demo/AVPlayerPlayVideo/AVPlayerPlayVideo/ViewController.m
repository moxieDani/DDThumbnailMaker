//
//  ViewController.m
//  AVPlayerPlayVideo
//
//  Created by Daniel on 2023/02/14.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadView {
    [super loadView];
    NSURL *_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"]];
    UIView *playerView = [[UIView alloc] initWithFrame:CGRectMake(30, 50, 320, 240)];
    playerView.backgroundColor = [UIColor blackColor];

    {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:_url];
        AVPlayer *avPlayer = [AVPlayer playerWithPlayerItem:playerItem];

        {
            AVPlayerLayer *avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer: avPlayer];
            avPlayerLayer.frame = CGRectMake(0, 0, 320, 240);
            avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            [playerView.layer addSublayer:avPlayerLayer];
            [self.view addSubview:playerView];
        }

        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[ avPlayer currentItem]];
        [avPlayer play];
    }

}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    NSLog(@"video end");
}

@end
