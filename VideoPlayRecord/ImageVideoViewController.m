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
    
    images = [[NSMutableArray alloc] init];
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
    
    // Our VideoUtils has a method for rendering a list of images into a video
    [VideoUtils imagesToVideo:images withFrameTime:2500 completion:^(AVAssetWriter *videoWriter) {
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
    images = [[NSMutableArray alloc] init];
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
    [images addObject:image];
}


// Adding a "done" button to the top of the navigation bar
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    NSLog(@"Inside navigationController ...");
    
    
    if (!doneButton)
    {
        doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                      style:UIBarButtonItemStyleDone
                                                     target:self action:@selector(saveImagesDone:)];
    }
    
    viewController.navigationItem.rightBarButtonItem = doneButton;
}

// This method is called when the user clicked on the "done" button. Closing the image picker
- (IBAction)saveImagesDone:(id)sender
{
    NSLog(@"select images done ...");

    // Dismissing the image picker
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
