//
//  GPGUserID extensions.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 06/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "GPGSubkey extensions.h"
#import "ABKeyManagerPluginBundleResourceAccess.h"


@implementation GPGUserID (AB_gui_extensions)

-(NSString *)statusDescription
{
  if([self hasBeenRevoked])
	return KeyManagerLocalizedString(@"Revoked",@"GPGKey Status");
  
  if([self isInvalid])
	return KeyManagerLocalizedString(@"Invalid",@"GPGKey Status");
  
  return [self validityDescription];
}

-(NSString *)shortKeyID
{
	return [[self key] shortKeyID];
}

//Bindings stuff
//*********************************************************
-(id)valueForUndefinedKey:(NSString *)key
{
  NSLog(@"GPGUserID: Could not bind '%@'",key);
  return [NSNumber numberWithInt:0];
}


@end
