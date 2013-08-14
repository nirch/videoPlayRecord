//
//  TikimViewController.h
//  VideoPlayRecord
//
//  Created by Tomer Harry on 8/14/13.
//  Copyright (c) 2013 Homage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "VideoUtils.h"

@interface TikimViewController : UIViewController{
    NSMutableArray *images;
    UIBarButtonItem *doneButton;
    
    UIImagePickerController *imagesPicker;
    UIImagePickerController *preRacePicker;
    UIImagePickerController *feetPicker;
    UIImagePickerController *racePicker;
    UIImagePickerController *heroLingersPicker;
    UIImagePickerController *finishLinePicker;
    UIImagePickerController *sighPicker;
    
    
    NSURL *preRaceVideoUrl;
    NSURL *feetVideoUrl;
    NSURL *raceVideoUrl;
    NSURL *heroLingersVideoUrl;
    NSURL *finishLineVideoUrl;
    NSURL *sighVideoUrl;
    
    NSURL *textVideoUrl;
    NSURL *imageVideoUrl;
    
    BOOL imageSelection;
}


@property (weak, nonatomic) IBOutlet UITextField *displayText;
- (IBAction)selectImages:(id)sender;
- (IBAction)selectPreRaceVideo:(id)sender;
- (IBAction)selectFeetVideo:(id)sender;
- (IBAction)selectRaceVideo:(id)sender;
- (IBAction)selectHeroLingersVideo:(id)sender;
- (IBAction)selectFinishLineVideo:(id)sender;
- (IBAction)selectSighVideo:(id)sender;
- (IBAction)createTikimVideo:(id)sender;

// This methods loads the media browser picker. Whoever invokes this method can decide which media types (e.g. video, image)to show in the media browser
- (UIImagePickerController*)startMediaBrowserFromViewController:(UIViewController*)controller withMediaTypes:(NSArray*)mediaTypes usingDelegate:(id)delegate;

// This method is called when the new video is ready to be saved
-(void)exportTextVideoFinish:(AVAssetExportSession*)exporter;

// Called when the video is ready
-(void)exportDidFinish:(AVAssetExportSession*)exporter;

@end
