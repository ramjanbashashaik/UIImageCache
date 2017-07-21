//  UIImageView+Cached.h
//
//  Created by Lane Roathe
//  Copyright 2009 Ideas From the Deep, llc. All rights reserved.

#import "UIImageView+Cached.h"

#pragma mark -
#pragma mark --- Threaded & Cached image loading ---

@implementation UIImageView (Cached)

#define MAX_CACHED_IMAGES 50	// max # of images we will cache before flushing cache and starting over

// method to return a static cache reference (ie, no need for an init method)
-(NSMutableDictionary*)cache
{
	static NSMutableDictionary* _cache = nil;
	
	if( !_cache )
		_cache = [NSMutableDictionary dictionaryWithCapacity:MAX_CACHED_IMAGES];

	assert(_cache);
	return _cache;
}

// Loads an image from a URL, caching it for later loads
// This can be called directly, or via one of the threaded accessors
-(void)cacheFromURL:(NSURL*)url
{
	UIImage* newImage = [[self cache] objectForKey:url.description];
    
	if( !newImage )
	{
	
		NSError *err = nil;
		
		newImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:url options:0 error:&err]] ;
		if( newImage )
		{
			// check to see if we should flush existing cached items before adding this new item
			if( [[self cache] count] >= MAX_CACHED_IMAGES )
				[[self cache] removeAllObjects];

			[[self cache] setValue:newImage forKey:url.description];
		}
		else
			NSLog( @"UIImageView:LoadImage Failed: %@", err );
		
		
	}

	if( newImage )
		[self performSelectorOnMainThread:@selector(setImage:) withObject:newImage waitUntilDone:NO];
}
-(UIImage *)imageCacheFromURL:(NSURL*)url
{
	UIImage* newImage = [[self cache] objectForKey:url.description];
	if( !newImage )
	{
        
		NSError *err = nil;
		
		newImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:url options:0 error:&err]] ;
		if( newImage )
		{
			// check to see if we should flush existing cached items before adding this new item
			if( [[self cache] count] >= MAX_CACHED_IMAGES )
				[[self cache] removeAllObjects];
            
			[[self cache] setValue:newImage forKey:url.description];
		}
		else
			NSLog( @"UIImageView:LoadImage Failed: %@", err );
		
		
	}
    
	//if( newImage )
		//[self performSelectorOnMainThread:@selector(setImage:) withObject:newImage waitUntilDone:NO];
    return newImage;
}
// Methods to load and cache an image from a URL on a separate thread
-(void)loadFromURL:(NSURL *)url
{
	[self performSelectorInBackground:@selector(cacheFromURL:) withObject:url]; 
}

-(void)loadFromURL:(NSURL*)url afterDelay:(float)delay
{
	[self performSelector:@selector(loadFromURL:) withObject:url afterDelay:delay];
}
-(void) setImageFromUrl:(NSString *)urlString
            withSpinner:(bool)useLoadingSpinner
         andFailedImage:(UIImage*)failImage{
    
    
    
    [self setImageFromUrl:urlString
              preparation:^{
                  //add a spinner if needed
                  if (useLoadingSpinner){
                      UIActivityIndicatorView *myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                      myIndicator.tag = 12345;
                      myIndicator.center = self.center;
                      myIndicator.hidesWhenStopped = YES;
                      [myIndicator startAnimating];
                      [self addSubview:myIndicator];
                  }
              }
     
     
               completion:^{
                   if (useLoadingSpinner){
                       UIActivityIndicatorView *myIndicator = (UIActivityIndicatorView *) [self viewWithTag:12345];
                       [myIndicator stopAnimating];
                   }
               }
                  failure:^{
                      self.image = failImage;
                  }
     
                     stop:^{
                         if (useLoadingSpinner){
                             UIActivityIndicatorView *myIndicator = (UIActivityIndicatorView *) [self viewWithTag:12345];
                             [myIndicator stopAnimating];
                         }
                         
                     }];
}
- (void) setImageFromUrl:(NSString*)urlString
             preparation:(void (^)(void))preparation
              completion:(void (^)(void))completion
                 failure:(void (^)(void))failure  stop:(void (^)(void))stop
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //run preparation on maint thread
        dispatch_async(dispatch_get_main_queue(), preparation);
        
        NSLog(@"Starting: %@", urlString);
        UIImage *avatarImage = nil;
        NSURL *url = [NSURL URLWithString:urlString];
        NSData *responseData = [NSData dataWithContentsOfURL:url];
        avatarImage = [UIImage imageWithData:responseData];
        NSLog(@"Finishing: %@", urlString);
        
        if (avatarImage) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.image = avatarImage;
            });
            // dispatch_sync(dispatch_get_main_queue(), completion);
            void dispatch_barrier_sync(
                                       dispatch_queue_t queue,
                                       dispatch_block_t block);
            dispatch_sync(dispatch_get_main_queue(),stop);
            
        }
        else {
            NSLog(@"-- impossible download: %@", urlString);
            dispatch_sync(dispatch_get_main_queue(), failure);
        }
	});
    
}

@end
