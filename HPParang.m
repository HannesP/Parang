#import "HPParang.h"
#import "TFSwizzleExtras.h"
#import "HPParangPreferences.h"
#import "NSPreferences.h"

#import <WebKit/WebKit.h>
#import <WebKit/DOMHTMLInputElement.h>

@implementation NSObject (HPParangPatch)

+ (void)load {
	if ([[[NSBundle mainBundle] bundleIdentifier] isNotEqualTo:@"com.apple.Safari"]) return;
	
	Class BrowserWindowController = NSClassFromString(@"BrowserWindowController");
    if(!BrowserWindowController) BrowserWindowController = NSClassFromString(@"BrowserWindowControllerMac"); // Safari on Lion
    
	[BrowserWindowController interchangeMethod:@selector(goToToolbarLocation:) with:@selector(HPParangPatch_goToToolbarLocation:)];
	[NSClassFromString(@"BrowserWebView") interchangeMethod:@selector(webView:contextMenuItemsForElement:defaultMenuItems:) with:@selector(HPParangPatch_webView:contextMenuItemsForElement:defaultMenuItems:)];
	[NSClassFromString(@"ToolbarController") interchangeMethod:@selector(shouldShowGoogleSearch) with:@selector(HPParangPatch_shouldShowGoogleSearch)];
	
	[[NSClassFromString(@"WBPreferences") sharedPreferences] addPreferenceNamed:@"Parang" owner:[HPParangPreferences sharedInstance]];
}

- (BOOL)HPParangPatch_shouldShowGoogleSearch {
	return ![[NSUserDefaults standardUserDefaults] boolForKey:@"HPParangHideGoogleField"];
}

- (void)HPParangPatch_goToToolbarLocation:(id)sender {
	[sender setStringValue:[[HPParangPreferences sharedInstance] urlForInput:[sender stringValue]]];
	[self HPParangPatch_goToToolbarLocation:sender];
}

- (NSArray*)HPParangPatch_webView:(WebView*)sender contextMenuItemsForElement:(NSDictionary*)element defaultMenuItems:(NSArray*)defaultMenuItems {
	NSArray *items = [self HPParangPatch_webView:sender contextMenuItemsForElement:element defaultMenuItems:defaultMenuItems];
	DOMHTMLElement *de = [element objectForKey:WebElementDOMNodeKey];
		
	if ([de isKindOfClass:[DOMHTMLInputElement class]]) {
		DOMHTMLInputElement *input = (DOMHTMLInputElement*)de;
		if ([[NSArray arrayWithObjects:@"text", @"search", nil] containsObject:input.type] && [[input.form.method lowercaseString] isNotEqualTo:@"post"]) {
			NSMenuItem *addItem = [[[NSMenuItem alloc] initWithTitle:@"Add Parang Shortcut..." action:@selector(addShortcutFromTextInput:) keyEquivalent:@""] autorelease];
			[addItem setTarget:[HPParangPreferences sharedInstance]];
			[addItem setRepresentedObject:[NSDictionary dictionaryWithObjectsAndKeys:input, @"input", sender, @"webview", nil]];
			
			NSMutableArray *mitems = [[items mutableCopy] autorelease];
			[mitems addObject:[NSMenuItem separatorItem]];
			[mitems addObject:addItem];
			
			return mitems;
		}
	}
	
	return items;
}

@end