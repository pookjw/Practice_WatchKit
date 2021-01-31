//
//  InterfaceController.m
//  Project10 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/31/21.
//

#import "InterfaceController.h"

@implementation InterfaceController

- (void)setup {
    self.activities = @{
        @"Cycling": [NSNumber numberWithUnsignedInteger:HKWorkoutActivityTypeCycling],
        @"Running": [NSNumber numberWithUnsignedInteger:HKWorkoutActivityTypeRunning],
        @"Swimming": [NSNumber numberWithUnsignedInteger:HKWorkoutActivityTypeSwimming],
        @"Wheelchair": [NSNumber numberWithUnsignedInteger:HKWorkoutActivityTypeWheelchairRunPace]
    };
    self.selectedActivity = HKWorkoutActivityTypeCycling;
}

- (void)awakeWithContext:(id)context {
    [self setup];
    [super awakeWithContext:context];
    
    NSMutableArray<WKPickerItem *> *items = [@[] mutableCopy];
    
    [self.activities enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull string, NSNumber * _Nonnull number, BOOL * _Nonnull stop){
        WKPickerItem *item = [WKPickerItem new];
        item.title = string;
        [items addObject:item];
    }];
    
    [self.activityType setItems:items];
}

- (IBAction)activityPickerChanged:(NSInteger)value {
    NSArray<NSString *> *keys = [self.activities allKeys];
    NSString *key = keys[value];
    self.selectedActivity = (HKWorkoutActivityType)[self.activities[key] unsignedIntegerValue];
}

- (IBAction)startWorkoutTapped {
    if (![HKHealthStore isHealthDataAvailable]) return;
    
    [WKInterfaceController reloadRootPageControllersWithNames:@[@"WorkoutInterfaceController"]
                                                     contexts:@[[NSNumber numberWithUnsignedInteger:self.selectedActivity]]
                                                  orientation:WKPageOrientationHorizontal
                                                    pageIndex:0];
}

@end



