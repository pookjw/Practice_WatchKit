//
//  AppDelegate.m
//  Project10
//
//  Created by Jinwoo Kim on 1/31/21.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self requestHealthKitAccess];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

- (void)applicationShouldRequestHealthAuthorization:(UIApplication *)application {
    HKHealthStore *healthStore = [HKHealthStore new];
    [healthStore handleAuthorizationForExtensionWithCompletion:^(BOOL success, NSError * _Nullable error){
        NSLog(@"Success!");
    }];
}

- (void)requestHealthKitAccess {
    NSSet<HKSampleType *> *sampleTypes = [NSSet<HKSampleType *> setWithArray:@[
        [HKObjectType workoutType],
        [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
        [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],
        [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling],
        [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
        [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceSwimming],
        [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWheelchair]
    ]];
    
    HKHealthStore *healthStore = [HKHealthStore new];
    [healthStore requestAuthorizationToShareTypes:sampleTypes
                                        readTypes:sampleTypes
                                       completion:^(BOOL success, NSError * _Nullable error){
        if (success) {
            
        }
    }];
}

@end
