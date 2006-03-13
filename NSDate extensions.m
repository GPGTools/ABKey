//
//  NSDate extensions.m
//  ABKeyManager
//
//  Created by Robert Goldsmith on 24/04/2005.
//  Copyright 2005 far-blue. All rights reserved.
//

#import "NSDate extensions.h"


@implementation NSDate (ICUDateFormat)

+ (NSString *) calendarFormatFromICUDateFormat:(NSString *)icuFormat
{
  // See http://oss.software.ibm.com/icu/userguide/formatDateTime.html
  int             i, count = [icuFormat length];
  NSMutableString *calendarFormat = [NSMutableString string];
  NSMutableString *currentFormatPattern = [NSMutableString string];
  NSCharacterSet  *icuCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"GyMdhHmsSEDFwWakKZ'\""];
  BOOL            quotedText = NO;
  
  for(i = 0; i <= count; i++){
	unichar aChar;
	
	if(i < count)
	  aChar = [icuFormat characterAtIndex:i];
	else
	  aChar = '\0';
	
	if([currentFormatPattern length] > 0){
	  unichar previousChar = [currentFormatPattern characterAtIndex:[currentFormatPattern length] - 1];
	  
	  if(i < count && (previousChar == aChar || (quotedText && aChar != '\''))){
		[currentFormatPattern appendFormat:@"%C", aChar];
		continue;
	  }
	  else{
		int formatLength = [currentFormatPattern length] + ((i >= count || previousChar != aChar) ? 0:1);
		
		switch([currentFormatPattern characterAtIndex:0]){
		  case 'G':
			[NSException raise:NSParseErrorException format:@"Unable to convert ICU's G pattern (era) to Cocoa pattern."];
		  case 'y':
			if(formatLength >= 3)
			  [calendarFormat appendString:@"%Y"];
			else
			  [calendarFormat appendString:@"%y"];
			break;
		  case 'M':
			switch(formatLength){
			  case 1:
				[calendarFormat appendString:@"%1m"]; break;
			  case 2:
				[calendarFormat appendString:@"%m"]; break;
			  case 3:
				[calendarFormat appendString:@"%b"]; break;
			  default:
				[calendarFormat appendString:@"%B"];
				break;
			}
			break;
		  case 'd':
			if(formatLength > 1)
			  [calendarFormat appendString:@"%d"];
			else
			  [calendarFormat appendString:@"%e"];
			break;
		  case 'h':
			if(formatLength > 1)
			  [calendarFormat appendString:@"%I"];
			else
			  [calendarFormat appendString:@"%1I"];
			break;
		  case 'H':
			if(formatLength > 1)
			  [calendarFormat appendString:@"%H"];
			else
			  [calendarFormat appendString:@"%1H"];
			break;
		  case 'm':
			if(formatLength > 1)
			  [calendarFormat appendString:@"%M"];
			else
			  [calendarFormat appendString:@"%1M"];
			break;
		  case 's':
			if(formatLength > 1)
			  [calendarFormat appendString:@"%S"];
			else
			  [calendarFormat appendString:@"%1S"];
			break;
		  case 'S':
			// We can't display only 1 or 2 digits for milliseconds
			switch(formatLength){
			  case 1:
				//                                [calendarFormat appendString:@"%1F"]; break;
			  case 2:
				//                                [calendarFormat appendString:@"%2F"]; break;
				NSLog(@"Milliseconds are always rendered with 3 digits.");
			  default:
				[calendarFormat appendString:@"%F"];
			}
			break;
		  case 'E':
			if(formatLength > 3)
			  [calendarFormat appendString:@"%A"];
			else
			  [calendarFormat appendString:@"%a"];
			break;
		  case 'D':
			switch(formatLength){
			  case 1:
				[calendarFormat appendString:@"%1j"]; break;
			  case 2:
				[calendarFormat appendString:@"%2j"]; break;
			  default:
				[calendarFormat appendString:@"%j"];
			}
			break;
		  case 'F':
			[NSException raise:NSParseErrorException format:@"Unable to convert ICU's F pattern (day of week in month) to Cocoa pattern."];
		  case 'w':
			[NSException raise:NSParseErrorException format:@"Unable to convert ICU's w pattern (week in year) to Cocoa pattern."];
		  case 'W':
			[NSException raise:NSParseErrorException format:@"Unable to convert ICU's W pattern (week in month) to Cocoa pattern."];
		  case 'a':
			[calendarFormat appendString:@"%p"];
			break;
		  case 'k':
			[NSException raise:NSParseErrorException format:@"Unable to convert ICU's k pattern (hour in day, 1-24) to Cocoa pattern."];
		  case 'K':
			[NSException raise:NSParseErrorException format:@"Unable to convert ICU's K pattern (hour in day, 0-11) to Cocoa pattern."];
		  case 'Z':
			if(formatLength > 3)
			  [calendarFormat appendString:@"%Z"];
			else
			  [NSException raise:NSParseErrorException format:@"Unable to convert ICU's short Z pattern (abbreviated timezone) to Cocoa pattern."];
			break;
		  case '\'':
			if(formatLength > 1)
			  [calendarFormat appendString:[currentFormatPattern substringFromIndex:1]];
			quotedText = NO;
			[currentFormatPattern setString:@""];
			continue;
		  case '"':
			[calendarFormat appendString:@"'"];
			break;
		  default:
			[NSException raise:NSInternalInconsistencyException format:@"Unable to convert ICU's %@%S pattern to Cocoa pattern.", calendarFormat, aChar];
		}
		[currentFormatPattern setString:@""];
	  }
	}        
	
	if(i < count){
	  if([icuCharacterSet characterIsMember:aChar]){
		[currentFormatPattern appendFormat:@"%C", aChar];
		if(aChar == '\'')
		  quotedText = YES;
	  }
	  else{
		[calendarFormat appendFormat:@"%C", aChar];
	  }
	}
  }
  
  return calendarFormat;
}

@end
