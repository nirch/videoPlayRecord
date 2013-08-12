//
//  VideoUtils.m
//  VideoPlayRecord
//
//  Created by Tomer Harry on 8/8/13.
//  Copyright (c) 2013 Homage. All rights reserved.
//

#import "VideoUtils.h"

// Private methods
@interface VideoUtils ()
//- (id)aPrivateMethod;
@end

@implementation VideoUtils

// This method receives a list of videos (URLs to the videos) and a soundtrack (URL to the soundtrack). The method merges the videos and soundtrack into a new video. The completion method will be called asynchronously once the new video is ready
+(void)mergeVideos:(NSArray*)videoUrls withSoundtrack:(NSURL*)soundtrackURL completion:(void (^)(AVAssetExportSession*))completion
{
    // Creating the composition object. This object will hold the composition track intances
    AVMutableComposition *mainComposition = [[AVMutableComposition alloc] init];
    
    // Creating a composition track for the video which is also added to the main composition oject
    AVMutableCompositionTrack *compositionTrack = [mainComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // *** Step 1: Merging the videos ***
    
    // The time to insert a current video in the below loop (the first video will be inserted in zime zero, then the variable will be increased)
    CMTime insertTime = kCMTimeZero;
    
    // Looping over the videos and adding them (merging) to the main composition
    for(NSURL *videoURL in videoUrls)
    {
        // TODO: Check if the URL is really a video
        
        // Creating a video asset for the current video URL
        AVAsset *videoAsset = [AVAsset assetWithURL:videoURL];
        
        // Creating a composition track for the video which is also added to the main composition oject
        //AVMutableCompositionTrack *compositionTrack = [mainComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        // Inserting the video to the composition track in the correct time range
        [compositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:insertTime error:nil];
        
        // Updating the insertTime for the next insert
        insertTime = CMTimeAdd(insertTime, videoAsset.duration);
    }

    // *** Step 2: Adding the soundtrack ***
    
    // Creating an asset object from the soundtrack URL
    AVAsset *soundtrackAsset = [AVAsset assetWithURL:soundtrackURL];
    
    // Creating a composition track for the soundtrack which is also added to the main composition oject
    AVMutableCompositionTrack *soundtrackTrack = [mainComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // Inserting the soundtrack to the composition track in the correct time frame
    [soundtrackTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, insertTime) ofTrack:[[soundtrackAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    // *** Step 3: Exporting the video ***
    
    // Getting the path to the documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Creating a full path and URL to the exported video
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"mergeVideo-%d.mov",arc4random() % 1000]];
    NSURL *outptVideoUrl = [NSURL fileURLWithPath:myPathDocs];

    // Creating an export session using the main composition
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mainComposition presetName:AVAssetExportPresetHighestQuality];
    
    // Setting attributes of the exporter
    exporter.outputURL=outptVideoUrl;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    //exporter.videoComposition = MainCompositionInst;
    
    
    // Setting the completion method that will be invoked asynchronously once the new video is ready
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(exporter);
        });
    }];

}

// This method transformes a list of images into a video. It receives an array of images (UIImage) and frame time in milliseconds for the time that each image will be displayed in the video. The completion method will be called asynchronously once the new video is ready
+(void)imagesToVideo:(NSArray*)images withFrameTime:(int64_t)frameTimeMS completion:(void (^)(void))completion
{
    
}

// This method addes text to video. It recevies a video (as a URL) and the text that will be displyed on the video. The completion method will be called asynchronously once the new video is ready
+(void)textOnVideo:(NSURL*)videoURL withText:(NSString*)text completion:(void (^)(void))completion
{
    
}


@end
