//
//  NSObject+Trace.h
//  TmCleanSave
//
//  Created by toy on 04.01.11.
//  Copyright 2011 tadump. All rights reserved.
//

#ifndef NDEBUG

#import <Cocoa/Cocoa.h>
#import <objc/objc-class.h>

@interface NSObject (Inspect)

- (void)inspect;
- (void)inspectTill:(Class)stopClass;

@end

@implementation NSObject (Inspect)

- (void)inspect {
	[self inspectTill:[NSObject class]];
}

- (void)inspectTill:(Class)stopClass {
	Class inspectedClass = [self class];
	
	Class originalClass = inspectedClass;
	NSString *originalClassString = [NSString stringWithFormat:@"%@", originalClass];
	NSString *inheritancePath = [NSString stringWithFormat:@"%@", originalClass];
	
	Method *methods;
	objc_property_t *properties;
	unsigned int i;
	unsigned int methodCount;
	unsigned int propertyCount;
	
	NSArray *sorted;
	NSArray *methodsAndPropertiesKeys;
	NSMutableDictionary * methodsAndProperties = [NSMutableDictionary dictionaryWithCapacity:10];
	
	NSString *inspectedClassString;
	NSString *methodOrPropertyName;
	while (inspectedClass != stopClass) {
		inspectedClassString = [NSString stringWithFormat:@"%@", inspectedClass];
		if (inspectedClass != originalClass) {
			inheritancePath = [inheritancePath stringByAppendingFormat:@" : %@", inspectedClass];
		}
		
		methods = class_copyMethodList(inspectedClass, &methodCount);
		properties = class_copyPropertyList(inspectedClass, &propertyCount);
		
		for (i = 0; i < methodCount; i++) {
			methodOrPropertyName = [NSString stringWithFormat:@"-%s", sel_getName(method_getName(methods[i]))];
			
			if (![methodsAndProperties objectForKey:methodOrPropertyName]) {
				[methodsAndProperties setObject:inspectedClassString forKey:methodOrPropertyName];
			}
		}
		
		for (i = 0; i < propertyCount; i++) {
			methodOrPropertyName = [NSString stringWithFormat:@" %s", property_getName(properties[i])];
			
			if (![methodsAndProperties objectForKey:methodOrPropertyName]) {
				[methodsAndProperties setObject:inspectedClassString forKey:methodOrPropertyName];
			}
		}
		
		inspectedClass = [inspectedClass superclass];
	}
	free(methods);
	free(properties);
	
	methodsAndPropertiesKeys = [methodsAndProperties allKeys];
	sorted = [methodsAndPropertiesKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
	NSMutableArray *lines = [NSMutableArray array];
	
	[lines addObject:inheritancePath];
	for (NSString *key in sorted) {
		if (![[methodsAndProperties objectForKey:key] isEqualToString:originalClassString]) {
			[lines addObject:[NSString stringWithFormat:@"\t%@ (%@)", key, [methodsAndProperties objectForKey:key]]];
		} else {
			[lines addObject:[NSString stringWithFormat:@"\t%@", key]];
		}
	}
	NSLog(@"%@", [lines componentsJoinedByString:@"\n"]);
}

@end

#endif
