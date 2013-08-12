//
//  VideoUtils.h
//  VideoPlayRecord
//
//  Created by Tomer Harry on 8/8/13.
//  Copyright (c) 2013 Homage. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
//#import <AssetsLibrary/AssetsLibrary.h>

@interface VideoUtils : NSObject

// This method receives a list of videos (URLs to the videos) and a soundtrack (URL to the soundtrack). The method merges the videos and soundtrack into a new video. The completion method will be called asynchronously once the new video is ready
+(void)mergeVideos:(NSArray*)videoUrls withSoundtrack:(NSURL*)soundtrackURL completion:(void (^)(AVAssetExportSession*))completion;

// This method transformes a list of images into a video. It receives an array of images (UIImage) and frame time in milliseconds for the time that each image will be displayed in the video. The completion method will be called asynchronously once the new video is ready
+(void)imagesToVideo:(NSArray*)images withFrameTime:(int64_t)frameTimeMS completion:(void (^)(void))completion;

// This method addes text to video. It recevies a video (as a URL) and the text that will be displyed on the video. The completion method will be called asynchronously once the new video is ready
+(void)textOnVideo:(NSURL*)videoURL withText:(NSString*)text completion:(void (^)(void))completion;

@end
