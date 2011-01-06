//
//  NSString+Repeat.m
//  TmCleanSave
//
//  Created by toy on 07.01.11.
//  Copyright 2011 tadump. All rights reserved.
//

#import "NSString+Repeat.h"

@implementation NSString (Repeat)

- (NSString *)repeatTimes:(NSUInteger)times {
	return [@"" stringByPaddingToLength:times * [self length] withString:self startingAtIndex:0];
}

@end
