//
//  TFSwizzleExtras.m
//  Swizzle
//
//  Created by Tomas Franzén on 2006-06-24.
//  Copyright 2006 Lighthead Software. All rights reserved.
//

#import "TFSwizzleExtras.h"
#import </usr/include/objc/objc-class.h>

@implementation NSObject (HPParangTFSwizzleExtras)


+ (BOOL)interchangeMethod:(SEL)firstMethod with:(SEL)secondMethod {
	return [self interchangeMethod:firstMethod with:secondMethod from:self];
}

+ (BOOL)interchangeMethod:(SEL)firstMethod with:(SEL)secondMethod from:(Class)target {
	IMP i1 = class_getMethodImplementation(self, firstMethod);
	IMP i2 = class_getMethodImplementation(target, secondMethod); 
	
	Method first = class_getInstanceMethod(self,firstMethod);
	Method second = class_getInstanceMethod(target,secondMethod);
	
	if(!first || !second) return NO;
	
	class_replaceMethod(self, firstMethod, i2, method_getDescription(first)->types);
	class_replaceMethod(target, secondMethod, i1, method_getDescription(second)->types);
	
	return YES;
}

+ (BOOL)interchangeClassMethod:(SEL)firstMethod with:(SEL)secondMethod {
	return [self interchangeClassMethod:firstMethod with:secondMethod from:self];
}

+ (BOOL)interchangeClassMethod:(SEL)firstMethod with:(SEL)secondMethod from:(Class)target {
	//IMP i1 = class_getMethodImplementation(self, firstMethod);
	IMP i1 = method_getImplementation(class_getClassMethod(self,firstMethod));
	//IMP i2 = class_getMethodImplementation(target, secondMethod);
	IMP i2 = method_getImplementation(class_getClassMethod(self,secondMethod));
	
	Method first = class_getClassMethod(self,firstMethod);
	Method second = class_getClassMethod(target,secondMethod);
	
	if(!first || !second) return NO;
	
	class_replaceMethod(self, firstMethod, i2, method_getDescription(first)->types);
	class_replaceMethod(target, secondMethod, i1, method_getDescription(second)->types);
	
	return YES;
}


+ (BOOL)changeClassMethod:(SEL)firstMethod toUseOtherMethod:(SEL)secondMethod {
	IMP i2 = method_getImplementation(class_getClassMethod(self,secondMethod));
	if(!i2) return NO;
	Method first = class_getClassMethod(self,firstMethod);
	if(!first) return NO;
	
	IMP r = method_setImplementation(first,i2);
	//IMP r = class_replaceMethod(self, firstMethod, i2, method_getDescription(first)->types);
	return r != nil;
}


+ (BOOL)changeMethod:(SEL)firstMethod toUseOtherMethod:(SEL)secondMethod {
	IMP i2 = class_getMethodImplementation(self, secondMethod); 
	Method first = class_getInstanceMethod(self,firstMethod);
	if(!first) return NO;
	
	class_replaceMethod(self, firstMethod, i2, method_getDescription(first)->types);
	return YES;
}

@end