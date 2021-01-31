//
//  InterfaceController.m
//  Project11 WatchKit Extension
//
//  Created by Jinwoo Kim on 2/1/21.
//

#import "InterfaceController.h"
#import "GameScene.h"

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self startGame:self];
}

- (void)didAppear {
    [super didAppear];
    [self.crownSequencer focus];
}

- (IBAction)startGame:(id)sender {
    if ((self.gameScene) && (self.gameScene.isPlayerAlive)) return;
    
    self.gameScene = [GameScene sceneWithSize:CGSizeMake(self.contentFrame.size.width, self.contentFrame.size.height)];
    self.gameScene.parentInterfaceController = self;
    self.gameScene.anchorPoint = CGPointMake(0.5, 0.5);
    
    SKTransition *transition = [SKTransition doorwayWithDuration:1];
    self.crownSequencer.delegate = self.gameScene;
    [self.gameInterface presentScene:self.gameScene transition:transition];
}

@end



