//
//  HPParangPreferences.m
//  Parang
//
//  Created by Hannes Petri on 6/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HPParangPreferences.h"
#import <WebKit/WebKit.h>

@implementation HPParangPreferences

- (NSMutableDictionary*)entryWithKey:(NSString*)key name:(NSString*)name url:(NSString*)url {
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:key, @"key", name, @"name", url, @"url", nil];
}

- (NSArray*)mutableEntries {
	NSMutableArray *result = [NSMutableArray array];
	
	for (NSDictionary *d in [[NSUserDefaults standardUserDefaults] objectForKey:@"HPParangEntries"]) {
		[result addObject:[[d mutableCopy] autorelease]];
	}
	
	return result;
}

- (void)registerDefaults {
	NSArray *defaultEntries = [NSArray arrayWithObjects:
						[self entryWithKey:@"*" name:@"Lucky search" url:@"http://www.google.com/search?hl=en&q=$0&btnI=I%27m+Feeling+Lucky"],
						[self entryWithKey:@"g" name:@"Google" url:@"http://www.google.com/search?ie=utf8&oe=utf8&q=$0"],
						[self entryWithKey:@"gi" name:@"Google Images" url:@"http://images.google.com/images?hl=en&q=$0&gbv=2&aq=f&oq="],
						[self entryWithKey:@"w" name:@"en.Wikipedia" url:@"http://en.wiktionary.org/w/index.php?title=Special%3ASearch&search=$0&go=go"],
						[self entryWithKey:@"k" name:@"en.Wiktionary" url:@"http://en.wiktionary.org/w/index.php?title=Special%3ASearch&search=$0&go=go"],
						[self entryWithKey:@"wa" name:@"Wolfram|Alpha" url:@"http://www.wolframalpha.com/input/?i=$0"],
						[self entryWithKey:@"imdb" name:@"IMDB" url:@"http://www.imdb.com/find?s=all&q=$0"],
						nil];
	
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults setObject:defaultEntries forKey:@"HPParangEntries"];
	[defaults setObject:[NSNumber numberWithBool:NO] forKey:@"HPParangHideGoogleField"];
	[defaults setObject:[NSNumber numberWithBool:YES] forKey:@"HPParangFallBackToBaseURL"];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)saveData:(NSNotification*)notif {
	[[NSUserDefaults standardUserDefaults] setObject:entries forKey:@"HPParangEntries"];
}

- (id)init {
	[super init];
	[self registerDefaults];
	
	entries = [[self mutableEntries] retain];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveData:) name:NSApplicationWillTerminateNotification object:NSApp];
	
	return self;
}

- (id)imageForPreferenceNamed:(id)fp8 {
	return [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"Parang" ofType:@"tiff"]] autorelease];
}

- (id)preferencesNibName {
	return @"Parang";
}

- (IBAction)add:(id)sender {
	[entries addObject:[self entryWithKey:@"" name:@"" url:@""]];
	[tableView reloadData];
	[tableView selectRow:[tableView numberOfRows]-1 byExtendingSelection:NO];
	[tableView editColumn:0 row:[tableView numberOfRows]-1 withEvent:nil select:YES];
}

- (IBAction)remove:(id)sender {
	[tableView reloadData];
	[entries removeObjectsAtIndexes:[tableView selectedRowIndexes]];
	[tableView reloadData];
}

- (IBAction)changeGoogleFieldVisibility:(id)sender {
	NSArray *documents = [[NSClassFromString(@"BrowserDocumentController") sharedDocumentController] documents];
	/*for (id doc in documents) {
		[[[doc currentWebView] browserWindow] flushWindow];
	}*/
}

- (NSString*)urlForInput:(NSString*)str {
	if (([str rangeOfString:@" "].location == NSNotFound && [str rangeOfString:@"."].location != NSNotFound) || [[NSURL URLWithString:str] scheme]) return str;
	
	NSArray *words = [str componentsSeparatedByString:@" "];
	NSString *key = [words objectAtIndex:0];
	NSDictionary *entry = [self entryForKey:key];
	NSDictionary *fallbackEntry = [self entryForKey:@"*"];
	
	if (!entry && !fallbackEntry) {
		return str;
	}
	
	if ([words count] == 1 && entry && [[[NSUserDefaults standardUserDefaults] valueForKey:@"HPParangFallBackToBaseURL"] boolValue]) {
		NSURL *url = [NSURL URLWithString:[entry objectForKey:@"url"]];
		if (url) {
			NSString *res = [NSString stringWithFormat:@"%@://%@/", [url scheme], [url host]];
			if (res) return res;
		}
	}
	
	NSArray *args = entry ? [words subarrayWithRange:NSMakeRange(1, [words count]-1)] : words;
	entry = entry ? entry : fallbackEntry;
	
	NSMutableString *final = [[[entry valueForKey:@"url"] mutableCopy] autorelease];
			
	for (int i = [args count]+1; i--; i >= 0) {
		NSString *rep = i > 0 ? [args objectAtIndex:i-1] : [args componentsJoinedByString:@" "];			
		[final replaceOccurrencesOfString:[NSString stringWithFormat:@"$%d", i] withString:rep options:0 range:NSMakeRange(0, [final length])];
	}
	
	//return entry == fallbackEntry ? final : [self urlForInput:final];
	return final;
}

- (NSDictionary*)entryForKey:(NSString*)key {
	for (NSDictionary *d in entries) {
		if ([[d objectForKey:@"key"] isEqual:key]) return d;
	}
	
	return nil;
}

- (id)tableView:(NSTableView*)aTableView objectValueForTableColumn:(NSTableColumn*)aTableColumn row:(int)rowIndex {
	return [[entries objectAtIndex:rowIndex] objectForKey:[aTableColumn identifier]];
}

- (void)tableView:(NSTableView*)aTableView setObjectValue:anObject forTableColumn:(NSTableColumn*)aTableColumn row:(int)rowIndex {
	[[entries objectAtIndex:rowIndex] setObject:[anObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:[aTableColumn identifier]];
}

- (void)tableViewSelectionDidChange:(NSNotification*)aNotification {
	[self willChangeValueForKey:@"removeButtonEnabled"];
	[self didChangeValueForKey:@"removeButtonEnabled"];
}

- (int)numberOfRowsInTableView:(NSTableView*)aTableView {
    return [entries count];
}

- (BOOL)removeButtonEnabled {
	return [[tableView selectedRowIndexes] count];
}

- (void)addShortcutFromTextInput:(NSMenuItem*)item {
	DOMHTMLInputElement *input = [[item representedObject] objectForKey:@"input"];
	WebView *webview = [[item representedObject] objectForKey:@"webview"];
	DOMHTMLFormElement *form = input.form;
	
	NSMutableString *searchURL = [NSMutableString stringWithString:[[NSURL URLWithString:form.action relativeToURL:[NSURL URLWithString:[webview mainFrameURL]]] absoluteString]];
	[searchURL appendString:[searchURL rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&"];
	
	DOMHTMLCollection *inputs = form.elements;
	NSMutableArray *params = [NSMutableArray array];
	
	for (int i = 0; i < inputs.length; i++) {
		DOMHTMLInputElement *curr = (DOMHTMLInputElement*)[inputs item:i];
		if (![[NSArray arrayWithObjects:@"button", @"submit", nil] containsObject:curr.type]) {
			[params addObject:[NSString stringWithFormat:@"%@=%@", curr.name, (curr == input ? @"$0" : curr.value)]];
		}
	}
	
	[searchURL appendString:[params componentsJoinedByString:@"&"]];

	[[NSClassFromString(@"WBPreferences") sharedPreferences] showPreferencesPanelForOwner:self];
	
	[entries addObject:[self entryWithKey:@"" name:[webview mainFrameTitle] url:searchURL]];
	[tableView reloadData];
	[tableView selectRow:[tableView numberOfRows]-1 byExtendingSelection:NO];
	[tableView editColumn:0 row:[tableView numberOfRows]-1 withEvent:nil select:YES];
}

@end
