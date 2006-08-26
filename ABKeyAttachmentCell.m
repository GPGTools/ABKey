//
//  ABKeyAttachmentCell.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 17/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "ABKeyAttachmentCell.h"
#import "ABKeyGlobalAnimationTimer.h"
#import "ABKeyManagerPluginBundleResourceAccess.h"


@implementation ABKeyAttachmentCell

-(void)constructBezierPath
{
  NSBezierPath *halfArrow=[NSBezierPath bezierPath];
  NSAffineTransform *rotate180=[NSAffineTransform transform];
  
  [rotate180 rotateByDegrees:180];
  
  [drawingPath setLineWidth:(drawSize.width-3)/10];
  
  [halfArrow appendBezierPathWithArcWithCenter:NSMakePoint(0,0) radius:(drawSize.width-6)/2 startAngle:50 endAngle:180];
    
  [halfArrow relativeLineToPoint:NSMakePoint(-1,1)];
  [halfArrow relativeLineToPoint:NSMakePoint(2,0)];
  [halfArrow relativeLineToPoint:NSMakePoint(-1,-1)];
  
  [drawingPath appendBezierPath:halfArrow];
  [halfArrow transformUsingAffineTransform:rotate180];
  [drawingPath appendBezierPath:halfArrow];
}


-(id)initWithIdentifier:(NSString *)newIdentifier
{
  if([super init])
  {
	identifier=[newIdentifier retain];
	animationRotationAngle=0;
	trackingRectTag=-1;
	toolTipTag=-1;
	drawInverted=NO;
	stopAfterFullRotation=NO;
	drawSize.width=drawSize.height=15+[[NSUserDefaults standardUserDefaults] integerForKey:@"ABTextSizeIncrement"];
	hasRegisteredWithAnimationTimer=NO;
	drawingPath=[[NSBezierPath alloc] init];
	
	[self constructBezierPath];
	
	[[GPGMEController sharedController] add:self selector:@selector(asyncStateChange:) forAsyncGPGOperationsConcerningIdentifier:identifier];
  }
  return self;
}


//basic text-attachment methods
-(NSPoint)cellBaselineOffset
{return NSMakePoint(0,-3);}


-(NSSize)cellSize
{return drawSize;}


-(void)mouseClicked
{
  if(hasRegisteredWithAnimationTimer)
	[[GPGMEController sharedController] interruptAsyncOperationForIdentifier:identifier];
  else
	[[GPGMEController sharedController] refreshGPGKeyWithFingerprint:identifier];
}


-(void)registerWithAnimationTimer
{
  if(hasRegisteredWithAnimationTimer)
	return;
  [ABKeyGlobalAnimationTimer addToGlobalAnimationTimer:self selector:@selector(animationStep:)];
  hasRegisteredWithAnimationTimer=YES;
}


-(void)unregisterWithAnimationTimer
{
  if(!hasRegisteredWithAnimationTimer)
	return;
  
  [ABKeyGlobalAnimationTimer removeObserver:self];
  hasRegisteredWithAnimationTimer=NO;
}


//key refresh status changes
-(void)asyncStateChange:(NSNotification *)notification
{  
  //NSLog(@"Status changed: %@", [[notification object] description]);
  if([[notification object] isEqualToString:@"asyncOperationStarted"])
	[self registerWithAnimationTimer];
  else
	stopAfterFullRotation=YES;
}


-(void)animationStep:(NSNotification *)notification
{
  //NSLog(@"Animation step");
  animationRotationAngle+=18;
  if(animationRotationAngle>180)
  {
	if(stopAfterFullRotation)
	{
	  [self unregisterWithAnimationTimer];
	  stopAfterFullRotation=NO;
	  animationRotationAngle=0;
	}
	else
	  animationRotationAngle-=180;
  }

  [myView displayRect:myFrame];
}


-(void)updateTrackingRect:(NSNotification *)notification
{
  if(trackingRectTag!=-1)
	[myView removeTrackingRect:trackingRectTag];
  trackingRectTag=[myView addTrackingRect:myFrame owner:self userData:nil assumeInside:NO];	
  
  if(toolTipTag!=-1)
	[[myView superview] removeToolTip:toolTipTag];
  toolTipTag=[[myView superview] addToolTipRect:myFrame owner:self userData:nil];
}


-(void)drawWithFrame:(NSRect)newFrame inView:(NSView *)aView
{ 
  if(myView==nil || ![myView isEqualTo:aView])
  {
	if(myView!=nil)
	  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:myView];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTrackingRect:) name:NSViewFrameDidChangeNotification object:aView];
	
	myView=aView;
  }
  
  if(!NSEqualRects(newFrame,myFrame))
  {
	myFrame=newFrame;
	[self updateTrackingRect:nil];
  }

  NSAffineTransform *transform=[NSAffineTransform transform];
  [transform translateXBy:myFrame.origin.x+(myFrame.size.width/2) yBy:myFrame.origin.y+(myFrame.size.height/2)];
  
  if(drawInverted)
  {
	[[NSColor lightGrayColor] setFill];
	[[NSColor whiteColor] setStroke];
  }
  else
  {
	[[NSColor lightGrayColor] setStroke];
	[[NSColor whiteColor] setFill];
  }
  
  if([myView lockFocusIfCanDraw])
  {
	[[NSBezierPath bezierPathWithOvalInRect:myFrame] fill];
	if(!drawInverted || !hasRegisteredWithAnimationTimer)
	{
	  [transform rotateByDegrees:animationRotationAngle];
	  [[transform transformBezierPath:drawingPath] stroke];
	}
	else
	{
	  int length=(drawSize.width-7);
	  NSBezierPath *cancelIcon=[NSBezierPath bezierPath];
	  [cancelIcon setLineWidth:(drawSize.width-3)/10];
	  	
	  [cancelIcon moveToPoint:NSMakePoint(length/2,length/2)];
	  [cancelIcon relativeLineToPoint:NSMakePoint(-length,-length)];
	  [cancelIcon moveToPoint:NSMakePoint(-(length/2),length/2)];
	  [cancelIcon relativeLineToPoint:NSMakePoint(length,-length)];
	  [[transform transformBezierPath:cancelIcon] stroke];
	}
	[myView unlockFocus];
  }
  
}


-(void)mouseEntered:(NSEvent *)theEvent
{
  drawInverted=YES;
  [[NSCursor arrowCursor] push];
  [myView displayRect:myFrame];
}

-(void)mouseExited:(NSEvent *)theEvent
{
  drawInverted=NO;
  [NSCursor pop];
  [myView displayRect:myFrame];
}

-(NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)userData
{
  return KeyManagerLocalizedString(@"refresh tooltip",@"key refresh tooltip");
}


-(void)dealloc
{
  [myView removeTrackingRect:trackingRectTag];
  [[myView superview] removeToolTip:toolTipTag];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewFrameDidChangeNotification object:myView];
  [identifier release];
  [drawingPath release];
  [[GPGMEController sharedController] removeObserver:self];
  [self unregisterWithAnimationTimer];
  
  [super dealloc];
}
@end
