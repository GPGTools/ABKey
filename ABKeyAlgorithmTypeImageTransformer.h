//
//  ABKeyAlgorithmTypeImageTransformer.h
//  ABKeyManager
//
//  Created by Robert Goldsmith on 25/04/2005.
//  Copyright 2005 far-blue. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MacGPGME/MacGPGME.h>

@interface ABKeyAlgorithmTypeImageTransformer  : NSValueTransformer

+ (Class)transformedValueClass;
+(BOOL)allowsReverseTransformation;

- (NSImage *)transformedValue:(NSNumber *)algorithmNumber;

@end
