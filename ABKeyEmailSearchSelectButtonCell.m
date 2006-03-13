//
//  ABKeyEmailSearchSelectButtonCell.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 21/03/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "ABKeyEmailSearchSelectButtonCell.h"


@implementation ABKeyEmailSearchSelectButtonCell

-(id)init
{
  if([super init])
  {
	[self setButtonType:NSSwitchButton];
	[self setTitle:nil];
	[self setControlSize:NSMiniControlSize];
	[self setObjectValue:[NSNumber numberWithInt:-1]];
  }
  return self;
}

-(void)setObjectValue:(id)object
{
  if([object isKindOfClass:[NSNumber class]] && [object intValue]==-1)
  {
	[self setEditable:NO];
	[self setTransparent:YES];
	[super setIntValue:0];
  }
  else
  {
	[super setObjectValue:object];
	[self setEditable:YES];
	[self setTransparent:NO];
  }

}


@end
