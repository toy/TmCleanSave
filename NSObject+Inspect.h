//
//  NSObject+Trace.h
//  TmCleanSave
//
//  Created by toy on 04.01.11.
//  Copyright 2011 tadump. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objc/objc-class.h>

@interface NSObject (Inspect)

- (void)inspect;
- (void)inspectTill:(Class)stopClass;

@end
