//
//  ABKeyStatusColourTransformer.h
//  ABKeyManager
//
//  Created by Robert Goldsmith on 09/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GPGME/GPGME.h>

@interface ABKeyStatusColourTransformer  : NSValueTransformer

+ (Class)transformedValueClass;
+(BOOL)allowsReverseTransformation;

- (NSColor *)transformedValue:(id)key;

@end
