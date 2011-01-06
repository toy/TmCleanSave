//
//  TmCleanSave.h
//  TmCleanSave
//
//  Created by toy on 03.01.11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSObject+Inspect.h"
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
@end

@interface OakDocument
- (id)filename;
- (int)fileEncoding;
- (void)setFileModificationDate:(id)date;
- (BOOL)checkForFilesystemChanges;
@end

//#define OakCallbackStack NSClassFromString(@"OakCallbackStack")
//
//@interface OakDocument : NSObject
//@end
//@interface OakDocument (CleanSave)
//- (BOOL)cleanFile;
//@end
