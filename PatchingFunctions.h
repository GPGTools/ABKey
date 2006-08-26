/*
 *  PatchingFunctions.h
 *  ABKeyManager
 *
 *  Created by Robert Goldsmith on Thu Apr 08 2004.
 *  Copyright (c) 2004 Far-Blue. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>

void listMethodsForClassNamed(NSString *className);
void listInstanceVariablesForClassNamed(NSString *className);
void listInheritanceStackForClassNamed(NSString *className);
void registerMethodWithNewClass(NSString *originalClass, SEL methodSelector, NSString *newClass);
void renameMethodForClass(NSString *class, SEL methodSelector, const char *newName);
void registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass(NSString *classWithReplacementMethod, SEL methodSelector, NSString *classInWhichToRegisterNewMethod, NSString *newNameForMethodBeingReplacedInNewClass);
void registerNewIDTypeInstanceVariableForClass(char *variableName, NSString *className);
void registerNewSuperClassForClass(NSString *className, NSString *superClassName);
void registerNewClassTypeForObject(id theObject, NSString *newClassName);
