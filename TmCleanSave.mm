//
//  TmCleanSave.mm
//  TmCleanSave
//
//  Created by toy on 03.01.11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "TmCleanSave.h"

@implementation TmCleanSave

- (id)initWithPlugInController:(id <TMPlugInController>)aController{
	if(self = [super init]) {
		[self installMenuItem];
	}
	return self;
}

- (void)dealloc{
	[self uninstallMenuItem];
	[super dealloc];
}

- (void)installMenuItem{
	if (fileMenu = [[[[NSApp mainMenu] itemWithTitle:@"File"] submenu] retain]) {
		originalSaveMenuItem = [fileMenu itemWithTitle:@"Save"];
		[originalSaveMenuItem setKeyEquivalentModifierMask:[originalSaveMenuItem keyEquivalentModifierMask] | NSAlternateKeyMask | NSShiftKeyMask];

		saveMenuItem = [fileMenu insertItemWithTitle:@"Clean'n'Save" action:@selector(cleanNSaveAction:) keyEquivalent:[originalSaveMenuItem keyEquivalent] atIndex:[fileMenu indexOfItem:originalSaveMenuItem] + 1];
		[saveMenuItem setTarget:self];
	}
}

- (void)uninstallMenuItem{
	[originalSaveMenuItem setKeyEquivalent:[saveMenuItem keyEquivalent]];
	originalSaveMenuItem = nil;
	[fileMenu removeItem:saveMenuItem];
	saveMenuItem = nil;
}

- (void)cleanNSaveAction:(id)sender{
	OakController *controller = [NSApp targetForAction:@selector(saveDocument:)];
	OakTextView *view = [NSApp targetForAction:@selector(document)];
	OakDocument *document = [view document];

	[controller saveDocument:sender];
	NSString *filename = [document filename];
	if (filename) {
		NSStringEncoding encoding = [document fileEncoding];
		NSDictionary* envVars = [view allEnvironmentVariables];
		int lineIndex = [[envVars objectForKey:@"TM_LINE_NUMBER"] intValue] - 1;
		int columnIndex = [[envVars objectForKey:@"TM_COLUMN_NUMBER"] intValue] - 1;
		BOOL softTab = [view softTabs];
		unsigned long tabSize = [view tabSize];
		NSString *spaceTab = [@" " repeatTimes:tabSize];
		NSString *tab = softTab ? spaceTab : @"\t";
		NSMutableString *data;
		NSError *error;

		data = [NSString stringWithContentsOfFile:filename usedEncoding:&encoding error:&error];
		if (data == nil) {
			data = [NSString stringWithContentsOfFile:filename encoding:encoding error:&error];
		}

		OnigRegexp *rightSpaceReg = [OnigRegexp compile:@"\\s*\\Z" ignorecase:true multiline:true];
		OnigRegexp *nonSpaceReg = [OnigRegexp compileIgnorecase:@"\\S+(\\s+\\S+)*"];

		data = [data replaceByRegexp:rightSpaceReg with:@""];

		NSArray *lines = [data componentsSeparatedByString:@"\n"];
		data = [NSMutableString stringWithCapacity:[data length]];
		NSUInteger i, _i = [lines count];
		BOOL eatingLines = true, comment = false;
		NSUInteger eatenLines = 0, commentTabCount;
		for (i = 0; i < _i; i++) { NSString *line = [lines objectAtIndex:i];
			OnigResult *match = [nonSpaceReg search:line];
			NSString *body = [match body];
			NSString *preMatch = [match preMatch];

			if (!body) {
				if (eatingLines) {
					eatenLines++;
					continue;
				}
			} else {
				eatingLines = false;
				NSUInteger tabCount = [self stringTabCount:preMatch withTabSize:tabSize];
				if (comment && [body hasPrefix:@"*"]) {
					if ([body hasPrefix:@"*"]) {
						body = [NSString stringWithFormat:@" %@", body];
						tabCount = commentTabCount;
					}
				} else {
					if ([body hasPrefix:@"/*"]) {
						comment = true;
						commentTabCount = tabCount;
					} else {
						comment = false;
					}
				}
				[data appendFormat:@"%@%@", [tab repeatTimes:tabCount], body];
				if (i == lineIndex && !softTab) {
					columnIndex = columnIndex - MIN(tabCount, [self columnsToTabs:columnIndex withTabSize:tabSize]) * (tabSize - 1);
				}
			}
			[data appendString:@"\n"];
		}

		if (![data writeToFile:filename atomically:FALSE encoding:encoding error:&error]) {
			if (![data writeToFile:filename atomically:FALSE encoding:NSUTF8StringEncoding error:&error]) {
				NSLog(@"%@", error);
			}
		}

		[document setFileModificationDate:[NSDate distantPast]];
		[document checkForFilesystemChanges];
		[view goToLineNumber:[NSNumber numberWithInt:lineIndex + 1 - eatenLines]];
		[view goToColumnNumber:[NSNumber numberWithInt:columnIndex + 1]];
		[view recalcFrameSize];
	} else {
		NSBeep();
	}
}

- (NSUInteger)stringColumnCount:(NSString *)string withTabSize:(NSUInteger)tabSize {
	NSUInteger column = 0;
	NSUInteger s, _s = [string length];
	for (s = 0; s < _s; s++) { unichar character = [string characterAtIndex:s];
		if (character == '\t') {
			column = (column / tabSize + 1) * tabSize;
		} else {
			column++;
		}
	}
	return column;
}

- (NSUInteger)stringTabCount:(NSString *)string withTabSize:(NSUInteger)tabSize {
	return [self columnsToTabs:[self stringColumnCount:string withTabSize:tabSize] withTabSize:tabSize];
}

- (NSUInteger)columnsToTabs:(NSUInteger)column withTabSize:(NSUInteger)tabSize {
	return (NSUInteger)roundf((float)column / tabSize);
}

@end
