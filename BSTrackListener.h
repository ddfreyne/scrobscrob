//
//	BSTrackListener.h
//	ScrobScrob
//
//	Copyright 2007 Denis Defreyne. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// A track listener checks what iTunes is doing and immediately sends
// notifications when a song is played or paused.

@class BSTrackFilter;

@interface BSTrackListener : NSObject {
	BSTrackFilter	*mTrackFilter;
}

- (void)start; // override this method when subclassing
- (void)stop;  // override this method when subclassing

#pragma mark -

- (BSTrackFilter *)trackFilter;
- (void)setTrackFilter:(BSTrackFilter *)aTrackFilter;

@end
