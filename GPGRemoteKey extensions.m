//
//  GPGKey extensions.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 06/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "GPGRemoteKey extensions.h"
#import "NSDate extensions.h"
#import "ABKeyManagerPluginBundleResourceAccess.h"

extern int ABSystemVersion;

@implementation GPGRemoteKey (AB_gui_extensions)

-(NSString *)statusDescription
{
  if([self isKeyRevoked])
	return KeyManagerLocalizedString(@"Revoked",@"GPGKey Status");
  
  if([self hasKeyExpired])
	return KeyManagerLocalizedString(@"Expired",@"GPGKey Status");
  return @"";
}

-(NSString *)uidCount
{return [NSString stringWithFormat:@"%i",[[self userIDs] count]];}

-(NSString *)formattedCreationDate
{
  if(![self creationDate])
	return nil;

  if(ABSystemVersion<8)
  {
	CFDateFormatterRef  aFormatter = CFDateFormatterCreate(NULL, NULL, kCFDateFormatterMediumStyle, kCFDateFormatterNoStyle);
	NSString *dateFormat = [NSDate calendarFormatFromICUDateFormat:(NSString *)CFDateFormatterGetFormat(aFormatter)];
	CFRelease(aFormatter);
	return [[self creationDate] descriptionWithCalendarFormat:dateFormat];
  }
  
  return [[self creationDate] descriptionWithCalendarFormat:@"%x" locale:[NSLocale currentLocale]];

}

-(NSString *)formattedExpirationDate
{
  if(![self expirationDate])
	return nil;
  
  if(ABSystemVersion<8)
  {

	CFDateFormatterRef  aFormatter = CFDateFormatterCreate(NULL, NULL, kCFDateFormatterMediumStyle, kCFDateFormatterNoStyle);
	NSString *dateFormat = [NSDate calendarFormatFromICUDateFormat:(NSString *)CFDateFormatterGetFormat(aFormatter)];
	CFRelease(aFormatter);
	return [[self expirationDate] descriptionWithCalendarFormat:dateFormat];
  }
  return [[self expirationDate] descriptionWithCalendarFormat:@"%x" locale:[NSLocale currentLocale]];
}

-(NSString *)formattedShortKeyID
{return [NSString stringWithFormat:@"0x%@",[self shortKeyID]];}


  //Bindings stuff
  //*********************************************************
-(id)valueForUndefinedKey:(NSString *)key
{
  NSLog(@"GPGRemoteKey: Could not bind '%@'",key);
  return [NSNumber numberWithInt:0];
}


@end
