//
//  NSBundle+AndroidStrings.h
//  cocolize
//
//  Created by MacBook Pro on 31/07/12.
//  Copyright (c) 2012 Tall Developments. All rights reserved.
//

@interface NSBundle (AndroidStrings)

- (NSString*) localizedAndroidStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;

@end

#undef NSLocalizedString
#define NSLocalizedString(key, _comment) [[NSBundle mainBundle] localizedAndroidStringForKey: key value: nil table: nil];
