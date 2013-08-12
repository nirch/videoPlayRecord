//
//  MergeVideoViewController.m
//  VideoPlayRecord
//
//  Created by Tomer Harry on 7/15/13.
//  Copyright (c) 2013 Homage. All rights reserved.
//

#import "MergeVideoViewController.h"

@interface MergeVideoViewController ()

@end

@implementation MergeVideoViewController

@synthesize firstAsset, secondAsset, audioAsset, audioURL;
@synthesize activityView;

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
    
    videoURLs = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadAssetOne:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Saved Album Found"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        isSelectingAssetOne = TRUE;
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}

- (IBAction)loadAssestTwo:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Saved Album Found"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        isSelectingAssetOne = FALSE;
        [self startMediaBrowserFromViewController:self usingDelegate:self];
    }
}

- (IBAction)loadAudio:(id)sender {
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
    mediaPicker.delegate = self;
    mediaPicker.prompt = @"Select Audio";
    [self presentModalViewController:mediaPicker animated:YES];
}

- (IBAction)mergeAndSave:(id)sender {
    
    [VideoUtils mergeVideos:[videoURLs copy] withSoundtrack:audioURL completion:^(AVAssetExportSession *exporter){[self exportDidFinish:exporter];}];

    
//    ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self exportDidFinish:exporter];
//        });
//    }{
/*
    if (firstAsset !=nil && secondAsset!=nil) {
        [activityView startAnimating];
        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        
        // 2 - Create two video tracks
        AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration)
                            ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                             preferredTrackID:kCMPersistentTrackID_Invalid];
        [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration) 
                             ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:firstAsset.duration error:nil];
        
        AVMutableVideoCompositionInstruction *MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration));
        
        // Fixing Orientation
        AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
        AVAssetTrack *FirstAssetTrack = [[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        CGSize firstSize = FirstAssetTrack.naturalSize;
        UIImageOrientation FirstAssetOrientation_  = UIImageOrientationUp;
        BOOL  isFirstAssetPortrait_  = NO;
        CGAffineTransform firstTransform = FirstAssetTrack.preferredTransform;
        if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)  {FirstAssetOrientation_= UIImageOrientationRight; isFirstAssetPortrait_ = YES;}
        if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)  {FirstAssetOrientation_ =  UIImageOrientationLeft; isFirstAssetPortrait_ = YES;}
        if(firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0)   {FirstAssetOrientation_ =  UIImageOrientationUp;}
        if(firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0) {FirstAssetOrientation_ = UIImageOrientationDown;}
        CGFloat FirstAssetScaleToFitRatio = 320.0/FirstAssetTrack.naturalSize.width;
        if(isFirstAssetPortrait_){
            FirstAssetScaleToFitRatio = 320.0/FirstAssetTrack.naturalSize.height;
            CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
            [FirstlayerInstruction setTransform:CGAffineTransformConcat(FirstAssetTrack.preferredTransform, FirstAssetScaleFactor) atTime:kCMTimeZero];
        }else{
            //CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
            //[FirstlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(FirstAssetTrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
            [FirstlayerInstruction setTransform:FirstAssetTrack.preferredTransform atTime:kCMTimeZero];
        }
        [FirstlayerInstruction setOpacity:0.0 atTime:firstAsset.duration];
        
        AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
        AVAssetTrack *SecondAssetTrack = [[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        CGSize seconfSize = SecondAssetTrack.naturalSize;
        UIImageOrientation SecondAssetOrientation_  = UIImageOrientationUp;
        BOOL  isSecondAssetPortrait_  = NO;
        CGAffineTransform secondTransform = SecondAssetTrack.preferredTransform;
        if(secondTransform.a == 0 && secondTransform.b == 1.0 && secondTransform.c == -1.0 && secondTransform.d == 0)  {SecondAssetOrientation_= UIImageOrientationRight; isSecondAssetPortrait_ = YES;}
        if(secondTransform.a == 0 && secondTransform.b == -1.0 && secondTransform.c == 1.0 && secondTransform.d == 0)  {SecondAssetOrientation_ =  UIImageOrientationLeft; isSecondAssetPortrait_ = YES;}
        if(secondTransform.a == 1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == 1.0)   {SecondAssetOrientation_ =  UIImageOrientationUp;}
        if(secondTransform.a == -1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == -1.0) {SecondAssetOrientation_ = UIImageOrientationDown;}
        CGFloat SecondAssetScaleToFitRatio = 320.0/SecondAssetTrack.naturalSize.width;
        if(isSecondAssetPortrait_){
            SecondAssetScaleToFitRatio = 320.0/SecondAssetTrack.naturalSize.height;
            CGAffineTransform SecondAssetScaleFactor = CGAffineTransformMakeScale(SecondAssetScaleToFitRatio,SecondAssetScaleToFitRatio);
            [SecondlayerInstruction setTransform:CGAffineTransformConcat(SecondAssetTrack.preferredTransform, SecondAssetScaleFactor) atTime:firstAsset.duration];
        }else{
            ;
            //CGAffineTransform SecondAssetScaleFactor = CGAffineTransformMakeScale(SecondAssetScaleToFitRatio,SecondAssetScaleToFitRatio);
            //[SecondlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(SecondAssetTrack.preferredTransform, SecondAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:firstAsset.duration];
            [SecondlayerInstruction setTransform:SecondAssetTrack.preferredTransform atTime:firstAsset.duration];
        }
        
        MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];;
        
        AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
        MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
        MainCompositionInst.frameDuration = CMTimeMake(1, 30);
        
        
        CGSize naturalSizeFirst, naturalSizeSecond;
        if(isFirstAssetPortrait_){
            naturalSizeFirst = CGSizeMake(FirstAssetTrack.naturalSize.height, FirstAssetTrack.naturalSize.width);
        } else {
            naturalSizeFirst = FirstAssetTrack.naturalSize;
        }
        if(isSecondAssetPortrait_){
            naturalSizeSecond = CGSizeMake(SecondAssetTrack.naturalSize.height, SecondAssetTrack.naturalSize.width);
        } else {
            naturalSizeSecond = SecondAssetTrack.naturalSize;
        }
        
        float renderWidth, renderHeight;
        if(naturalSizeFirst.width > naturalSizeSecond.width) {
            renderWidth = naturalSizeFirst.width;
        } else {
            renderWidth = naturalSizeSecond.width;
        }
        if(naturalSizeFirst.height > naturalSizeSecond.height) {
            renderHeight = naturalSizeFirst.height;
        } else {
            renderHeight = naturalSizeSecond.height;
        }
        MainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
        
        
        //MainCompositionInst.renderSize = CGSizeMake(320.0, 480.0);
        
        // 3 - Audio track
        if (audioAsset!=nil){
            AVMutableCompositionTrack *AudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
            [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration))
                                ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        }
        // 4 - Get path
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                                 [NSString stringWithFormat:@"mergeVideo-%d.mov",arc4random() % 1000]];
        NSURL *url = [NSURL fileURLWithPath:myPathDocs];
        // 5 - Create exporter
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL=url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.shouldOptimizeForNetworkUse = YES;
        exporter.videoComposition = MainCompositionInst;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self exportDidFinish:exporter];
            });
        }];
    }
 */
}

-(BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate {
    // 1 - Validation
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    // 2 - Create image picker
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = delegate;
    // 3 - Display image picker
    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 1 - Get media type
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    // 2 - Dismiss image picker
    [self dismissModalViewControllerAnimated:NO];
    // 3 - Handle video selection
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        if (isSelectingAssetOne){
            NSLog(@"Video One  Loaded");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video One Loaded"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            [videoURLs addObject:[info objectForKey:UIImagePickerControllerMediaURL]];
            firstAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        } else {
            NSLog(@"Video two Loaded");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video Two Loaded"
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            [videoURLs addObject:[info objectForKey:UIImagePickerControllerMediaURL]];
            secondAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        }
    }
}

-(void) mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    NSArray *selectedSong = [mediaItemCollection items];
    if ([selectedSong count] > 0) {
        MPMediaItem *songItem = [selectedSong objectAtIndex:0];
        NSURL *songURL = [songItem valueForProperty:MPMediaItemPropertyAssetURL];
        audioAsset = [AVAsset assetWithURL:songURL];
        audioURL = songURL;
        NSLog(@"Audio Loaded");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Audio Loaded"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    [self dismissModalViewControllerAnimated:YES];
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissModalViewControllerAnimated: YES];
}

-(void)exportDidFinish:(AVAssetExportSession*)session {
    if (session.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = session.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
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
    audioAsset = nil;
    firstAsset = nil;
    secondAsset = nil;
    videoURLs = [[NSMutableArray alloc] init];
    [activityView stopAnimating];
}

@end
