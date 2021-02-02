//
//  ComplicationController.m
//  Project12 WatchKit Extension
//
//  Created by Jinwoo Kim on 2/2/21.
//

#import "ComplicationController.h"

/// 6번
@implementation ComplicationController

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTimeTravelDirections))handler {
    handler(0);
}

- (void)getComplicationDescriptorsWithHandler:(void (^)(NSArray<CLKComplicationDescriptor *> * _Nonnull))handler {
    NSArray<CLKComplicationDescriptor *> *descriptors = @[
        [[CLKComplicationDescriptor alloc] initWithIdentifier:@"complication"
                                                  displayName:@"Project12"
                                            supportedFamilies:@[[NSNumber numberWithInt:CLKComplicationFamilyModularSmall]]]
    ];
    
    handler(descriptors);
}

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTimelineEntry * _Nullable))handler {
    NSString *currentText = [NSUserDefaults.standardUserDefaults valueForKey:@"complication_number"];
    if (currentText == nil) currentText = @"❤️";
    CLKComplicationTemplateModularSmallSimpleText *template = [CLKComplicationTemplateModularSmallSimpleText templateWithTextProvider:[CLKTextProvider textProviderWithFormat:@"%@", currentText]];
    CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry entryWithDate:[NSDate new] complicationTemplate:template];
    handler(entry);
}

- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTemplate * _Nullable))handler {
    // This method will be called once per supported complication, and the results will be cached
    CLKComplicationTemplateModularSmallSimpleText *template = [CLKComplicationTemplateModularSmallSimpleText templateWithTextProvider:[CLKTextProvider textProviderWithFormat:@"💔"]];
    handler(template);
}

@end
