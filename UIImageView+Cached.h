//  UIImageView+Cached.h
//
//  Created by Lane Roathe
//  Copyright 2009 Ideas From the Deep, llc. All rights reserved.
#import <UIKit/UIKit.h>
@interface UIImageView (Cached)

-(void)loadFromURL:(NSURL*)url;

-(void)loadFromURL:(NSURL*)url afterDelay:(float)delay;
-(UIImage *)imageCacheFromURL:(NSURL*)url;
-(void) setImageFromUrl:(NSString *)urlString
            withSpinner:(bool)useLoadingSpinner
         andFailedImage:(UIImage*)failImage;
- (void) setImageFromUrl:(NSString*)urlString
             preparation:(void (^)(void))preparation
              completion:(void (^)(void))completion
                 failure:(void (^)(void))failure  stop:(void (^)(void))stop;
@end

