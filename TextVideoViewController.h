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
@property(nonatomic, strong) UIImage *backgroundImage;
@property (weak, nonatomic) IBOutlet UITextField *inputText;

- (IBAction)createTextVideo:(id)sender;
-(void)exportDidFinish:(AVAssetExportSession*)session;
- (IBAction)createVideoByImage:(id)sender;

- (UIImage*) scaleImage: (UIImage*)originalImage toSize: (CGSize)newSize;
- (CVPixelBufferRef) newPixelBufferFromCGImage: (CGImageRef) image;

@end
