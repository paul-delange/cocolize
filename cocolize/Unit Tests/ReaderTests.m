//
//  ReaderTests.m
//  cocolize
//
//  Created by MacBook Pro on 31/07/12.
//  Copyright (c) 2012 Tall Developments. All rights reserved.
//

#import "ReaderTests.h"
#import "AndroidStringsReader.h"

#define kAppNameEnglish @"HELLO WORLD"
#define KAppNameFrench @"BONJOUR TOUR LE MONDE"

@implementation ReaderTests

- (void) testParser {
    
    NSString* srcPath = [[NSBundle mainBundle] pathForResource: @"strings"
                                                        ofType: @"xml"];
    
    NSData* data = [NSData dataWithContentsOfFile: srcPath];
    NSError* error = nil;
    NSDictionary* all = [AndroidStringsReader dictionaryForXMLData: data
                                                             error: &error];
    
    GHAssertNil(error, @"There was an error: %@", error);
    GHAssertNotNil(all, @"Parser returned an empty dictionary");
    
    NSString* appName = [all objectForKey: @"app_name"];
    
    NSString* lang = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex: 0];
    if( [lang isEqualToString: @"fr"] )
        GHAssertEqualStrings(appName, KAppNameFrench, @"The app name %@ does not equal %@", appName, KAppNameFrench);
    else
        GHAssertEqualStrings(appName, kAppNameEnglish, @"The app name %@ was not english", appName);
}

- (void) testBundleCategory {
    NSString* lang = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex: 0];
    NSString* n = kAppNameEnglish;
    if( [lang isEqualToString: @"fr"] )
        n = KAppNameFrench;
    
    NSString* v1 = [[NSBundle mainBundle] localizedAndroidStringForKey: @"app_name" value: @"" table: nil];
    
    GHAssertEqualStrings(v1, n, @"Empty table name did not work");
    
    NSString* v2 = [[NSBundle mainBundle] localizedAndroidStringForKey: @"pocahontas" value: @"A princess" table: nil];
    
    GHAssertEqualStrings(v2, @"A princess", @"Unknown key failed");
    
    NSString* empty = [[NSBundle mainBundle] localizedAndroidStringForKey: nil value: @"no crash?" table: nil];
    
    GHAssertNil(empty, @"Should be no value returned when the key is empty");
    
    NSString* trimmed = [v1 stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    GHAssertEqualStrings(trimmed, v1, @"'%@' has some white space", v1);
}

- (void) testMacro {
    NSString* lang = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex: 0];
    NSString* loc = [lang isEqualToString: @"fr"] ? @"Ton" : @"Sound";
    
    NSString* sound = NSLocalizedString(@"sound", @"");
    
    GHAssertEqualStrings(sound, loc, @"Macro did not return '%@' but %@", loc, sound);
}

- (void) testFormatSpecifiers {
    
    NSString* indexed = [NSString stringWithFormat: NSLocalizedString(@"welcome", @""), @"25", @"Homer"];
    NSString* unindexed = [NSString stringWithFormat: NSLocalizedString(@"welcome2", @""), @"Homer", @"25"];
    
    GHAssertEqualStrings(indexed, unindexed, @"Macro did not return '%@' but %@", indexed, unindexed);
    
    for(NSInteger people=0;people<6;people++) {
        NSString* format = nil;
        switch (people) {
            case 0:
            {
                format = NSLocalizedString(@"people_zero", @"");
                break;
            }
            case 1:
            {
                format = NSLocalizedString(@"people_one", @"");
                break;
            }
            case 2:
            {
                format = NSLocalizedString(@"people_two", @"");
                break;
            }
            case 3:
            {
                format = NSLocalizedString(@"people_other", @"");
                break;
            }
            default:
                format = NSLocalizedString(@"people_other", @"");
                break;
        }
        
        NSString* output = [NSString stringWithFormat: format, @(people)];
        
        GHAssertTrue(output.length, @"Formating plural people failed for count: %d", people);
    }
}

- (void) testUnknownString {
    NSString* copy = NSLocalizedString(@"copy", @"");
    GHAssertEqualStrings(copy, @"copy", @"Did not correctly fall throught to native implementation");
}

@end
