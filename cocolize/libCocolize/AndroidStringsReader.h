//
//  AndroidStringsReader.h
//  cocolize
//
//  Created by MacBook Pro on 31/07/12.
//  Copyright (c) 2012 Tall Developments. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AndroidStringsReader : NSObject

+ (NSDictionary*) dictionaryForXMLData: (NSData*) data error: (NSError **) error;

@end
