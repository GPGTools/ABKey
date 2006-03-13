//
//  GPGSubkey extensions.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 06/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "GPGSubkey extensions.h"
#import "ABKeyManagerPluginBundleResourceAccess.h"


@implementation GPGSubkey (AB_gui_extensions)

-(NSString *)statusInfo
{return KeyManagerLocalizedString(@"Active",@"GPGKey Status");}

-(BOOL)isPrimaryKey
{return([[self shortKeyID] isEqualToString:[[self key] shortKeyID]]);}


  //Bindings stuff
  //*********************************************************
-(id)valueForUndefinedKey:(NSString *)key
{
  NSLog(@"GPGSubey: Could not bind '%@'",key);
  return [NSNumber numberWithInt:0];
}

@end
