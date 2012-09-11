//
//  NSBundle+AndroidStrings.m
//  cocolize
//
//  Created by MacBook Pro on 31/07/12.
//  Copyright (c) 2012 Tall Developments. All rights reserved.
//

#import "NSBundle+AndroidStrings.h"
#import "AndroidStringsReader.h"

#import <objc/runtime.h>

static char* kNSBundleAndroidStringsTableAssociationKey = "NSBundle.stringsTables";

@interface NSBundle () <NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableDictionary* stringTables;

@end

@implementation NSBundle (AndroidStrings)

- (NSDictionary*) stringTables {
    return objc_getAssociatedObject(self, &kNSBundleAndroidStringsTableAssociationKey);
}

- (void) setStringTables:(NSDictionary *)stringTables {
    objc_setAssociatedObject(self, &kNSBundleAndroidStringsTableAssociationKey, stringTables, OBJC_ASSOCIATION_RETAIN);
}

- (NSString*) localizedAndroidStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    if( !key )
        return nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.stringTables = [NSMutableDictionary dictionary];
    });
    
    @synchronized(self) {
        if( ![tableName length] )
            tableName = @"strings.xml";
        
        NSDictionary* table = [self.stringTables objectForKey: tableName];
        if( !table ) {
            
            NSString* tableFileName = [[tableName lastPathComponent] stringByDeletingLastPathComponent];
            NSString* tableExtension = [tableName pathExtension];
            
            if( ![tableFileName length] )
                tableFileName = @"strings";
            if( ![tableExtension length] )
                tableExtension = @"xml";
            
            NSString* tablePath = [[NSBundle mainBundle] pathForResource: tableFileName ofType: tableExtension];
            NSData* tableData = [NSData dataWithContentsOfFile: tablePath];
            NSError* error = nil;
            
            table = [AndroidStringsReader dictionaryForXMLData: tableData
                                                         error: &error];
            
            if( error ) {
                NSException* exception = [NSException exceptionWithName: @"Strings Table"
                                                                 reason: @"There was an error creating the strings table"
                                                               userInfo: @{ @"TableName" : tableName, @"Underlying Error" : error }];
                [exception raise];
            }
            else {
                if( table )
                    [self.stringTables setObject: table forKey: tableName];
                else {
                    NSException* exception = [NSException exceptionWithName: @"Strings Table"
                                                                     reason: @"There was no strings table created"
                                                                   userInfo: @{ @"TableName" : tableName}];
                    [exception raise];
                }
            }
        }
        
        NSString* tableValue = [table objectForKey: key];
        if( !tableValue )
            tableValue = value;
        
        return tableValue;
    }
}

@end
