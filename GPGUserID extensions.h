//
//  GPGUserID extensions.h
//  ABKeyManager
//
//  Created by Robert Goldsmith on 06/02/2005.
//  Copyright 2005 Far-Blue. All rights reserved.
//

#import <GPGME/GPGME.h>
#import <Cocoa/Cocoa.h>

@interface GPGUserID (AB_gui_extensions)

-(NSString *)statusDescription;
-(NSString *)shortKeyID;

@end
