//
//  NSDate extensions.h
//  ABKeyManager
//
//  Created by Robert Goldsmith on 24/04/2005.
//  Copyright 2005 far-blue. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSDate (ICUDateFormat)

+ (NSString *) calendarFormatFromICUDateFormat:(NSString *)icuFormat;

@end
