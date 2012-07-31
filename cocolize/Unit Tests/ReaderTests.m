//
//  ReaderTests.m
//  cocolize
//
//  Created by MacBook Pro on 31/07/12.
//  Copyright (c) 2012 Tall Developments. All rights reserved.
//

#import "ReaderTests.h"
#import "AndroidStringsReader.h"

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
    
    GHAssertEqualStrings(appName, @"Koalyptus", @"The app name %@ does not equal Koalyptus", appName);
}

- (void) testBundleCategory {
    NSString* v1 = [[NSBundle mainBundle] localizedAndroidStringForKey: @"app_name" value: @"" table: nil];
    
    GHAssertEqualStrings(v1, @"Koalyptus", @"Empty table name did not work");
    
    NSString* v2 = [[NSBundle mainBundle] localizedAndroidStringForKey: @"pocahontas" value: @"A princess" table: nil];
    
    GHAssertEqualStrings(v2, @"A princess", @"Unknown key failed");
    
    NSString* empty = [[NSBundle mainBundle] localizedAndroidStringForKey: nil value: @"no crash?" table: nil];
    
    GHAssertNil(empty, @"Should be no value returned when the key is empty");
    
    NSString* trimmed = [v1 stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    GHAssertEqualStrings(trimmed, v1, @"'%@' has some white space", v1);
}

- (void) testMacro {
    NSString* sound = NSLocalizedString(@"sound", @"");
    
    GHAssertEqualStrings(sound, @"Ton", @"Macro did not return 'Ton' but %@", sound);
}

@end
