//
//  InterfaceController.m
//  Project2 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/22/21.
//

#import "InterfaceController.h"

@implementation InterfaceController

- (void)setup {
    self.allMoves = [@[@"rock", @"paper", @"scissors"] mutableCopy];
    self.shouldWin = YES;
    self.level = 1;
}

- (void)awakeWithContext:(id)context {
    [self setup];
    [super awakeWithContext:context];
    
    [self.rock setBackgroundImage:[UIImage imageNamed:@"rock"]];
    [self.paper setBackgroundImage:[UIImage imageNamed:@"paper"]];
    [self.scissors setBackgroundImage:[UIImage imageNamed:@"scissors"]];
    
    [self.timer start];
    [self newLevel];
}

- (void)newLevel {
    if (self.level == 21) {
        [self.result setHidden:NO];
        [self.question setHidden:YES];
        [self.answers setHidden:YES];
        [self.timer stop];
        return;
    }
    
    [self.levelCounter setText:[NSString stringWithFormat:@"%d/20", self.level]];
    BOOL randomBool = arc4random_uniform(2) == 1;
    
    if (randomBool) {
        [self setTitle:@"Win!"];
        self.shouldWin = YES;
    } else {
        [self setTitle:@"Lose!"];
        self.shouldWin = NO;
    }
    
    [self.allMoves shuffle];
    [self.question setImage:[UIImage imageNamed:self.allMoves[0]]];
}

- (void)checkFor:(NSString *)answer {
    if ([self.allMoves[0] isEqual:answer]) {
        self.level += 1;
        [self newLevel];
    } else {
        self.level -= 1;
        if (self.level < 1) self.level = 1;
        [self newLevel];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
}

- (IBAction)rockTapped {
    if (self.shouldWin) {
        [self checkFor:@"scissors"];
    } else {
        [self checkFor:@"paper"];
    }
}

- (IBAction)paperTapped {
    if (self.shouldWin) {
        [self checkFor:@"rock"];
    } else {
        [self checkFor:@"scissors"];
    }
}

- (IBAction)scissorsTapped {
    if (self.shouldWin) {
        [self checkFor:@"paper"];
    } else {
        [self checkFor:@"rock"];
    }
}


@end



