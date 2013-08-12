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
#import "VideoUtils.h"

@interface TextVideoViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputText;

- (IBAction)createTextVideo:(id)sender;
-(void)exportDidFinish:(AVAssetExportSession*)session;
- (IBAction)createVideoByImage:(id)sender;

@end
