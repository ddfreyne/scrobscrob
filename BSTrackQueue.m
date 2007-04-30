//
//	BSTrackQueue.m
//	ScrobScrob
//
//	Copyright 2007 Denis Defreyne. All rights reserved.
//

#import "BSTrackQueue.h"

#import "BSTrackSubmitter.h"
#import "BSTrack.h"


@interface BSTrackQueue (Private)

- (void)queueTrack:(BSTrack *)aTrack;
- (void)submitTracks:(NSArray *)aTracks;

@end

@implementation BSTrackQueue (Private)

- (void)readyForSubmitting:(NSTimer *)aTimer
{
	NSLog(@"Ready for submitting.");
	
	// Allow submitting
	mMaySubmit = YES;
	
	// Submit queued tracks
	[self submitTracks:mQueuedTracks];
}

#pragma mark -

- (void)queueTrack:(BSTrack *)aTrack
{
	NSLog(@"Queueing track (%@)", aTrack);
	
	[mQueuedTracks addObject:aTrack];
}

- (void)submitTracks:(NSArray *)aTracks
{
	if([aTracks count] < 1)
		return;
	
	// Submit tracks
	[mTrackSubmitter submitTracks:aTracks];
	
	// Disallow submitting
	mMaySubmit = NO;
}

#pragma mark -

- (NSMutableArray *)queuedTracks
{
	return mQueuedTracks;
}

- (void)setQueuedTracks:(NSMutableArray *)aQueuedTracks
{
	if(mQueuedTracks == aQueuedTracks)
		return;
	
	[mQueuedTracks release];
	mQueuedTracks = [aQueuedTracks retain];
}

@end

#pragma mark -

@implementation BSTrackQueue

- (id)init
{
	if(self = [super init])
	{
		mMaySubmit = NO;
		[self setQueuedTracks:[[[NSMutableArray alloc] init] autorelease]];
	}
	
	return self;
}

- (void)dealloc
{
	[self setTrackSubmitter:nil];
	
	[super dealloc];
}

#pragma mark -

- (void)trackFiltered:(BSTrack *)aTrack
{
	// Queue or submit track
	if(mMaySubmit && !mIsPaused)
		[self submitTracks:[NSArray arrayWithObject:aTrack]];
	else
		[self queueTrack:aTrack];
}

- (void)submitIntervalReceived:(NSNumber *)aTimeInterval
{
	// Allow updates on given date
	[NSTimer scheduledTimerWithTimeInterval:[aTimeInterval doubleValue] target:self selector:@selector(readyForSubmitting:) userInfo:nil repeats:NO];
}

#pragma mark -

- (void)pause
{
	NSLog(@"Pausing.");
	
	mIsPaused = YES;
}

- (void)resume
{
	NSLog(@"Resuming.");
	
	mIsPaused = NO;
	
	// Submit queued tracks
	[self submitTracks:mQueuedTracks];
}

#pragma mark -

- (BSTrackSubmitter *)trackSubmitter
{
	return mTrackSubmitter;
}

- (void)setTrackSubmitter:(BSTrackSubmitter *)aTrackSubmitter
{
	if(mTrackSubmitter == aTrackSubmitter)
		return;
	
	[mTrackSubmitter release];
	mTrackSubmitter = [aTrackSubmitter retain];
}

@end
