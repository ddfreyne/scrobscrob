//
//	BSApplicationController.m
//	ScrobScrob
//
//	Copyright 2007 Denis Defreyne. All rights reserved.
//

#import "BSApplicationController.h"

#import "BSLoginWindowController.h"
#import "BSScrobbler.h"


@implementation BSApplicationController

- (id)init
{
	if(self = [super init])
	{
		// Create scrobbler
		mScrobbler = [[BSScrobbler alloc] init];
		
		// Setup notifications
		[[NSNotificationCenter defaultCenter]
			addObserver:self selector:@selector(queueResumed:) name:BSQueueResumedNotificationName object:nil];
		[[NSNotificationCenter defaultCenter]
			addObserver:self selector:@selector(queuePaused:) name:BSQueuePausedNotificationName object:nil];
		[[NSNotificationCenter defaultCenter]
			addObserver:self selector:@selector(userAuthenticationFailed:) name:BSUserAuthenticationFailedNotificationName object:nil];
		[[NSNotificationCenter defaultCenter]
			addObserver:self selector:@selector(passwordAuthenticationFailed:) name:BSPasswordAuthenticationFailedNotificationName object:nil];
		[[NSNotificationCenter defaultCenter]
			addObserver:self selector:@selector(networkErrorReceived:) name:BSNetworkErrorReceivedNotificationName object:nil];
	}
	
	return self;
}

- (void)dealloc
{
	[mScrobbler release];
	
	[mMenu release];
	[mStatusItem release];
	
	[super dealloc];
}

- (void)awakeFromNib
{
	mStatusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[mStatusItem setTitle:[NSString stringWithUTF8String:"\xE2\x99\xAC"]]; // ♬ = 0xE299AC (UTF-8)
	[mStatusItem setHighlightMode:YES];
	[mStatusItem setMenu:mMenu];
	
	[self updateMenu];
}

#pragma mark -

- (void)queueResumed:(NSNotification *)aNotification
{
	[self updateMenu];
}

- (void)queuePaused:(NSNotification *)aNotification
{
	[self updateMenu];
}

- (void)userAuthenticationFailed:(NSNotification *)aNotification
{
	// TODO localize
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:@"Login failed: incorrect username"];
	[alert setInformativeText:@"The username you specified appears to be incorrect. Do you want to re-enter your username and password?"];
	[alert addButtonWithTitle:@"Re-enter username"];
	[alert addButtonWithTitle:@"Cancel"];
	
	[NSApp activateIgnoringOtherApps:YES];
	int alertReturn = [alert runModal];
	
	if(NSAlertFirstButtonReturn == alertReturn)
	{
		NSLog(@"Showing login window again.");
		
		[NSApp activateIgnoringOtherApps:YES];
		[mLoginWindowController showWindow:self];
		[[mLoginWindowController window] center];
		[[mLoginWindowController window] makeKeyAndOrderFront:self];
	}
	else
	{
		NSLog(@"Canceling.");
	}
}

- (void)passwordAuthenticationFailed:(NSNotification *)aNotification
{
	// TODO localize
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:@"Login failed: incorrect password"];
	[alert setInformativeText:@"The password you specified appears to be incorrect. Do you want to re-enter your username and password?"];
	[alert addButtonWithTitle:@"Re-enter password"];
	[alert addButtonWithTitle:@"Cancel"];
	
	[NSApp activateIgnoringOtherApps:YES];
	int alertReturn = [alert runModal];
	
	if(NSAlertFirstButtonReturn == alertReturn)
	{
		NSLog(@"Showing login window again.");
		
		[NSApp activateIgnoringOtherApps:YES];
		[mLoginWindowController showWindow:self];
		[[mLoginWindowController window] center];
		[[mLoginWindowController window] makeKeyAndOrderFront:self];
	}
	else
	{
		NSLog(@"Canceling.");
	}
}

- (void)networkErrorReceived:(NSNotification *)aNotification
{
	;
	
	NSLog(@"ERROR! Network error!");
}

- (void)updateMenu
{
	if([mScrobbler isPaused])
		[[mMenu itemAtIndex:0] setTitle:NSLocalizedString(@"Start Scrobbling", @"start scrobbling menu item title")];
	else
		[[mMenu itemAtIndex:0] setTitle:NSLocalizedString(@"Stop Scrobbling", @"stop scrobbling menu item title")];
}

#pragma mark -

- (void)loginWithUsername:(NSString *)aUsername password:(NSString *)aPassword
{
	[mScrobbler loginWithUsername:aUsername password:aPassword];
}

#pragma mark -

- (IBAction)showAboutPanel:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:self];
}

- (IBAction)toggleScrobbling:(id)sender
{
	// Check whether we need to login first
	if(![mScrobbler isLoggedIn])
	{
		[NSApp activateIgnoringOtherApps:YES];
		[mLoginWindowController showWindow:self];
		[[mLoginWindowController window] center];
		[[mLoginWindowController window] makeKeyAndOrderFront:self];
		return;
	}
	
	if([mScrobbler isPaused])
		[mScrobbler startScrobbling];
	else
		[mScrobbler stopScrobbling];
}

- (IBAction)visitScrobScrobSite:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://scrobscrob.stoneship.org/"]];
}

- (IBAction)viewLastFmDashboard:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.last.fm/dashboard/"]];
}

- (IBAction)viewLastFmProfile:(id)sender
{
	NSString *username = [mScrobbler username];
	
	if(!username)
		return;
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:
		[NSString stringWithFormat:@"http://www.last.fm/user/%@",
			[username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
		]
	]];
}

@end
