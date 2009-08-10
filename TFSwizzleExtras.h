//
//  TFSwizzleExtras.h
//  Swizzle
//
//  Created by Tomas Franzén on 2006-06-24.
//  Copyright 2006 Lighthead Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (HPParangTFSwizzleExtras)

+ (BOOL)interchangeMethod:(SEL)firstMethod with:(SEL)secondMethod;
+ (BOOL)interchangeMethod:(SEL)firstMethod with:(SEL)secondMethod from:(Class)target;

+ (BOOL)interchangeClassMethod:(SEL)firstMethod with:(SEL)secondMethod;
+ (BOOL)interchangeClassMethod:(SEL)firstMethod with:(SEL)secondMethod from:(Class)target;

+ (BOOL)changeMethod:(SEL)firstMethod toUseOtherMethod:(SEL)secondMethod;
+ (BOOL)changeClassMethod:(SEL)firstMethod toUseOtherMethod:(SEL)secondMethod;
@end