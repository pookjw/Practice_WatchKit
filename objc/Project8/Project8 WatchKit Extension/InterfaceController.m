//
//  InterfaceController.m
//  Project8 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/27/21.
//

#import "InterfaceController.h"

@implementation InterfaceController

- (void)setup {
    self.correctSafeValue = (float)50;
    self.targetSafeValue = 0;
    self.allSafeNumbers = [@[] mutableCopy];
    self.correctValues = [@[] mutableCopy];
}

- (void)awakeWithContext:(id)context {
    [self setup];
    [super awakeWithContext:context];
    [self startNewGame];
}

- (void)didAppear {
    [super didAppear];
    [self.crownSequencer focus];
    self.crownSequencer.delegate = self;
}

- (void)startNewGame {
    // reset and start the timer
    [self.timer setDate:[NSDate new]];
    [self.timer start];
    
    // create an array of random numbers from 0 to 100
    for (NSUInteger i = 0; i <= 10; i++) {
        [self.allSafeNumbers addObject:[NSNumber numberWithUnsignedInteger:i]];
    }
    [self.allSafeNumbers shuffle];
    
    // reset the current value
    self.correctSafeValue = 50;
    [self.safeValue setValue:50];
    
    // remove all their previous answers and reset the text
    [self.correctValues removeAllObjects];
    [self.numbersLabel setText:@"Safe Crack"];
    
    // pick the first number to guess
    [self pickNumber];
}

- (void)pickNumber {
    self.targetSafeValue = [self.allSafeNumbers[0] unsignedIntegerValue];
    [self.allSafeNumbers removeObjectAtIndex:0];
    NSLog(@"%lu", self.targetSafeValue);
    [self numberIsWrong];
}

- (void)numberIsWrong {
    [self.safeValue setColor:UIColor.redColor];
    [self.numbersLabel setTextColor:UIColor.whiteColor];
    [self.nextButton setEnabled:NO];
}

- (IBAction)nextTapped {
    if ((NSUInteger)self.correctSafeValue != self.targetSafeValue) return;
    
    [self.correctValues addObject:[NSString stringWithFormat:@"%lu", (unsigned long)self.targetSafeValue]];
    [self.numbersLabel setText:[self.correctValues componentsJoinedByString:@", "]];
    
    if (self.correctValues.count == 4) {
        [self.timer stop];
        
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            WKAlertAction *playAgain = [WKAlertAction actionWithTitle:@"Play again" style:WKAlertActionStyleDefault handler:^{
                [self startNewGame];
            }];
            [self presentAlertControllerWithTitle:@"You win!" message:nil preferredStyle:WKAlertControllerStyleAlert actions:@[playAgain]];
        });
    } else {
        [self pickNumber];
    }
}

- (void)crownDidRotate:(WKCrownSequencer *)crownSequencer rotationalDelta:(double)rotationalDelta {
    self.correctSafeValue += (float)rotationalDelta;
    self.correctSafeValue = MIN(MAX(0, self.correctSafeValue), 100);
    [self.safeValue setValue:self.correctSafeValue];
    [self.nextButton setTitle:[NSString stringWithFormat:@"Enter %lu", (unsigned long)self.correctSafeValue]];
    
    if ((NSUInteger)self.correctSafeValue == self.targetSafeValue) {
        // this is the right number - tap their wrist
        [WKInterfaceDevice.currentDevice playHaptic:WKHapticTypeClick];
        
        // now update the UI to show this is good
        [self.safeValue setColor:UIColor.greenColor];
        [self.numbersLabel setTextColor:UIColor.greenColor];
        [self.nextButton setEnabled:YES];
    } else {
        // wrong number; make the UI show this is bad
        [self numberIsWrong];
    }
}

@end



