//
//  GPGKey extensions.h
//  ABKeyManager
//
//  Created by Robert Goldsmith on 06/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import <MacGPGME/MacGPGME.h>
#import <Cocoa/Cocoa.h>

@interface GPGRemoteKey (AB_gui_extensions)

-(NSString *)statusDescription;
-(NSString *)uidCount;
-(NSString *)formattedCreationDate;
-(NSString *)formattedExpirationDate;
-(NSString *)formattedShortKeyID;

//binding errors
-(id)valueForUndefinedKey:(NSString *)key;

@end
