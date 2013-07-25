//
//  ImageVideoViewController.h
//  VideoPlayRecord
//
//  Created by Tomer Harry on 7/23/13.
//  Copyright (c) 2013 Homage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface ImageVideoViewController : UIViewController {
    NSMutableArray *_images;
    UIBarButtonItem *_doneButton;
}

- (IBAction)loadImage:(id)sender;

- (IBAction)createVideo:(id)sender;

// Opening the image/video picker
- (BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;

@end
