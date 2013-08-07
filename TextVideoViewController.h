//
//  TextVideoViewController.h
//  VideoPlayRecord
//
//  Created by Tomer Harry on 8/7/13.
//  Copyright (c) 2013 Homage. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>



@interface TextVideoViewController : UIViewController

@property(nonatomic, strong) AVURLAsset *videoAsset;

- (IBAction)selectVideo:(id)sender;
- (IBAction)createTextVideo:(id)sender;
-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;
-(void)exportDidFinish:(AVAssetExportSession*)session;
@end
