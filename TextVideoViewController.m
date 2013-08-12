//
//  TextVideoViewController.m
//  VideoPlayRecord
//
//  Created by Tomer Harry on 8/7/13.
//  Copyright (c) 2013 Homage. All rights reserved.
//

#import "TextVideoViewController.h"

@interface TextVideoViewController ()

@end

@implementation TextVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This method creates a new video using the embedded video and the text that the user has provided
- (IBAction)createTextVideo:(id)sender {
    
    // Getting a path and a URL to the video in this project
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"Red" ofType:@"mov"];
    NSURL   *videoURL = [NSURL fileURLWithPath:videoPath];
    
    // Adding text on the video. The completion handler will be invoked once the new video is ready (or there are errors...)
    [VideoUtils textOnVideo:videoURL withText:self.inputText.text completion:^(AVAssetExportSession *exporter) {
        [self exportDidFinish:exporter];
    }];
}

// This method is called when the new video is ready to be saved
-(void)exportDidFinish:(AVAssetExportSession*)session
{
    NSURL *exportUrl = session.outputURL;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Validating that the new video can be saved in the photo album
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:exportUrl])
    {
        // Saving the video
        [library writeVideoAtPathToSavedPhotosAlbum:exportUrl completionBlock:^(NSURL *assetURL, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (error) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 } else {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                                    delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 }
             });
         }];
        
    }
    NSLog(@"Completed");
}

// This method creates a video using an image and text
- (IBAction)createVideoByImage:(id)sender {

    // Loading the background image
    NSString *backgroundfImagePath = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"jpg"];
    UIImage *backgroundImage = [UIImage imageWithContentsOfFile:backgroundfImagePath];
    
    // Converting the background image into a 3 sec video. Once it is ready the completion handler will be called - it will be responsile for adding the text to the video
    [VideoUtils imagesToVideo:[NSArray arrayWithObject:backgroundImage] withFrameTime:3000 completion:
     ^(AVAssetWriter *videoWriter) {
         [self videoWriterDidFinish:videoWriter];
     }];
}

// This method is triggered once the video writer is done and the video is ready (or there are errors...)
-(void)videoWriterDidFinish:(AVAssetWriter*)videoWriter
{
    // Checking the status of the video wirter
    if (videoWriter.status == AVAssetWriterStatusCompleted)
    {
        // Getting the output URL and validating we can save ir
        NSURL *outputVideoURL = videoWriter.outputURL;
        
        [VideoUtils textOnVideo:outputVideoURL withText:self.inputText.text completion:
         ^(AVAssetExportSession *exporter) {
            [self exportDidFinish:exporter];
        }];
    }
    else
    {
        // Printing the error to the log
        NSError *error = videoWriter.error;
        NSLog(@"Error: %@",error.description);
    }    
}

// This method is invoked when the user clicked on the return (done) button of a text field keyboard
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Closing the keyboard if this is the correct text field
    if (textField == _inputText)
    {
        [_inputText resignFirstResponder];
    }
    
    // Returning NO beacuse this is a non-default behaviuor
    return NO;
}

@end
