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

@interface ImageVideoViewController : UIViewController {
    NSMutableArray *_images;
    UIBarButtonItem *_doneButton;
}

- (IBAction)loadImage:(id)sender;

- (IBAction)createVideo:(id)sender;

// Opening the image/video picker
- (BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;

// Creating a CVPixelBuffer from a CGImage
- (CVPixelBufferRef) newPixelBufferFromCGImage: (CGImageRef) image;

-(void)videoWriterDidFinish:(AVAssetWriter*)videoWriter;

// Scaling a given image to a given size
- (UIImage*) scaleImage: (UIImage*)originalImage toSize: (CGSize)newSize;

@end
