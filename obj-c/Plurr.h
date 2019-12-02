//
// Plurr.h
// Copyright (C) 2015 Igor Afanasyev, https://github.com/iafan/Plurr
//

#import <Foundation/Foundation.h>

@interface Plurr : NSObject

@property(nonatomic) NSLocale* locale;

- (NSString*)stringWithFormat:(NSString*)format arguments:(NSDictionary*)arguments;
- (NSString*)localizedStringWithFormat:(NSString*)format arguments:(NSDictionary*)arguments;

+ (NSString*)stringWithFormat:(NSString*)format arguments:(NSDictionary*)arguments;
+ (NSString*)localizedStringWithFormat:(NSString*)format arguments:(NSDictionary*)arguments;

@end

NSString* PlurrLocalizedString(NSString* format, NSDictionary* arguments);