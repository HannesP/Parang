//
//  HPParangPreferences.h
//  Parang
//
//  Created by Hannes Petri on 6/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSPreferences.h"

@interface HPParangPreferences : NSPreferencesModule {
	IBOutlet NSTableView *tableView;
	NSMutableArray *entries;
}
- (id)imageForPreferenceNamed:(id)fp8;
- (id)preferencesNibName;

- (NSString*)urlForInput:(NSString*)str;
- (NSDictionary*)entryForKey:(NSString*)key;

- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)changeGoogleFieldVisibility:(id)sender;
@end
