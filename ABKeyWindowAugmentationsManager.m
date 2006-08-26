//
//  ABKeyWindowAugmentationsManager.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 12/03/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "ABKeyWindowAugmentationsManager.h"
#import "NSWindow Extensions.h"
#import "ABKeyManagerPluginBundleResourceAccess.h"

#define LayoutTypeOffset 40

@implementation ABKeyWindowAugmentationsManager

id sharedABKeyWindowAugmentationsManager=nil;

+(id)sharedAugmentationsManager
{
  if(sharedABKeyWindowAugmentationsManager==nil)
	sharedABKeyWindowAugmentationsManager=[[ABKeyWindowAugmentationsManager alloc] init];
  return sharedABKeyWindowAugmentationsManager;
}


+(void)augmentWindow:(NSWindow *)window controller:(id)controller
{[[self sharedAugmentationsManager] augmentWindow:window controller:controller];}


+(void)removeWindow:(NSWindow *)window
{[[self sharedAugmentationsManager] removeWindow:window];}


+(void)adjustAugmentationsInWindow:(NSWindow *)window forLayout:(int)layout
{[[self sharedAugmentationsManager] adjustAugmentationsInWindow:window forLayout:layout];}


+(void)setAugmentationsEnabled:(BOOL)state forWindow:(NSWindow *)window
{[[self gpgSearchButtonForWindow:window] setEnabled:state];}


+(id)gpgSearchButtonForWindow:(NSWindow *)window
{return [[self sharedAugmentationsManager] augmentationItemWithKey:@"gpgSearchButton" forWindow:window];}

+(id)gpgSearchSpinnerForWindow:(NSWindow *)window
{return [[self sharedAugmentationsManager] augmentationItemWithKey:@"gpgSearchSpinner" forWindow:window];}





-(id)init
{
  if([super init])
  {
	augmentations=[[NSMutableDictionary alloc] initWithCapacity:3];
	
	//when the template layout changes this could be due to the preference pane being changed
	//therefore, check whenever this happens to see if the windows need undressing
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkAugmentationPreference:) name:@"ABTemplateLayoutHasChanged" object:nil];
  }
  return self;
}


-(void)augmentWindow:(NSWindow *)window controller:(id)controller
{
//  NSLog(@"Window elements: %@",[[[[[window contentView] subviews] objectAtIndex:4] prototype] description]);
  
  
  if(![augmentations objectForKey:[window identifierString]])
  {
	NSMutableDictionary *tempDictionary=[[NSMutableDictionary alloc] initWithCapacity:1];

	NSRect searchFrameRect=[[window contentView] frame];
	searchFrameRect.origin.x+=searchFrameRect.size.width-45;
	if((int)[[controller uiController] layoutType]==1)
	  searchFrameRect.origin.x-=LayoutTypeOffset;
	searchFrameRect.origin.y=3;
	searchFrameRect.size.width=searchFrameRect.size.height=16;

	//gpg email search button
	NSButton *gpgSearchButton=[[[NSButton alloc] initWithFrame:searchFrameRect] autorelease];	
	[gpgSearchButton setImage:[[[NSImage alloc] initByReferencingFile:pathToPluginBundleResource(@"search", @"png")] autorelease]];
	[gpgSearchButton setAlternateImage:[[[NSImage alloc] initByReferencingFile:pathToPluginBundleResource(@"search-cancel", @"png")] autorelease]];
	[gpgSearchButton sizeToFit];
	[gpgSearchButton setBordered:NO];
	[gpgSearchButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
	
	[[gpgSearchButton cell] setShowsStateBy:NSContentsCellMask];
	[[gpgSearchButton cell] setHighlightsBy:NSPushInCellMask];
	  
	[gpgSearchButton setTarget:controller];
	[gpgSearchButton setAction:@selector(gpgEmailSearch:)];
	
	[[window contentView] addSubview:gpgSearchButton];
	[tempDictionary setObject:gpgSearchButton forKey:@"gpgSearchButton"];
	
	//gpg email search button tooltip
	[gpgSearchButton setToolTip:pathToPluginBundleResource(@"email search tooltip", @"tooltips")];

	//gpg email search spinner
	searchFrameRect.origin.x-=18;
	searchFrameRect.origin.y+=2;
	NSProgressIndicator *spinner=[[[NSProgressIndicator alloc] initWithFrame:searchFrameRect] autorelease];
	[spinner setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
	[spinner setHidden:YES];
	[spinner setIndeterminate:YES];
	[spinner setStyle:NSProgressIndicatorSpinningStyle];
	[spinner setControlSize:NSMiniControlSize];
	[spinner sizeToFit];

	[[window contentView] addSubview:spinner];
	[tempDictionary setObject:spinner forKey:@"gpgSearchSpinner"];

	
	
	[augmentations setObject:tempDictionary forKey:[window identifierString]];
  }
  else
  {
	NSDictionary *windowAugmentations=[augmentations objectForKey:[window identifierString]];
	[[windowAugmentations objectForKey:@"gpgSearchButton"] setState:NSOffState];
	[[windowAugmentations objectForKey:@"gpgSearchSpinner"] stopAnimation:self];
	[[windowAugmentations objectForKey:@"gpgSearchSpinner"] setHidden:YES];
  }
}

-(void)undressWindowWithIdentifier:(id)identifier
{
  NSArray *windowAugmentations=[[augmentations objectForKey:identifier] allValues];
  NSEnumerator *augmentationEnumerator=[windowAugmentations objectEnumerator];
  NSView *currentAugmentation;
  while((currentAugmentation=[augmentationEnumerator nextObject]))
	[currentAugmentation removeFromSuperview];
}

-(void)removeWindow:(NSWindow *)window
{
  [self undressWindowWithIdentifier:[window identifierString]];
  [augmentations removeObjectForKey:[window identifierString]];
}


-(void)removeAllWindows
{
  NSArray *allWindows=[augmentations allKeys];
  NSEnumerator *windowEnumerator=[allWindows objectEnumerator];
  id currentWindowIdentifier;
  while((currentWindowIdentifier=[windowEnumerator nextObject]))
  {
	[self undressWindowWithIdentifier:currentWindowIdentifier];
	[augmentations removeObjectForKey:currentWindowIdentifier];
  }
}


-(void)adjustAugmentationsInWindow:(NSWindow *)window forLayout:(int)layout
{
  NSRect frame;
  NSArray *windowAugmentations=[[augmentations objectForKey:[window identifierString]] allValues];
  NSEnumerator *augmentationEnumerator=[windowAugmentations objectEnumerator];
  NSView *currentAugmentation;
  while((currentAugmentation=[augmentationEnumerator nextObject]))
  {
	frame=[currentAugmentation frame];
	if(layout==1)
	  frame.origin.x-=LayoutTypeOffset;
	else
	  frame.origin.x+=LayoutTypeOffset;
	[currentAugmentation setFrame:frame];
  }
}


-(id)augmentationItemWithKey:(NSString *)key forWindow:(NSWindow *)window
{return [[augmentations objectForKey:[window identifierString]] objectForKey:key];}


-(void)checkAugmentationPreference:(NSNotification *)notification
{
  //whenever the template changes, check to see if the augmentation preference has changed
  //and, if it has, remove the window augmentations for all windows
  if(![[NSUserDefaults standardUserDefaults] boolForKey:@"ABKeyDisplayEmailSearchButton"])
	[self removeAllWindows];
}

-(void)dealloc
{
  [augmentations release];
  [super dealloc];
}


@end
