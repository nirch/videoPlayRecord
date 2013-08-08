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
    
    // Loading the background image
    NSString *backgroundfImagePath = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"jpg"];
    _backgroundImage = [UIImage imageWithContentsOfFile:backgroundfImagePath];

    
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

// This method creates a video using an image and text
- (IBAction)createVideoByImage:(id)sender {

    NSError *error = nil;
    
    // Getting the path to the documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Creating a full path and URL to the image video
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"imageVideo-%d.mov",arc4random() % 1000]];
    NSURL *outptUrl = [NSURL fileURLWithPath:myPathDocs];
    
    // Creating the container to which the video will be written to
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:outptUrl fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    
    // Specifing settings for the new video (codec, width, hieght)
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:640], AVVideoWidthKey,
                                   [NSNumber numberWithInt:480], AVVideoHeightKey,
                                   nil];
    
    // Creating a writer input
    AVAssetWriterInput* writerInput = [AVAssetWriterInput
                                       assetWriterInputWithMediaType:AVMediaTypeVideo
                                       outputSettings:videoSettings];
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    // Connecting the writer input with the video wrtier
    [videoWriter addInput:writerInput];
    
    // Creating an AVAssetWriterInputPixelBufferAdaptor based on writerInput
    AVAssetWriterInputPixelBufferAdaptor *assetWriterInputPixelAdapter = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    
    // Start writing
    [videoWriter startWriting];
    
    // The duration of each frame in the video is "frameTime". The present time for each fram will start at 0 and then we will add the frame time to the present time for each frame
    CMTime frameTime = CMTimeMake(3000, 1000);
    CMTime presentTime = CMTimeMake(0, 1000);
    [videoWriter startSessionAtSourceTime:kCMTimeZero];

    // Resizing image to 640:480
    UIImage *scaledBackgroundImage = [self scaleImage:_backgroundImage toSize:CGSizeMake(640.0, 480.0)];
        
    // Appending image to asset writer
    BOOL appendSuccess = [assetWriterInputPixelAdapter appendPixelBuffer:[self newPixelBufferFromCGImage:scaledBackgroundImage.CGImage] withPresentationTime:presentTime];
    NSLog(appendSuccess ? @"Append Success" : @"Append Failed");
        
    // Increasing the present time
    presentTime = CMTimeAdd(presentTime,frameTime);

    // There is a need to append it again in the last time (otherwise the video will always be 0 seconds long)
    BOOL appendSuccess2 = [assetWriterInputPixelAdapter appendPixelBuffer:[self newPixelBufferFromCGImage:scaledBackgroundImage.CGImage] withPresentationTime:presentTime];
    NSLog(appendSuccess2 ? @"Append Success" : @"Append Failed");
    
    
    // Finishing the video. The actaul finish process is asynchronic, so we are assigning a completion handler to be invoked once the the video is ready ("videoWriterDidFinish")
    [writerInput markAsFinished];
    [videoWriter endSessionAtSourceTime:presentTime];
    [videoWriter finishWritingWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self videoWriterDidFinish:videoWriter];
        });
    }];
}


// This method is triggered once the video writer is done and the video is ready (or there are errors...)
-(void)videoWriterDidFinish:(AVAssetWriter*)videoWriter
{
    // Checking the status of the video wirter
    if (videoWriter.status == AVAssetWriterStatusCompleted)
    {
        // Getting the output URL and validating we can save ir
        NSURL *outputURL = videoWriter.outputURL;
        
        // Initialaing the video asset with the video embedded in this project
        _videoAsset = [[AVURLAsset alloc]initWithURL:outputURL  options:nil];
        
        [self createTextVideo:self];
    }
    else
    {
        // Printing the error to the log
        NSError *error = videoWriter.error;
        NSLog(@"Error: %@",error.description);
    }    
}



// Returning a new imaged scaled to the given size using a given image
- (UIImage*) scaleImage: (UIImage*)originalImage toSize: (CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [originalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

// Creating a CVPixelBuffer from a CGImage
- (CVPixelBufferRef) newPixelBufferFromCGImage: (CGImageRef) image
{
    CGSize frameSize = CGSizeMake(640.0, 480.0);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height, kCVPixelFormatType_32ARGB, (__bridge  CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
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
