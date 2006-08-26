/*
 *  PatchingFunctions.m
 *  ABKeyManager
 *
 *  Created by Robert Goldsmith on Thu Apr 08 2004.
 *  Copyright (c) 2004 Far-Blue. All rights reserved.
 *
 */

#import "PatchingFunctions.h"

void listMethodsForClassNamed(NSString *className)
{
  void *iterator = 0;
  Class theClass=NSClassFromString(className);
  struct objc_method_list *methodList;
  int i;
  
  NSLog(@"Instance Methods for %@:",className);
  // Each call to class_nextMethodList returns one methodList
  while((methodList=class_nextMethodList(theClass,&iterator)))
	for(i=0;i<methodList->method_count;i++)
	  NSLog(@"%s - %s\n",(char *)((methodList->method_list[i]).method_name),(methodList->method_list[i]).method_types);
  
  NSLog(@"Class Methods for %@:",className);
  theClass=objc_getMetaClass(theClass->name);
  while((methodList=class_nextMethodList(theClass,&iterator)))
	for(i=0;i<methodList->method_count;i++)
	  NSLog(@"%s - %s\n",(char *)((methodList->method_list[i]).method_name),(methodList->method_list[i]).method_types);
  
}

void listInstanceVariablesForClassNamed(NSString *className)
{
  struct objc_ivar_list *ivarList=(NSClassFromString(className))->ivars;
  int i;
  if(ivarList==0 || ivarList->ivar_count==0)
	NSLog(@"%@ has no instance variables",className);
  else
  {
	NSLog(@"Instance variables for %@:",className);
	for(i=0;i<ivarList->ivar_count;i++)
	  NSLog(@"%s - %s, %i\n",(ivarList->ivar_list[i]).ivar_name,(ivarList->ivar_list[i]).ivar_type,(ivarList->ivar_list[i]).ivar_offset);
  }
}

void listInheritanceStackForClassNamed(NSString *className)
{
  struct objc_class *currentClass=NSClassFromString(className);
  
  do
	NSLog(@"%s\n",currentClass->name);
  while((currentClass=currentClass->super_class));
}

void registerMethodWithNewClass(NSString *originalClass, SEL methodSelector, NSString *newClass)
{
  struct objc_method *theMethod=class_getInstanceMethod(NSClassFromString(originalClass), methodSelector);
  if(theMethod==0)
  {
	NSLog(@"Method not found for class %@",originalClass);
	return;
  }
  struct objc_method_list *newMethod=malloc(sizeof(struct objc_method_list));
  newMethod->method_list[0].method_name=theMethod->method_name;
  newMethod->method_list[0].method_types=theMethod->method_types;
  newMethod->method_list[0].method_imp=theMethod->method_imp;
  newMethod->method_count=1;
  class_addMethods(NSClassFromString(newClass),newMethod);
}

void renameMethodForClass(NSString *class, SEL methodSelector, const char *newName)
{
  struct objc_method *theMethod=class_getInstanceMethod(NSClassFromString(class), methodSelector);
  if(theMethod==0)
  {
	NSLog(@"Method not found for class %@",class);
	return;
  }
  theMethod->method_name=sel_registerName(newName);
}

void registerMethodFromClassInNewClassAndRenameOldMethodFromThisNewClass(NSString *classWithReplacementMethod, SEL methodSelector, NSString *classInWhichToRegisterNewMethod, NSString *newNameForMethodBeingReplacedInNewClass)
{
  renameMethodForClass(classInWhichToRegisterNewMethod, methodSelector, [newNameForMethodBeingReplacedInNewClass cString]);
  registerMethodWithNewClass(classWithReplacementMethod, methodSelector, classInWhichToRegisterNewMethod);
}

void registerNewIDTypeInstanceVariableForClass(char *variableName, NSString *className)
{
  Class theClass=NSClassFromString(className);
  
  struct objc_ivar *newIVar;
  struct objc_ivar_list *currentIVarList;
  
  if(theClass->ivars==0) //no current ivars so ivar_list struct needed and ivar array (of one item) needed
  {
	theClass->ivars=malloc(sizeof(struct objc_ivar_list));
	if(theClass->ivars==0) //alloc failed, exit
	  return;
	
	theClass->ivars->ivar_count=1;
	
	//set newIVar to the newly created space
	newIVar=&(theClass->ivars->ivar_list[0]);
  }
  else //ivar_list already exists so try to add space for one more ivar and update the count
  {
	currentIVarList=theClass->ivars;
	theClass->ivars=realloc(theClass->ivars,((theClass->ivars->ivar_count)*sizeof(struct objc_ivar))+sizeof(struct objc_ivar_list));
	if(theClass->ivars==nil) //realloc failed, put back the old list and exit
	{
	  theClass->ivars=currentIVarList;
	  return;
	}
	else //update the count and set newIVar to point to the new space
	{
	  currentIVarList=0;
	  newIVar=&(theClass->ivars->ivar_list[theClass->ivars->ivar_count]);
	  theClass->ivars->ivar_count+=1;
	}
  }
  
  //allocate space for the name and set the name
  newIVar->ivar_name = malloc (strlen(variableName) + 1);
  strcpy ((char*)newIVar->ivar_name, variableName);
  
  //allocate space for the type and set it
  newIVar->ivar_type = malloc (strlen ("@") + 1);
  strcpy ((char*)newIVar->ivar_type, "@");
  
  //set the offset
  newIVar->ivar_offset=theClass->instance_size;
  
  //update the instance_size
  theClass->instance_size+=sizeof(id);
}


void registerNewSuperClassForClass(NSString *className, NSString *superClassName)
{
  Class theClass=NSClassFromString(className);
  theClass->super_class=NSClassFromString(superClassName);
}

void registerNewClassTypeForObject(id theObject, NSString *newClassName)
{theObject->isa=NSClassFromString(newClassName);}

