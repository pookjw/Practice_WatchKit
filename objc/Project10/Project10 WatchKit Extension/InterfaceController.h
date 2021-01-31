//
//  InterfaceController.h
//  Project10 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/31/21.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@interface InterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfacePicker *activityType;
@property NSDictionary<NSString *, NSNumber *> *activities;
@property HKWorkoutActivityType selectedActivity;
@end
