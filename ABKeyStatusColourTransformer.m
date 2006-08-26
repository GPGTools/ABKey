//
//  ABKeyStatusColourTransformer.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 09/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "ABKeyStatusColourTransformer.h"


@implementation ABKeyStatusColourTransformer

+ (Class)transformedValueClass
{return [NSColor class];}

+(BOOL)allowsReverseTransformation
{return NO;}

- (NSColor *)transformedValue:(id)key
{
  //bool value, true = red
  if([key isKindOfClass:[NSNumber class]])
  {
	if([key boolValue])
	  return [NSColor colorWithCalibratedRed:0.7 green:0.0 blue:0.0 alpha:1];
	else
	  return [NSColor blackColor];
  }

  //based on key details
  if(![key isKindOfClass:[GPGKey class]])
	 return [NSColor blackColor];
  
  if([key isKeyRevoked] || [key isKeyInvalid])
	return [NSColor colorWithCalibratedRed:0.7 green:0.0 blue:0.0 alpha:1];
  
  if([key hasKeyExpired] || [key isKeyDisabled])
	return [NSColor colorWithCalibratedWhite:0.7 alpha:1];
  
  return [NSColor blackColor];
}

@end
