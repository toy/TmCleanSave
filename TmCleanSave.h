//
//  TmCleanSave.h
//  TmCleanSave
//
//  Created by toy on 03.01.11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSObject+Inspect.h"
#import "NSString+Repeat.h"
#import "OnigRegexp.h"

@protocol TMPlugInController

- (float)version;

@end

@interface TmCleanSave : NSObject
{
	NSMenu* fileMenu;
	NSMenuItem* originalSaveMenuItem;
	NSMenuItem* saveMenuItem;
}

- (id)initWithPlugInController:(id <TMPlugInController>)aController;
- (void)dealloc;

- (void)installMenuItem;
- (void)uninstallMenuItem;

- (void)cleanNSaveAction:(id)sender;

- (NSUInteger)stringColumnCount:(NSString *)string withTabSize:(NSUInteger)tabSize;
- (NSUInteger)stringTabCount:(NSString *)string withTabSize:(NSUInteger)tabSize;
- (NSUInteger)columnsToTabs:(NSUInteger)column withTabSize:(NSUInteger)tabSize;

@end

@interface OakController : NSWindowController
- (void)saveDocument:(id)sender;
@end

@interface OakTextView : NSView <NSTextInput>
- (id)document;
- (BOOL)softTabs;
- (unsigned long)tabSize;
- (id)allEnvironmentVariables;
- (void)goToLineNumber:(id)lineNumber;
- (void)goToColumnNumber:(id)columnNumber;
- (void)recalcFrameSize;
@end

@interface OakDocument
- (id)filename;
- (int)fileEncoding;
- (void)setFileModificationDate:(id)date;
- (BOOL)checkForFilesystemChanges;
@end
