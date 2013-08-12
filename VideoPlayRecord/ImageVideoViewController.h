//
//  ImageVideoViewController.h
//  VideoPlayRecord
//
//  Created by Tomer Harry on 7/23/13.
//  Copyright (c) 2013 Homage. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "VideoUtils.h"

@interface ImageVideoViewController : UIViewController {
    NSMutableArray *images;
    UIBarButtonItem *doneButton;
}

// Select images
- (IBAction)loadImage:(id)sender;

// Creating a video from the selected images
- (IBAction)createVideo:(id)sender;

// Opening the image/video picker
- (BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;

// completion handler for when the video is ready
-(void)videoWriterDidFinish:(AVAssetWriter*)videoWriter;

@end
