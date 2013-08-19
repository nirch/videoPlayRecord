//
//  TikimViewController.m
//  VideoPlayRecord
//
//  Created by Tomer Harry on 8/14/13.
//  Copyright (c) 2013 Homage. All rights reserved.
//

#import "TikimViewController.h"

@interface TikimViewController ()

@end

@implementation TikimViewController

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
    
    images = [[NSMutableArray alloc] init];
    imageSelection = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// This method is invoked when the user clicked on the return (done) button of a text field keyboard
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Closing the keyboard if this is the correct text field
    if (textField == _displayText)
    {
        [_displayText resignFirstResponder];
        
        // Creating a video with the text slide

        // Getting a path and a URL to the video in this project
        NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"Red" ofType:@"mov"];
        NSURL   *videoURL = [NSURL fileURLWithPath:videoPath];
        
        // Adding text on the video. The completion handler will be invoked once the new video is ready (or there are errors...)
        [VideoUtils textOnVideo:videoURL withText:self.displayText.text completion:^(AVAssetExportSession *exporter) {
            [self exportTextVideoFinish:exporter];
        }];

    }
    
    // Returning NO beacuse this is a non-default behaviuor
    return NO;
}


// This method is called when the new video is ready to be saved
-(void)exportTextVideoFinish:(AVAssetExportSession*)exporter
{
    textVideoUrl = exporter.outputURL;
    NSLog(@"Text video is ready");
}

// The below methods open the media picker to select images/videos.

- (IBAction)selectImages:(id)sender {
    
    imageSelection = YES;
    
    // Opening the media picker to select the images
    imagesPicker = [self startMediaBrowserFromViewController:self withMediaTypes:[[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil] usingDelegate:self ];
}

- (IBAction)selectPreRaceVideo:(id)sender {
    
    // Opening the media picker to select a video
    preRacePicker = [self startMediaBrowserFromViewController:self withMediaTypes:[[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil] usingDelegate:self ];
}

- (IBAction)selectFeetVideo:(id)sender {
    
    // Opening the media picker to select a video
    feetPicker = [self startMediaBrowserFromViewController:self withMediaTypes:[[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil] usingDelegate:self ];
}

- (IBAction)selectRaceVideo:(id)sender {
    
    // Opening the media picker to select a video
    racePicker = [self startMediaBrowserFromViewController:self withMediaTypes:[[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil] usingDelegate:self ];
}

- (IBAction)selectHeroLingersVideo:(id)sender {
    
    // Opening the media picker to select a video
    heroLingersPicker = [self startMediaBrowserFromViewController:self withMediaTypes:[[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil] usingDelegate:self ];
}

- (IBAction)selectFinishLineVideo:(id)sender {
    
    // Opening the media picker to select a video
    finishLinePicker = [self startMediaBrowserFromViewController:self withMediaTypes:[[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil] usingDelegate:self ];
}

- (IBAction)selectSighVideo:(id)sender {
    
    // Opening the media picker to select a video
    sighPicker = [self startMediaBrowserFromViewController:self withMediaTypes:[[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil] usingDelegate:self ];
}

// Creating the tikim video
- (IBAction)createTikimVideo:(id)sender {
    
    // Creating an array of all the videos that should be merged
    NSArray *videos = [[NSArray alloc] initWithObjects:textVideoUrl, imageVideoUrl, preRaceVideoScaledUrl, feetVideoScaledUrl,raceVideoScaledUrl,heroLingersVideoScaledUrl,finishLineVideoScaledUrl, sighVideoScaledUrl, nil];
    
    // Getting a path and a URL to the soundtrack in this project
    NSString *soundtrackPath = [[NSBundle mainBundle] pathForResource:@"Homage_Tikim" ofType:@"mp3"];
    NSURL   *soundtrackURL = [NSURL fileURLWithPath:soundtrackPath];
    
    // Merging the videos with the soundtrack. The completion block will be executed once the video is ready
    [VideoUtils mergeVideos:videos withSoundtrack:soundtrackURL completion:^(AVAssetExportSession *exporter){[self exportDidFinish:exporter];}];
}

// Called when the video is ready
-(void)exportDidFinish:(AVAssetExportSession*)exporter
{
    // Checking if the export session completed successfully
    if (exporter.status == AVAssetExportSessionStatusCompleted)
    {
       // Getting the exported video URL and validating if we can save it
        NSURL *outputURL = exporter.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL])
        {
            // Saving the video. This is an asynchronous process. The completion block (which is implemented here inline) will be invoked once the saving process finished
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
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
    }
    else
    {
        // Printing the error to the log
        NSError *error = exporter.error;
        NSLog(@"Error in merging the videos: %@",error.description);
    }
}

// Opening the media picker.
- (UIImagePickerController*)startMediaBrowserFromViewController:(UIViewController*)controller withMediaTypes:(NSArray*)mediaTypes usingDelegate:(id)delegate
{
    // Doing some valiadtions: checking whether the image picker is available or not and checking that there are no null values
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        || (delegate == nil)
        || (controller == nil))
    {
        return nil;
    }
    
    // OK, reaching here means that the image picker is available and we can proceed
    
    
    // Create an image picker
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.mediaTypes = mediaTypes;
    mediaUI.editing = NO;
    mediaUI.delegate = delegate;
    
    // Display the image picker
    [controller presentViewController:mediaUI animated:YES completion:nil];
    
    return mediaUI;
}

// This method is called after the user picked a media (images or video). Since we are selecting variuos medias in this view, we will first check from which picker this event was called, then we will scale the video to the desired duration, save the URL to the scaled video and close the picker
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if (picker == imagesPicker)
    {
        //We will save that image, but will not close the picker since we want the user to select multiple images. The picker will be closed only after the user clicks on the "done" button (see below)
        
        // Getting the image that the user selected
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSLog(@"image selected: %@",[image description]);
    
        // Adding the selected image to the images array
        [images addObject:image];
    }
    else if (picker == preRacePicker)
    {
        // Closing the picker and scaling the duration of this video
        [self dismissViewControllerAnimated:NO completion:nil];
        NSURL *preRaceVideoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        [VideoUtils scaleVideo:preRaceVideoUrl toDuration:CMTimeMake(560, 100) completion:^(AVAssetExportSession *exporter) {
            preRaceVideoScaledUrl = [self exportScaledVideoDidFinish:exporter withMessage:@"Pre-race Video"];
        }];
    }
    else if (picker == feetPicker)
    {
        // Closing the picker and scaling the duration of this video
        [self dismissViewControllerAnimated:NO completion:nil];
        NSURL *feetVideoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        [VideoUtils scaleVideo:feetVideoUrl toDuration:CMTimeMake(450, 100) completion:^(AVAssetExportSession *exporter) {
            feetVideoScaledUrl = [self exportScaledVideoDidFinish:exporter withMessage:@"Pre-race Video"];
        }];
    }
    else if (picker == racePicker)
    {
        // Closing the picker and scaling the duration of this video
        [self dismissViewControllerAnimated:NO completion:nil];
        NSURL *raceVideoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        [VideoUtils scaleVideo:raceVideoUrl toDuration:CMTimeMake(945, 100) completion:^(AVAssetExportSession *exporter) {
            raceVideoScaledUrl = [self exportScaledVideoDidFinish:exporter withMessage:@"Pre-race Video"];
        }];
    }
    else if (picker == heroLingersPicker)
    {
        // Closing the picker and scaling the duration of this video
        [self dismissViewControllerAnimated:NO completion:nil];
        NSURL *heroLingersVideoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        [VideoUtils scaleVideo:heroLingersVideoUrl toDuration:CMTimeMake(600, 100) completion:^(AVAssetExportSession *exporter) {
            heroLingersVideoScaledUrl = [self exportScaledVideoDidFinish:exporter withMessage:@"Pre-race Video"];
        }];
    }
    else if (picker == finishLinePicker)
    {
        // Closing the picker and scaling the duration of this video
        [self dismissViewControllerAnimated:NO completion:nil];
        NSURL *finishLineVideoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        [VideoUtils scaleVideo:finishLineVideoUrl toDuration:CMTimeMake(1530, 100) completion:^(AVAssetExportSession *exporter) {
            finishLineVideoScaledUrl = [self exportScaledVideoDidFinish:exporter withMessage:@"Pre-race Video"];
        }];
    }
    else if (picker == sighPicker)
    {
        // Closing the picker and scaling the duration of this video
        [self dismissViewControllerAnimated:NO completion:nil];
        NSURL *sighVideoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        [VideoUtils scaleVideo:sighVideoUrl toDuration:CMTimeMake(340, 100) completion:^(AVAssetExportSession *exporter) {
            sighVideoScaledUrl = [self exportScaledVideoDidFinish:exporter withMessage:@"Pre-race Video"];
        }];
    }
}

// Called when the scaling of the video is ready
-(NSURL*)exportScaledVideoDidFinish:(AVAssetExportSession*)exporter withMessage:(NSString*) message
{
    // Checking the status of the video wirter
    if (exporter.status == AVAssetExportSessionStatusCompleted)
    {
        // Getting the output URL
        NSLog(@"%@ scaled is ready", message);
        return exporter.outputURL;
    }
    else
    {
        // Printing the error to the log
        NSError *error = exporter.error;
        NSLog(@"%@ scaled error: %@",message, error.description);
        return nil;
    }
}

// Adding a "done" button to the top of the navigation bar
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    // Adding the "done" button only if we are selecting images
    if (imageSelection)
    {
        NSLog(@"Inside navigationController ...");
    
        if (!doneButton)
        {
            doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(saveImagesDone:)];
        }
        
        viewController.navigationItem.rightBarButtonItem = doneButton;
    }
}

// This method is called when the user clicked on the "done" button. Closing the image picker
- (IBAction)saveImagesDone:(id)sender
{
    NSLog(@"select images done ...");
    
    // Dismissing the image picker
    [self dismissViewControllerAnimated:YES completion:nil];
    
    imageSelection = NO;
    
    // Creating a video from a list of images. The completion handler will be invoked once the new video is ready (or there are errors...)
    [VideoUtils imagesToVideo:images withFrameTime:1000 completion:^(AVAssetWriter *videoWriter) {
        [self videoWriterDidFinish:videoWriter];
    }];
    
}

// This method is triggered once the video writer is done and the video is ready (or there are errors...)
-(void)videoWriterDidFinish:(AVAssetWriter*)videoWriter
{
    // Checking the status of the video wirter
    if (videoWriter.status == AVAssetWriterStatusCompleted)
    {
        // Getting the output URL
        imageVideoUrl = videoWriter.outputURL;
        NSLog(@"Image video is ready");
        
    }
    else
    {
        // Printing the error to the log
        NSError *error = videoWriter.error;
        NSLog(@"Image video error: %@",error.description);
    }
    
    // Initializing the images array
    images = [[NSMutableArray alloc] init];
}


@end
