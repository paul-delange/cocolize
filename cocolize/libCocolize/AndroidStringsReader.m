//
//  AndroidStringsReader.m
//  cocolize
//
//  Created by MacBook Pro on 31/07/12.
//  Copyright (c) 2012 Tall Developments. All rights reserved.
//

#import "AndroidStringsReader.h"

#import "printf-parse.h"

NSString *const kXMLReaderTextNodeKey = @"text";

@interface AndroidStringsReader () <NSXMLParserDelegate> {
    NSMutableArray* dictionaryStack;
    NSMutableString* textInProgress;
    NSError * __autoreleasing* errorPointer;
}

- (id)initWithError:(NSError **)error;
- (NSDictionary *)objectWithData:(NSData *)data;

@end

@implementation AndroidStringsReader

+ (NSDictionary*) dictionaryForXMLData: (NSData*) data error: (NSError **) error {
    AndroidStringsReader* reader = [[AndroidStringsReader alloc] initWithError: error];
    NSDictionary* root = [reader objectWithData: data];
    return root;
}

- (id)initWithError:(NSError **)error
{
    if (self = [super init])
    {
        errorPointer = error;
    }
    return self;
}

- (NSDictionary *)objectWithData:(NSData *)data
{
    dictionaryStack = [[NSMutableArray alloc] init];
    textInProgress = [[NSMutableString alloc] init];
    
    // Initialize the stack with a fresh dictionary
    [dictionaryStack addObject:[NSMutableDictionary dictionary]];
    
    // Parse the XML
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    BOOL success = [parser parse];
    
    // Return the stack’s root dictionary on success
    if (success)
    {
        NSDictionary *resultDict = [dictionaryStack objectAtIndex:0];
        NSDictionary* resources = [resultDict objectForKey: @"resources"];
        NSArray* strings = [resources objectForKey: @"string"];
        
        NSMutableDictionary* mutable = [NSMutableDictionary dictionaryWithCapacity: [strings count]];
        NSMutableDictionary* unparsable = [NSMutableDictionary dictionary];
        
        for(NSDictionary* string in strings) {
            NSString* key = [string objectForKey: @"name"];
            NSString* value = [string objectForKey: @"text"];
            
            //Has nasty whitespace
            key = [key stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            value = [value stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if( [key length] && [value length] ) {
                
                const char* utf8 = [value UTF8String];
                char_directives d;
                arguments a;
                printf_parse(utf8, &d, &a);
                
                if( d.count ) {
                for(NSUInteger i=0;i<d.count;i++) {
                    char_directive directive = d.dir[i];
                    NSInteger start = directive.dir_start-utf8;
                    NSInteger length = directive.dir_end-directive.dir_start;
                    
                    switch (directive.conversion) {
                        case 's':
                        case 'S':
                        {
                            NSRange conversionRange = [value rangeOfString: @"s"
                                                                   options: NSCaseInsensitiveSearch
                                                                     range: NSMakeRange(start, length)];
                            
                            if( conversionRange.location == NSNotFound ) {
                                NSLog(@"Could not find 's' specifier in: '%@'", value);
                                [unparsable setObject: value forKey: key];
                                goto stop_parsing;
                            }
                            else {
                                value = [value stringByReplacingCharactersInRange: conversionRange withString: @"@"];
                                [mutable setObject: value
                                            forKey: key];
                            }
                            break;
                        }
                        case 'c':
                        case 'C':
                        {
                            NSRange conversionRange = [value rangeOfString: @"c"
                                                                   options: NSCaseInsensitiveSearch
                                                                     range: NSMakeRange(start, length)];
                            
                            if( conversionRange.location == NSNotFound ) {
                                NSLog(@"Could not find 'c' specifier in: '%@'", value);
                                [unparsable setObject: value forKey: key];
                                goto stop_parsing;
                            }
                            else {
                                value = [value stringByReplacingCharactersInRange: conversionRange withString: @"@"];
                                [mutable setObject: value
                                            forKey: key];
                            }
                            break;
                        }
                        case 'i':
                        case 'I':
                        case 'd':
                        case 'D':
                        {
                            NSInteger widthLength = directive.width_end-directive.width_start;
                            NSInteger precisionLength = directive.precision_start-directive.precision_end;
                            if (directive.flags == 0 &&
                                widthLength <= 0     &&
                                precisionLength <= 0    ) {
                                NSRange conversionRange = [value rangeOfString: @"d"
                                                                       options: NSCaseInsensitiveSearch
                                                                         range: NSMakeRange(start, length)];
                                
                                if( conversionRange.location == NSNotFound ) {
                                    NSLog(@"Could not find 'd' specifier in: '%@'", value);
                                    [unparsable setObject: value forKey: key];
                                    goto stop_parsing;
                                }
                                else {
                                    value = [value stringByReplacingCharactersInRange: conversionRange withString: @"@"];
                                    [mutable setObject: value
                                                forKey: key];
                                }
                            }
                            else {
                                [mutable setObject: value forKey: key];
                            }
                            break;
                        }
                        case 'f':
                        case 'F':
                        {
                            NSInteger widthLength = directive.width_end-directive.width_start;
                            NSInteger precisionLength = directive.precision_start-directive.precision_end;
                            if (directive.flags == 0 &&
                                widthLength <= 0     &&
                                precisionLength <= 0    ) {
                                NSRange conversionRange = [value rangeOfString: @"f"
                                                                       options: NSCaseInsensitiveSearch
                                                                         range: NSMakeRange(start, length)];
                                
                                if( conversionRange.location == NSNotFound ) {
                                    NSLog(@"Could not find 'f' specifier in: '%@'", value);
                                    [unparsable setObject: value forKey: key];
                                    goto stop_parsing;
                                }
                                else {
                                    value = [value stringByReplacingCharactersInRange: conversionRange withString: @"@"];
                                    [mutable setObject: value
                                                forKey: key];
                                }
                            }
                            else {
                                [mutable setObject: value forKey: key];
                            }
                            break;
                        }
                        default:
                        {
                            NSLog(@"Could not parse: '%@'", value);
                            [unparsable setObject: value forKey: key];
                            goto stop_parsing;
                        }
                    }
                }
                
                continue;
                
            stop_parsing:
                NSLog(@"Skipping other specifiers for string: '%@'", value);
                }
                else {
                    [mutable setObject: value forKey: key];
                }
            }
        }
        
        if( [unparsable count]) {
            NSLog(@"Warning!! Could not parse the following strings:");
            for(NSString* key in [unparsable allKeys]) {
                NSLog(@"[%@] = '%@'", key, [unparsable valueForKey: key]);
            }
        }
        
        for(NSString* key in [mutable allKeys]) {
            NSLog(@"[%@]='%@'", key, [mutable valueForKey: key]);
        }
        
        return mutable;
    }
    
    return nil;
}

#pragma mark - NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // Get the dictionary for the current level in the stack
    NSMutableDictionary *parentDict = [dictionaryStack lastObject];
    
    // Create the child dictionary for the new element, and initilaize it with the attributes
    NSMutableDictionary *childDict = [NSMutableDictionary dictionary];
    [childDict addEntriesFromDictionary:attributeDict];
    
    // If there’s already an item for this key, it means we need to create an array
    id existingValue = [parentDict objectForKey:elementName];
    if (existingValue)
    {
        NSMutableArray *array = nil;
        if ([existingValue isKindOfClass:[NSMutableArray class]])
        {
            // The array exists, so use it
            array = (NSMutableArray *) existingValue;
        }
        else
        {
            // Create an array if it doesn’t exist
            array = [NSMutableArray array];
            [array addObject:existingValue];
            
            // Replace the child dictionary with an array of children dictionaries
            [parentDict setObject:array forKey:elementName];
        }
        
        // Add the new child dictionary to the array
        [array addObject:childDict];
    }
    else
    {
        // No existing value, so update the dictionary
        [parentDict setObject:childDict forKey:elementName];
    }
    
    // Update the stack
    [dictionaryStack addObject:childDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // Update the parent dict with text info
    NSMutableDictionary *dictInProgress = [dictionaryStack lastObject];
    
    // Set the text property
    if ([textInProgress length] > 0)
    {
        // Get rid of leading + trailing whitespace
        [dictInProgress setObject:textInProgress forKey:kXMLReaderTextNodeKey];
        
        // Reset the text
        textInProgress = [[NSMutableString alloc] init];
    }
    
    // Pop the current dict
    [dictionaryStack removeLastObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    // Build the text value
    [textInProgress appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    // Set the error pointer to the parser’s error object
    *errorPointer = parseError;
}

@end

