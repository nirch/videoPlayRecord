//
//  ImageVideoViewController.m
//  VideoPlayRecord
//
//  Created by Tomer Harry on 7/23/13.
//  Copyright (c) 2013 Homage. All rights reserved.
//

#import "ImageVideoViewController.h"

@interface ImageVideoViewController ()

@end

@implementation ImageVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Initializing the images array
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _images = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This event will be trigged when the user clicks on the "Load Image" button. We will let the user pick an image from the photo library and save his choice
- (IBAction)loadImage:(id)sender
{
    BOOL result = [self startMediaBrowserFromViewController:self usingDelegate:self];
    
    // Showing the user a notification if the photo album is not available
    if (result == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Saved Album Found"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

// This method is called when the user clicks on the "Create Video" button. It will create a video based on the selected photos
- (IBAction)createVideo:(id)sender {
    
    
    NSError *error = nil;
    
    // Create the URL to which the video will be stored/saved
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
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

    // Looping over all the images we want to append to the video
    for(UIImage *image in _images)
    {
        // Resizing image to 640:480
        UIImage *scaledImage = [self scaleImage:image toSize:CGSizeMake(640.0, 480.0)];
        
        // Appending image to asset writer
        BOOL appendSuccess = [assetWriterInputPixelAdapter appendPixelBuffer:[self newPixelBufferFromCGImage:scaledImage.CGImage] withPresentationTime:presentTime];
        NSLog(appendSuccess ? @"Append Success" : @"Append Failed");
        
        // Increasing the present time
        presentTime = CMTimeAdd(presentTime,frameTime);
    }
    
    // If there is only one image in the array, there is a need to append it again in the last time (otherwise the video will always be 0 seconds long)
    if (_images.count == 1)
    {
        // Resizing image to 640:480
        UIImage *scaledImage = [self scaleImage:[_images objectAtIndex:0] toSize:CGSizeMake(640.0, 480.0)];
        
        // Appending image to asset writer
        BOOL appendSuccess = [assetWriterInputPixelAdapter appendPixelBuffer:[self newPixelBufferFromCGImage:scaledImage.CGImage] withPresentationTime:presentTime];
        NSLog(appendSuccess ? @"Append Success" : @"Append Failed");
    }
    
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
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL])
        {
            // Saving the video. This is an asynchronous process. The completion block (which is implemented here inline) will be invoked once the saving process finished
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Checking if there was an error and notifying the user accordingly
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
    }
    else
    {
        // Printing the error to the log
        NSError *error = videoWriter.error;
        NSLog(@"Error: %@",error.description);
    }

    // Initializing the images array
    _images = [[NSMutableArray alloc] init];
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


// Opening the image picker
- (BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate
{
    // Doing some valiadtions: checking whether the image picker is available or not and checking that there are no null values
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        || (delegate == nil)
        || (controller == nil))
    {
        return NO;
    }
    
    // OK, reaching here means that the image picker is available and we can proceed
    
    
    // Create an image picker
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
    mediaUI.editing = NO;
    mediaUI.delegate = delegate;
    
    // Display the image picker
    //[controller presentModalViewController: mediaUI animated: YES];
    [controller presentViewController:mediaUI animated:YES completion:nil];
    
    return YES;
}

// This method is called after the user picked a media (image in our case). We will save that image, but will not close the picker since we want the user to select multiple images. The picker will be closed only after the user clicks on the "done" button (see below)
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Getting the image that the user selected
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"image selected: %@",[image description]);
    
    // Adding the selected image to the images array
    [_images addObject:image];
}


// Adding a "done" button to the top of the navigation bar
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    NSLog(@"Inside navigationController ...");
    
    
    if (!_doneButton)
    {
        _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                      style:UIBarButtonItemStyleDone
                                                     target:self action:@selector(saveImagesDone:)];
    }
    
    viewController.navigationItem.rightBarButtonItem = _doneButton;
}

// This method is called when the user clicked on the "done" button. Closing the image picker
- (IBAction)saveImagesDone:(id)sender
{
    NSLog(@"select images done ...");

    // Dismissing the image picker
    [self dismissViewControllerAnimated:YES completion:nil];
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




@end
