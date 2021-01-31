//
//  GameScene.h
//  Project11 WatchKit Extension
//
//  Created by Jinwoo Kim on 2/1/21.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "InterfaceController.h"

@interface GameScene : SKScene <WKCrownDelegate, SKPhysicsContactDelegate>
@property SKNode *player;
@property SKSpriteNode *leftEdge;
@property SKSpriteNode *rightEdge;
@property SKSpriteNode *topEdge;
@property SKSpriteNode *bottomEdge;
@property BOOL isPlayerAlive;
@property NSArray<NSString *> *colorNames;
@property NSArray<UIColor *> *colorValues;
@property double alertDelay;
@property double moveSpeed;
@property double createDelay;
@property (weak) InterfaceController *parentInterfaceController;
@property (nonatomic) NSUInteger score;
@end

