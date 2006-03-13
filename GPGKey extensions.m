//
//  GPGKey extensions.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 06/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "GPGKey extensions.h"
#import "NSDate extensions.h"
#import "ABKeyManagerPluginBundleResourceAccess.h"

extern int ABSystemVersion;

@implementation GPGKey (AB_gui_extensions)

-(NSString *)statusDescription
{
  if([self isKeyRevoked])
	return KeyManagerLocalizedString(@"Revoked",@"GPGKey Status");

  if([self isKeyInvalid])
	return KeyManagerLocalizedString(@"Invalid",@"GPGKey Status");

  if([self isKeyDisabled])
	return KeyManagerLocalizedString(@"Disabled",@"GPGKey Status");
  
  if([self hasKeyExpired])
	return KeyManagerLocalizedString(@"Expired",@"GPGKey Status");
  
  return [self statusInfo];
	
}

-(NSString *)statusInfo
{return [self validityDescription];}

-(NSImage *)photo
{
  NSData *rawData=[self photoData];
  if(rawData==nil)
	return nil;
  else
	return [[[NSImage alloc] initWithData:rawData] autorelease];
}


-(NSString *)subkeyCount
{return [NSString stringWithFormat:@"%i",[[self subkeys] count]-1];}

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
  NSLog(@"GPGKey: Could not bind '%@'",key);
  return [NSNumber numberWithInt:0];
}


@end
