//
//  ComplicationController.h
//  Project7 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/26/21.
//

#import <ClockKit/ClockKit.h>
#import "NSArray+containsString.h"

@interface ComplicationController : NSObject <CLKComplicationDataSource>
@property NSSet<NSString *> *positiveAnswers;
@property NSSet<NSString *> *uncertainAnswers;
@property NSSet<NSString *> *negativeAnswers;
@property NSArray<NSString *> *allAnswers;
@end
