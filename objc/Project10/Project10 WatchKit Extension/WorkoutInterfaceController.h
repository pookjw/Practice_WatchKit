//
//  WorkoutInterfaceController.h
//  Project10 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/31/21.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

typedef NS_ENUM(NSUInteger, DisplayMode) {
    kDistanceType, kEnergyType, kHeartRateType
};

@interface WorkoutInterfaceController : WKInterfaceController <HKWorkoutSessionDelegate>
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *quantityLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *unitLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *stopButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *resumeButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *endButton;
@property HKHealthStore *healthStore;
@property HKQuantityTypeIdentifier distanceType;
@property NSDate *workoutStartDate;
@property NSDate *workoutEndDate;
@property NSMutableArray<HKQuery *> *activeDataQueries;
@property HKWorkoutSession *workoutSession;
@property DisplayMode displayMode;
@property HKQuantity *totalEnergyBurned;
@property HKQuantity *totalDistance;
@property double lastHeartRate;
@property HKUnit *countPerMinuteUnit;
@property BOOL workoutIsActive;
@end
