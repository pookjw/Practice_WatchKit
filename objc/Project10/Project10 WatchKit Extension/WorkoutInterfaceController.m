//
//  WorkoutInterfaceController.m
//  Project10 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/31/21.
//

#import "WorkoutInterfaceController.h"

@implementation WorkoutInterfaceController

- (void)setup {
    self.distanceType = HKQuantityTypeIdentifierDistanceCycling;
    self.workoutStartDate = [NSDate new];
    self.workoutEndDate = [NSDate new];
    self.activeDataQueries = [@[] mutableCopy];
    self.workoutSession = nil;
    self.displayMode = kDistanceType;
    self.totalEnergyBurned = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:0];
    self.totalDistance = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:0];
    self.lastHeartRate = 0.0;
    self.countPerMinuteUnit = [HKUnit unitFromString:@"count/min"];
    self.workoutIsActive = YES;
}

- (void)awakeWithContext:(id)context {
    [self setup];
    [super awakeWithContext:context];
    
    NSNumber *number = (NSNumber *)context;
    if (number == nil) return;
    HKWorkoutActivityType activity = (HKWorkoutActivityType)[number unsignedIntegerValue];
    
    switch (activity) {
        case HKWorkoutActivityTypeCycling:
            self.distanceType = HKQuantityTypeIdentifierDistanceCycling;
            break;
        case HKWorkoutActivityTypeRunning:
            self.distanceType = HKQuantityTypeIdentifierDistanceWalkingRunning;
            break;
        case HKWorkoutActivityTypeSwimming:
            self.distanceType = HKQuantityTypeIdentifierDistanceSwimming;
            break;
        default:
            self.distanceType = HKQuantityTypeIdentifierDistanceWheelchair;
            break;
    }
    
    // configure the values we want to write
    NSSet<HKSampleType *> * const sampleTypes = [NSSet<HKSampleType *> setWithArray:@[
        [HKObjectType workoutType],
        [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
        [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],
        [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling],
        [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
        [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceSwimming],
        [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWheelchair]
    ]];
    
    // create our health store
    self.healthStore = [HKHealthStore new];
    
    // use it to request authorization for our types
    [self.healthStore requestAuthorizationToShareTypes:sampleTypes readTypes:sampleTypes completion:^(BOOL success, NSError * _Nullable error){
        if (success) {
            // start workout!
            [self startWorkoutForType:activity];
        }
    }];
}

- (void)startQueryWithType:(HKQuantityTypeIdentifier)quantityTypeIdentifier {
    // we only want data points after our workout start date
    NSPredicate *datePredicate = [HKQuery predicateForSamplesWithStartDate:self.workoutStartDate
                                                               endDate:nil
                                                               options:HKQueryOptionStrictStartDate];
    
    // we only want data points that come from our current
    NSPredicate *devicePredicate = [HKQuery predicateForObjectsFromDevices:[NSSet setWithArray:@[[HKDevice localDevice]]]];
    
    // combine the two predicates into one
    NSCompoundPredicate *queryPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[datePredicate, devicePredicate]];
    
    // write code to receive results into one
    void (^updateHandler)(HKAnchoredObjectQuery * _Nonnull, NSArray<__kindof HKSample *> * _Nullable, NSArray<HKDeletedObject *> * _Nullable, HKQueryAnchor * _Nullable, NSError * _Nullable) = ^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable sampleObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error){
        // safely typecast to a quantity sample so we can read values
        NSArray<HKQuantitySample *> *samples = (NSArray<HKQuantitySample *> *)sampleObjects;
        if (samples == nil) return;
        
        // just print them out for now
//        NSLog(@"%@", samples);
        [self process:samples type:quantityTypeIdentifier];
    };
    
    // create the query out of our type (e.g. heart rate), predicate, and result handling code
    HKAnchoredObjectQuery *query = [[HKAnchoredObjectQuery alloc] initWithType:[HKObjectType quantityTypeForIdentifier:quantityTypeIdentifier]
                                                                     predicate:queryPredicate
                                                                        anchor:nil
                                                                         limit:HKObjectQueryNoLimit
                                                                resultsHandler:updateHandler];
    
    // tell HealthKit to re-run the code every time new data is availanle
    query.updateHandler = updateHandler;
    
    // start the query running
    [self.healthStore executeQuery:query];
    
    // stash it away so we can stop it later
    [self.activeDataQueries addObject:query];
}

- (void)startQueries {
    [self startQueryWithType:self.distanceType];
    [self startQueryWithType:HKQuantityTypeIdentifierActiveEnergyBurned];
    [self startQueryWithType:HKQuantityTypeIdentifierHeartRate];
    [WKInterfaceDevice.currentDevice playHaptic:WKHapticTypeStart];
    
    if (self.distanceType == HKQuantityTypeIdentifierDistanceSwimming) {
        [WKInterfaceDevice.currentDevice enableWaterLock];
    }
}

- (void)cleanUpQueries {
    for (HKQuery *query in self.activeDataQueries) {
        [self.healthStore stopQuery:query];
    }
    
    [self.activeDataQueries removeAllObjects];
}

- (void)saveWithSession:(HKWorkoutSession *)workoutSession {
    HKWorkoutConfiguration *config = workoutSession.workoutConfiguration;
    HKWorkout *workout = [HKWorkout workoutWithActivityType:config.activityType
                                                  startDate:self.workoutStartDate
                                                    endDate:self.workoutEndDate
                                              workoutEvents:nil
                                          totalEnergyBurned:self.totalEnergyBurned
                                              totalDistance:self.totalDistance
                                                   metadata:@{HKMetadataKeyIndoorWorkout: @NO}];
    
    [self.healthStore saveObject:workout withCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [WKInterfaceController reloadRootPageControllersWithNames:@[@"InterfaceController"]
                                                                 contexts:nil
                                                              orientation:WKPageOrientationHorizontal
                                                                pageIndex:0];
            });
        }
    }];
}

- (void)updateLabels {
    switch (self.displayMode) {
        case kDistanceType:
        {
            double meters = [self.totalDistance doubleValueForUnit:[HKUnit meterUnit]];
            double kilometers = meters / 100;
            NSString *formattedKilometers = [NSString stringWithFormat:@"%.2f", kilometers];
            
            [self.quantityLabel setText:formattedKilometers];
            [self.unitLabel setText:@"KILOMETERS"];
            break;
        }
        case kEnergyType:
        {
            double kilocalories = [self.totalEnergyBurned doubleValueForUnit:[HKUnit kilocalorieUnit]];
            NSString *formattedKilocalories = [NSString stringWithFormat:@"%.0f", kilocalories];
            [self.quantityLabel setText:formattedKilocalories];
            [self.unitLabel setText:@"CALORIES"];
            break;
        }
        case kHeartRateType: {
            NSString *heartRate = [NSString stringWithFormat:@"%lu", (unsigned long)self.lastHeartRate];
            [self.quantityLabel setText:heartRate];
            [self.unitLabel setText:@"BEATS / MINUTE"];
            break;
        }
    }
}

- (void)process:(NSArray<HKQuantitySample *> *)samples type:(HKQuantityTypeIdentifier)type {
    // ignore updates while we are paused
    if (!self.workoutIsActive) return;
    
    // loop over all the samples we've been sent
    for (HKQuantitySample *sample in samples) {
        // this is a calorie count
        if (type == HKQuantityTypeIdentifierActiveEnergyBurned) {
            // find out how many calories were burned
            double newEnergy = [sample.quantity doubleValueForUnit:[HKUnit kilocalorieUnit]];
            
            // get our current total calorie burn
            double currentEnergy = [self.totalEnergyBurned doubleValueForUnit:[HKUnit kilocalorieUnit]];
            
            // add the two together and store it
            self.totalEnergyBurned = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:currentEnergy + newEnergy];
            
            // print out the new total for debugging purposes
            NSLog(@"Total envergy: %@", self.totalEnergyBurned);
        } else if (type == HKQuantityTypeIdentifierHeartRate) {
            // we got a heart rate - just update the property
            self.lastHeartRate = [sample.quantity doubleValueForUnit:self.countPerMinuteUnit];
            NSLog(@"Last heart rate: %f", self.lastHeartRate);
        } else if (type == self.distanceType) {
            // we got a distance traveled value
            double newDistance = [sample.quantity doubleValueForUnit:[HKUnit meterUnit]];
            double currentDistance = [self.totalDistance doubleValueForUnit:[HKUnit meterUnit]];
            self.totalDistance = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:currentDistance + newDistance];
            NSLog(@"Total distance: %@", self.totalDistance);
        }
    }
    
    // update our user interface
    [self updateLabels];
}

- (void)startWorkoutForType:(HKWorkoutActivityType)type {
    if (self.healthStore == nil) return;
    
    // 1: create a workout configuration
    HKWorkoutConfiguration *config = [HKWorkoutConfiguration new];
    config.activityType = type;
    config.locationType = HKWorkoutSessionLocationTypeOutdoor;
    
    // 2: create a workout session from that
    NSError * _Nullable error = nil;
    HKWorkoutSession *session = [[HKWorkoutSession alloc] initWithHealthStore:self.healthStore configuration:config error:&error];
    
    if (error == nil) {
        self.workoutSession = session;
        
        // 3: start the workout now
        [session startActivityWithDate:[NSDate new]];
        
        // 4: register receive status updates
        session.delegate = self;
    }
}

- (IBAction)changeDisplayMode {
    switch (self.displayMode) {
        case kDistanceType:
        {
            self.displayMode = kEnergyType;
            break;
        }
        case kEnergyType:
        {
            self.displayMode = kHeartRateType;
            break;
        }
        case kHeartRateType:
        {
            self.displayMode = kDistanceType;
            break;
        }
    }
    
    [self updateLabels];
}

- (IBAction)stopWorkout {
    if (self.workoutSession == nil) return;
    
    [self.stopButton setHidden:YES];
    [self.resumeButton setHidden:NO];
    [self.endButton setHidden:NO];
    
    [self.workoutSession pause];
}

- (IBAction)resumeWorkout {
    if (self.workoutSession == nil) return;
    
    [self.stopButton setHidden:NO];
    [self.resumeButton setHidden:YES];
    [self.endButton setHidden:YES];
    
    [self.workoutSession resume];
}

- (IBAction)endWorkout {
    if (self.workoutSession == nil) return;
    self.workoutEndDate = [NSDate new];
    
    [self.workoutSession end];
}

#pragma mark - HKWorkoutSessionDelegate

- (void)workoutSession:(HKWorkoutSession *)workoutSession didChangeToState:(HKWorkoutSessionState)toState fromState:(HKWorkoutSessionState)fromState date:(NSDate *)date {
    switch (toState) {
        case HKWorkoutSessionStateRunning:
        {
            if (fromState == HKWorkoutSessionStateNotStarted) {
                [self startQueries];
            } else {
                self.workoutIsActive = YES;
            }
            break;
        }
        case HKWorkoutSessionStatePaused:
        {
            self.workoutIsActive = NO;
            break;
        }
        case HKWorkoutSessionStateEnded:
        {
            self.workoutIsActive = NO;
            [self cleanUpQueries];
            [self saveWithSession:workoutSession];
            break;
        }
        default:
            break;
    }
}

- (void)workoutSession:(HKWorkoutSession *)workoutSession didFailWithError:(NSError *)error {
    
}

@end



