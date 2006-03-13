//
//  ABKeyAttachmentCell.h
//  ABKeyManager
//
//  Created by Robert Goldsmith on 17/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GPGMEController.h"

@interface ABKeyAttachmentCell : NSTextAttachmentCell
{
  NSString *identifier;
  NSBezierPath *drawingPath;
  int animationRotationAngle;
  BOOL hasRegisteredWithAnimationTimer;
  BOOL stopAfterFullRotation;
  
  NSView *myView;
  NSRect myFrame;
  
  NSTrackingRectTag trackingRectTag;
  NSToolTipTag toolTipTag;
  BOOL drawInverted;
  
  NSSize drawSize;
}

-(id)initWithIdentifier:(NSString *)newIdentifier;

-(void)mouseClicked;

-(void)animationStep:(NSNotification *)notification;

//key refresh status changes (starting / stopping 'refreshing' status with the spinner)
-(void)asyncStateChange:(NSNotification *)notification;


//tooltip
-(NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)userData;

@end
