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
    
    // Getting a path and a URL to the video in this project
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"Red" ofType:@"mov"];
    NSURL   *videoURL = [NSURL fileURLWithPath:videoPath];
    
    // Initialaing the video asset with the video embedded in this project
    _videoAsset = [[AVURLAsset alloc]initWithURL:videoURL  options:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This method creates a new video using the embedded video and the text that the user has provided
- (IBAction)createTextVideo:(id)sender {
    
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *clipVideoTrack = [[_videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, _videoAsset.duration) ofTrack:clipVideoTrack atTime:kCMTimeZero error:nil];
    
    [compositionVideoTrack setPreferredTransform:[[[_videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];
    
    CGSize videoSize = [clipVideoTrack naturalSize];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];

    CATextLayer *titleLayer = [CATextLayer layer];
    titleLayer.string = self.inputText.text;
    //titleLayer.string = @"Text goes here";
    titleLayer.font = (__bridge CFTypeRef)(@"Helvetica");
    titleLayer.fontSize = videoSize.height / 6;
    //?? titleLayer.shadowOpacity = 0.5;
    titleLayer.alignmentMode = kCAAlignmentCenter;
    
    // Setting the rectangle in which the text will be showed in
    titleLayer.bounds = CGRectMake(0, 0, videoSize.width, videoSize.height / 5);
    
    // Positioning the text box (in the middle of the video)
    titleLayer.position = CGPointMake(videoSize.width/2, videoSize.height/2);
    [parentLayer addSublayer:titleLayer]; 
    
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = videoSize;
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack *videoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    
  /*
   [videoAsset release];
     */
    
    // Getting the documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Creating a full path to the video and getting it's URL
    NSString *videoFullPath =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"textVideo-%d.mov",arc4random() % 1000]];
    NSURL *videoUrl = [NSURL fileURLWithPath:videoFullPath];
    
    // Create the exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL=videoUrl;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = videoComp;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exportDidFinish:exporter];
        });
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
