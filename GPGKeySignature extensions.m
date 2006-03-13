//
//  GPGKeySignature extensions.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 06/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import "GPGKeySignature extensions.h"
#import "NSDate extensions.h"
#import "ABKeyManagerPluginBundleResourceAccess.h"


@implementation GPGKeySignature (AB_gui_extensions)

-(NSString *)statusDescription
{
  if([self isSignatureInvalid])
	return KeyManagerLocalizedString(@"Invalid",@"GPGKeySignature Status");
  if([self hasSignatureExpired])
	return KeyManagerLocalizedString(@"Expired",@"GPGKeySignature Status");
  if([self isRevocationSignature])
	return KeyManagerLocalizedString(@"Revocation",@"GPGKeySignature Status");
  return KeyManagerLocalizedString(@"Active",@"GPGKeySignature Status");
}


-(NSString *)userDescription
{
  if([[self name] isEqualToString:@""])
	return nil;
  return [NSString stringWithFormat:@"%@ <%@>",[self name],[self email]];
}

-(NSString *)shortSignerKeyID
{
  NSString *keyID=[self signerKeyID];
  if(keyID==nil)
	return nil;
  else
	return [NSString stringWithFormat:@"0x%@",[keyID substringFromIndex:[keyID length]-8]];
}


-(NSString *)formattedCreationDate
{
  CFDateFormatterRef  aFormatter = CFDateFormatterCreate(NULL, NULL, kCFDateFormatterMediumStyle, kCFDateFormatterNoStyle);
  NSString            *dateFormat = [NSDate calendarFormatFromICUDateFormat:(NSString *)CFDateFormatterGetFormat(aFormatter)];
  CFRelease(aFormatter);
  return [[self creationDate] descriptionWithCalendarFormat:dateFormat];
}

-(NSString *)formattedExpirationDate
{
  if(![self expirationDate])
	return nil;
  
  CFDateFormatterRef  aFormatter = CFDateFormatterCreate(NULL, NULL, kCFDateFormatterMediumStyle, kCFDateFormatterNoStyle);
  NSString            *dateFormat = [NSDate calendarFormatFromICUDateFormat:(NSString *)CFDateFormatterGetFormat(aFormatter)];
  CFRelease(aFormatter);
  return [[self expirationDate] descriptionWithCalendarFormat:dateFormat];
}

@end
