//
//  NSObject+Helper.m
//  YoloNews
//
//  Created by hugo on 1/18/14.
//  Copyright (c) 2014 YoloSoft. All rights reserved.
//

#import "NSObject+Helper.h"

@implementation NSObject (Helper)

/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

+ (NSString *) getPublishDateString:(NSNumber *) publishedDate{
    long currentTime = [[NSDate date] timeIntervalSince1970];
    long offsetTime = currentTime - [publishedDate longValue];
    
    int relativeTime;
    if (offsetTime > 7*24*60*60) {
        // Show absolute date, i.e: 30 Dec 2013 and should be localized
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[publishedDate longValue]];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        
        return [dateFormatter stringFromDate:date];
    }else if (offsetTime > 24*60*60){
        // Show  with 'x days ago'
        relativeTime = offsetTime/(24*60*60);
        return (relativeTime > 1)   ? [NSString stringWithFormat:NSLocalizedString(@"publishedDateDays", nil), relativeTime]
                                    : [NSString stringWithFormat:NSLocalizedString(@"publishedDateDay", nil), relativeTime];
    }else if (offsetTime > 60*60){
        // Show with 'x hours ago'
        relativeTime = offsetTime/(60*60);
        return (relativeTime > 1)   ? [NSString stringWithFormat:NSLocalizedString(@"publishedDateHours", nil), relativeTime]
                                    : [NSString stringWithFormat:NSLocalizedString(@"publishedDateHour", nil), relativeTime];
    }else if (offsetTime > 60){
        // Show with 'x mins ago'
        relativeTime = offsetTime/60;
        return (relativeTime > 1)   ? [NSString stringWithFormat:NSLocalizedString(@"publishedDateMins", nil), relativeTime]
                                    : [NSString stringWithFormat:NSLocalizedString(@"publishedDateMin", nil), relativeTime];
    }else{
        // Show with 'Just now'
        return [NSString stringWithString:NSLocalizedString(@"publishedDateJustNow", nil)];
    }
    
}


+(NSDateComponents *)getDateComponentsWithHour:(NSDate*)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:date];
    
    return components;
}

+(NSDateComponents *)getDateComponents:(NSDate*)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    
    return components;
}

+ (NSDate *) getDateFromComponents:(NSDateComponents *) components {
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

+(int)getYear:(NSDate*)date {
    
    return [[self getDateComponents:date] year];
}

+(int)getDay:(NSDate*)date {
    return [[self getDateComponents:date] day];
}


+(int)getMonth:(NSDate*)date {
    return [[self getDateComponents:date] month];
}

+(int)getHour:(NSDate*)date {
    return [[self getDateComponentsWithHour:date] hour];
}

+(int)getMinute:(NSDate*)date {
    return [[self getDateComponentsWithHour:date] minute];
}

+(int)getSecond:(NSDate*)date {
    return [[self getDateComponentsWithHour:date] second];
}

+(NSString *) getDateInStringFormat:(NSDate *) date {
    NSInteger day = [self getDay:date];
    NSInteger hour = [self getHour:date];
    NSInteger minute = [self getMinute:date];
    
    NSString *dayStr = (day > 9) ? [NSString stringWithFormat:@"%d", day] : [NSString stringWithFormat:@"0%d", day];
    NSString *hourStr = (hour > 9) ? [NSString stringWithFormat:@"%d", hour] : [NSString stringWithFormat:@"0%d", hour];
    NSString *minStr = (minute > 9) ? [NSString stringWithFormat:@"%d", minute] : [NSString stringWithFormat:@"0%d", minute];

    return [NSString stringWithFormat:@"%@. %@, %d %@:%@", [self getMediumMonthInStringFormat:date], dayStr, [self getYear:date], hourStr, minStr];
}

+ (NSString *) getLocalizedDateInStringFormat:(NSDate *) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    return [dateFormatter stringFromDate:date];
}

+ (NSString *) getMediumMonthInStringFormat:(NSDate *) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    int monthInNumber = [self getMonth:date];
    
    return [[dateFormatter shortMonthSymbols] objectAtIndex:(monthInNumber - 1)];
}

+ (NSString *) getFullMonthInStringFormat:(NSDate *) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    int monthInNumber = [self getMonth:date];
    
    return [[dateFormatter monthSymbols] objectAtIndex:(monthInNumber - 1)];
}

+(NSString *) getMonthInStringFormat:(NSDate *) date {
    return [NSString stringWithFormat:@"%d-%d", [self getYear:date], [self getMonth:date]];
}

+(NSString *) getYearInStringFormat:(NSDate *) date {
    return [NSString stringWithFormat:@"%d", [self getYear:date]];
}

/**
 *  <#Description#>
 *
 *  @param calculatingDate <#calculatingDate description#>
 *  @param rootDate        <#rootDate description#>
 *
 *  @return negative if the calculating Date is past, positive if the calculating date is future
 */
+ (NSInteger) getIndexFromDate:(NSDate *) calculatingDate withRootDate:(NSDate *) rootDate{
    float different = [calculatingDate timeIntervalSinceDate:rootDate];
    
    return (int) different/(24*60*60);
}


+ (BOOL) aDate:(NSDate *) aDate isEqualToDate:(NSDate *) anotherDate {
    if ([self getYear:aDate] == [self getYear:anotherDate]
        && [self getMonth:aDate] == [self getMonth:anotherDate]
        && [self getDay:aDate] == [self getDay:anotherDate]
        ) {
        return YES;
    }
    return NO;
}


@end
