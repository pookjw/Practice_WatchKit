//
//  InterfaceController.h
//  Project8 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/27/21.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "NSMutableArray+Shuffling.h"

@interface InterfaceController : WKInterfaceController <WKCrownDelegate>
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *numbersLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceSlider *safeValue;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *nextButton;
@property (weak, nonatomic) IBOutlet WKInterfaceTimer *timer;
@property float correctSafeValue;
@property NSUInteger targetSafeValue;
@property NSMutableArray<NSNumber *> *allSafeNumbers;
@property NSMutableArray<NSString *> *correctValues;
@end
