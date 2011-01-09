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

		saveMenuItem = [fileMenu insertItemWithTitle:@"Clean'n'Save"
																					action:@selector(cleanNSaveAction:)
																	 keyEquivalent:[originalSaveMenuItem keyEquivalent]
																				 atIndex:[fileMenu indexOfItem:originalSaveMenuItem] + 1];
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
		BOOL eatingLines = true;
		NSUInteger eatenLines = 0;
		for (i = 0; i < _i; i++) { NSString *line = [lines objectAtIndex:i];
			OnigResult *match = [nonSpaceReg search:line];

			NSString *body = [match body];
			if (!body) {
				body = @"";
			}

			NSString *spaces = [match preMatch];
			if (spaces && [spaces length] > 0) {
				spaces = [tab repeatTimes:[self countTabs:spaces withTabSize:tabSize]];
			} else {
				spaces = @"";
			}

			if (eatingLines && [line length] == 0) {
				eatenLines++;
			} else {
				eatingLines = false;
				line = [NSString stringWithFormat:@"%@%@", spaces, body];
				if (i == lineIndex) {
					NSUInteger lineColumns = [self countColumns:line withTabSize:tabSize];
					if (lineColumns < columnIndex) {
						[@"" stringByPaddingToLength: withString:[] startingAtIndex:];
						line = [line stringByAppendingString:[@" " repeatTimes:columnIndex - lineColumns]];
					}
				}
				[data appendFormat:@"%@\n", line];
			}
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
	} else {
		NSBeep();
	}
}

- (NSUInteger)countColumns:(NSString *)string withTabSize:(NSUInteger)tabSize {
	NSUInteger col = 0;
	NSUInteger s, _s = [string length];
	for (s = 0; s < _s; s++) { unichar character = [string characterAtIndex:s];
		if (character == '\t') {
			col = (col / tabSize + 1) * tabSize;
		} else {
			col++;
		}
	}
	return col;
}

- (NSUInteger)countTabs:(NSString *)string withTabSize:(NSUInteger)tabSize {
	return roundf((float)[self countColumns:string withTabSize:tabSize] / tabSize);
}

@end
