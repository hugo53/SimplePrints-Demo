//
//  NSObject+Helper.h
//  YoloNews
//
//  Created by hugo on 1/18/14.
//  Copyright (c) 2014 YoloSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Helper)

+ (NSString *) getPublishDateString:(NSNumber *) publishedDate;

+(NSDateComponents *)getDateComponents:(NSDate*)date;
+(NSDateComponents *)getDateComponentsWithHour:(NSDate*)date;
+ (NSDate *) getDateFromComponents:(NSDateComponents *) components;
+ (NSString *) getMediumMonthInStringFormat:(NSDate *) date;
+ (NSString *) getFullMonthInStringFormat:(NSDate *) date;

+(int)getYear:(NSDate*)date;
+(int)getMonth:(NSDate*)date;
+(int)getDay:(NSDate*)date;
+(int)getHour:(NSDate*)date;
+(int)getMinute:(NSDate*)date;
+(int)getSecond:(NSDate*)date;
+(NSString *) getDateInStringFormat:(NSDate *) date;
+(NSString *) getMonthInStringFormat:(NSDate *) date;
+(NSString *) getYearInStringFormat:(NSDate *) date;
+ (NSString *) getLocalizedDateInStringFormat:(NSDate *) date;

+(NSDate *) getNextDateFromDate:(NSDate *) originDate withIntervalInDay:(NSInteger) numOfDays;
+(NSDate *) getPreviousDateFromDate:(NSDate *) originDate withIntervalInDay:(NSInteger) numOfDays;
+ (NSInteger) getIndexFromDate:(NSDate *) calculatingDate withRootDate:(NSDate *) rootDate;
+ (BOOL) aDate:(NSDate *) aDate isEqualToDate:(NSDate *) anotherDate;

@end
