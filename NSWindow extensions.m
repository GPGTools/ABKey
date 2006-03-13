//
//  NSWindow extensions.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 12/03/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "NSWindow extensions.h"


@implementation NSWindow (identifierString)

-(NSString *)identifierString
{
  return [NSString stringWithFormat:@"%u",[self hash]];
}

@end
