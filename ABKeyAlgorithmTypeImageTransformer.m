//
//  ABKeyAlgorithmTypeImageTransformer.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 25/04/2005.
//  Copyright 2005 far-blue. All rights reserved.
//

#import "ABKeyAlgorithmTypeImageTransformer.h"
#import "ABKeyManagerPluginBundleResourceAccess.h"

@implementation ABKeyAlgorithmTypeImageTransformer

NSImage *pencil=nil, *padlock=nil, *padlockAndPencil=nil;

+ (Class)transformedValueClass
{return [NSImage class];}

+(BOOL)allowsReverseTransformation
{return NO;}

- (NSImage *)transformedValue:(NSNumber *)algorithmNumber
{
  int algorithm=[algorithmNumber intValue];
  switch(algorithm)
  {
	case 1:
	case 20:
	case 21:
	  if(!padlockAndPencil)
		padlockAndPencil=[[NSImage alloc] initByReferencingFile:pathToPluginBundleResource(@"padlockAndPencil", @"png")];
	  return padlockAndPencil;
	  break;
	  
	case 2:
	case 16:
	case 18:
	case 19:
	  if(!padlock)
		padlock=[[NSImage alloc] initByReferencingFile:pathToPluginBundleResource(@"padlock", @"png")];
	  return padlock;
	  break;
		
	case 3:
	case 17:
	  if(!pencil)
		pencil=[[NSImage alloc] initByReferencingFile:pathToPluginBundleResource(@"pencil", @"png")];
	  return pencil;
	  break;
	  
	default:
	  return nil;
  }
}

@end
