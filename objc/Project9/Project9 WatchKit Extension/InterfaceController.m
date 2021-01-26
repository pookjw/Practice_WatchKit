//
//  InterfaceController.m
//  Project9 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/27/21.
//

#import "InterfaceController.h"

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    self.animation = 1;
    [super awakeWithContext:context];
}

- (IBAction)animateTapped {
    [self animateWithDuration:1 animations:^{
        switch (self.animation) {
            case 1:
            {
                [self.image setAlpha:0.5];
                break;
            }
            case 2:
            {
                [self.image setVerticalAlignment:WKInterfaceObjectVerticalAlignmentTop];
                [self.image setHorizontalAlignment:WKInterfaceObjectHorizontalAlignmentRight];
                break;
            }
            case 3:
            {
                [self.image setRelativeWidth:0.1 withAdjustment:0];
                [self.image setRelativeHeight:0.1 withAdjustment:0];
                break;
            }
            case 4:
            {
                [self.image setWidth:25];
                [self.image setHeight:25];
                break;
            }
            case 5:
            {
                [self.image setTintColor:UIColor.redColor];
                break;
            }
            case 6:
            {
                [self.image setTintColor:nil];
                [self.image setAlpha:1];
                [self.image setVerticalAlignment:WKInterfaceObjectVerticalAlignmentCenter];
                [self.image setHorizontalAlignment:WKInterfaceObjectHorizontalAlignmentCenter];
                [self.image sizeToFitWidth];
                [self.image sizeToFitHeight];
                break;
            }
            case 7:
            {
                [self.image setImageNamed:@"Animation"];
//                [self.image startAnimating];
//                [self.image startAnimatingWithImagesInRange:NSMakeRange(0, 23) duration:3 repeatCount:0];
                // reversed
                [self.image startAnimatingWithImagesInRange:NSMakeRange(0, 23) duration:-3 repeatCount:0];
                break;
            }
            default:
            {
                self.animation = 1;
                [self animateTapped];
                break;
            }
        }
        
        self.animation += 1;
    }];
}

@end



