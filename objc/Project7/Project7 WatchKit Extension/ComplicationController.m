//
//  ComplicationController.m
//  Project7 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/26/21.
//

#import "ComplicationController.h"

@implementation ComplicationController

#pragma mark - Complication Configuration

- (void)getComplicationDescriptorsWithHandler:(void (^)(NSArray<CLKComplicationDescriptor *> * _Nonnull))handler {
    /*
     watchOS 7 이후로, Supported Complication Families는 Info.plist가 아니라, 아래 descripters에서 처리한다.
     https://developer.apple.com/documentation/clockkit/declaring_the_complications
     */
//    NSArray<CLKComplicationDescriptor *> *descriptors = @[
//        [[CLKComplicationDescriptor alloc] initWithIdentifier:@"complication"
//                                                  displayName:@"Project7"
//                                            supportedFamilies:CLKAllComplicationFamilies()]
//        // Multiple complication support can be added here with more descriptors
//    ];
    NSArray<CLKComplicationDescriptor *> *descriptors = @[
        [[CLKComplicationDescriptor alloc] initWithIdentifier:@"complication"
                                                  displayName:@"Project7"
                                            supportedFamilies:@[[NSNumber numberWithInt:CLKComplicationFamilyModularLarge], [NSNumber numberWithInt:CLKComplicationFamilyModularSmall]]]
        // Multiple complication support can be added here with more descriptors
    ];
    
    // Call the handler with the currently supported complication descriptors
    handler(descriptors);
}

- (void)handleSharedComplicationDescriptors:(NSArray<CLKComplicationDescriptor *> *)complicationDescriptors {
    // Do any necessary work to support these newly shared complication descriptors
}

#pragma mark - Timeline Configuration

// DEPRECATED
- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void (^)(NSDate * _Nullable))handler {
    NSDate *startDate = [[NSDate new] dateByAddingTimeInterval:-86400];
    handler(startDate);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
    NSDate *endDate = [[NSDate new] dateByAddingTimeInterval:86400];
    handler(endDate);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    // Call the handler with your desired behavior when the device is locked
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)setup {
    self.positiveAnswers = [NSSet<NSString *> setWithArray:@[@"It is certain", @"It is decidedly so", @"Without a doubt", @"Yes definitely", @"As I see it, yes", @"Most likely", @"Outlook good", @"Yes", @"Signs point to yes"]];
    self.uncertainAnswers = [NSSet<NSString *> setWithArray:@[@"Reply hazy, try again", @"Ask again later", @"Better not tell you now", @"Cannot predict now", @"Concentrate and ask again"]];
    self.negativeAnswers = [NSSet<NSString *> setWithArray:@[@"Don't count on it", @"My reply is no", @"My sources say no", @"Outlook not so good", @"Very doubtful"]];
    
    NSMutableArray<NSString *> *tempArr = [@[] mutableCopy];
    [tempArr addObjectsFromArray:[self.positiveAnswers allObjects]];
    [tempArr addObjectsFromArray:[self.uncertainAnswers allObjects]];
    [tempArr addObjectsFromArray:[self.negativeAnswers allObjects]];
    self.allAnswers = tempArr;
}

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    // Call the handler with the current timeline entry
    [self setup];
    
    [self getTimelineEntriesForComplication:complication beforeDate:[NSDate new] limit:1 withHandler:^(NSArray<CLKComplicationTimelineEntry *> * _Nullable entries){
        handler([entries firstObject]);
    }];
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries after the given date
    
    // 1: Create an empty array to return
    NSMutableArray<CLKComplicationTimelineEntry *> *entries = [@[] mutableCopy];
    
    // 2: Create as many entries as requested
    for (NSUInteger i = 0; i < limit; i++) {
        // 3: Calculate the date for this result
        NSDate *predictionDate = [date dateByAddingTimeInterval:(double)(60 * 5 * i)];
        
        // 4: Fetch a completed template for this date
        CLKComplicationTemplate *predictionTemplate = [self templateFor:complication.family date:predictionDate];
        
        // 5: Add in the date
        CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry entryWithDate:predictionDate complicationTemplate:predictionTemplate];
        
        // 6: Append to our result array
        [entries addObject:entry];
    }
    
    // 7: Send back the time line
    handler(entries);
}

// DEPRECATED - but using it
- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void (^)(NSArray<CLKComplicationTimelineEntry *> * _Nullable))handler {
    NSMutableArray<CLKComplicationTimelineEntry *> *entries = [@[] mutableCopy];
    
    // note: reverse the loop!
    for (NSInteger i = limit - 1; i >= 0; i--) {
        // note: reverse dates!
        NSDate *predictionDate = [date dateByAddingTimeInterval:(double)(-60 * 5 * i)];
        CLKComplicationTemplate *predictionTemplate = [self templateFor:complication.family date:predictionDate];
        CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry entryWithDate:predictionDate complicationTemplate:predictionTemplate];
        [entries addObject:entry];
    }
    
    handler(entries);
}

#pragma mark - Sample Templates

- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    // This method will be called once per supported complication, and the results will be cached
    
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge:
        {
            CLKComplicationTemplateModularLargeStandardBody *template = [CLKComplicationTemplateModularLargeStandardBody templateWithHeaderTextProvider:[CLKSimpleTextProvider textProviderWithText:@"Magic 8-ball" shortText:@"8-Ball"]
                                                                                                                                      body1TextProvider:[CLKSimpleTextProvider textProviderWithText:@"Your Prediction" shortText:@"Prediction"]];
            handler(template);
            break;
        }
        case CLKComplicationFamilyModularSmall:
        {
            CLKComplicationTemplateModularSmallSimpleText *template = [CLKComplicationTemplateModularSmallSimpleText templateWithTextProvider:[CLKTextProvider textProviderWithFormat:@"🎱"]];
            handler(template);
            break;
        }
        default:
        {
            handler(nil);
            break;
        }
    }
}

- (CLKComplicationTemplate *)templateFor:(CLKComplicationFamily)family date:(NSDate *)date {
    // find the correct prediction for this data
    NSUInteger predictionNumber = (NSUInteger)date.timeIntervalSince1970 % self.allAnswers.count;
    NSString *prediction = self.allAnswers[predictionNumber];
    
    switch (family) {
        case CLKComplicationFamilyModularLarge:
        {
            // create a long, text-based prediction
            CLKComplicationTemplateModularLargeStandardBody *template = [CLKComplicationTemplateModularLargeStandardBody templateWithHeaderTextProvider:[CLKTextProvider textProviderWithFormat:@"Magic 8-ball"]
                                                                                                                                      body1TextProvider:[CLKTextProvider textProviderWithFormat:@"%@", prediction]];
            return template;
            break;
        }
        default:
        {
            // create a short, emoji-based prediction
            CLKSimpleTextProvider *text;
            
            if ([[self.positiveAnswers allObjects] containsString:prediction]) {
                text = [CLKSimpleTextProvider textProviderWithText:@"😀"];
            } else if ([[self.uncertainAnswers allObjects] containsString:prediction]) {
                text = [CLKSimpleTextProvider textProviderWithText:@"🤔"];
            } else {
                text = [CLKSimpleTextProvider textProviderWithText:@"😧"];
            }
            
            return [CLKComplicationTemplateModularSmallSimpleText templateWithTextProvider:text];
            break;
        }
    }
}

@end
