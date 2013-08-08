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



@interface TextVideoViewController : UIViewController <UITextFieldDelegate>

@property(nonatomic, strong) AVURLAsset *videoAsset;
@property (weak, nonatomic) IBOutlet UITextField *inputText;

- (IBAction)createTextVideo:(id)sender;
-(void)exportDidFinish:(AVAssetExportSession*)session;

@end
