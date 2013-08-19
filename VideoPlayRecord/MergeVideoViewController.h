//
//  MergeVideoViewController.h
//  VideoPlayRecord
//
//  Created by Tomer Harry on 7/15/13.
//  Copyright (c) 2013 Homage. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VideoUtils.h"

@interface MergeVideoViewController: UIViewController {
    BOOL isSelectingAssetOne;
    NSMutableArray *videoURLs;
}

@property(nonatomic, strong) AVAsset *firstAsset;
@property(nonatomic, strong) AVAsset *secondAsset;
@property(nonatomic, strong) AVAsset *audioAsset;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property(nonatomic, strong) NSURL *audioURL;


-(IBAction)loadAssetOne:(id)sender;
-(IBAction)loadAssetTwo:(id)sender;
-(IBAction)loadAudio:(id)sender;
-(IBAction)mergeAndSave:(id)sender;
-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;
-(void)exportDidFinish:(AVAssetExportSession*)session;
- (IBAction)speedVideo:(id)sender;
- (IBAction)slowVideo:(id)sender;

@end
