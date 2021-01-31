//
//  GameScene.m
//  Project11 WatchKit Extension
//
//  Created by Jinwoo Kim on 2/1/21.
//

#import "GameScene.h"

@implementation GameScene

- (void)setup {
    self.player = [SKNode new];
    self.isPlayerAlive = YES;
    self.colorNames = @[@"Red", @"Blue", @"Green", @"Yellow"];
    self.colorValues = @[UIColor.redColor, UIColor.blueColor, UIColor.greenColor, UIColor.yellowColor];
    self.alertDelay = 1.0;
    self.moveSpeed = 70.0;
    self.createDelay = 0.5;
    self.score = 0;
}

- (void)setScore:(NSUInteger)score {
    _score = score;
    [self.parentInterfaceController setTitle:[NSString stringWithFormat:@"Score: %lu", _score]];
}

- (void)sceneDidLoad {
    [self setup];
    [super sceneDidLoad];
    self.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    
    SKSpriteNode *red = [self createPlayerWithColor:@"Red"];
    red.position = CGPointMake(-8, 8);
    
    SKSpriteNode *blue = [self createPlayerWithColor:@"Blue"];
    blue.position = CGPointMake(8, 8);
    
    SKSpriteNode *green = [self createPlayerWithColor:@"Green"];
    green.position = CGPointMake(-8, -8);
    
    SKSpriteNode *yellow = [self createPlayerWithColor:@"Yellow"];
    yellow.position = CGPointMake(8, -8);
    
    [self addChild:self.player];
    
    self.leftEdge = [SKSpriteNode spriteNodeWithColor:UIColor.whiteColor size:CGSizeMake(10, self.size.height)];
    self.rightEdge = [SKSpriteNode spriteNodeWithColor:UIColor.whiteColor size:CGSizeMake(10, self.size.height)];
    self.topEdge = [SKSpriteNode spriteNodeWithColor:UIColor.whiteColor size:CGSizeMake(self.size.width, 10)];
    self.bottomEdge = [SKSpriteNode spriteNodeWithColor:UIColor.whiteColor size:CGSizeMake(self.size.width, 10)];
    
    self.leftEdge.position = CGPointMake((-self.size.width / 2) + 10, 0);
    self.rightEdge.position = CGPointMake((self.size.width / 2) - 10, 0);
    self.topEdge.position = CGPointMake(0, (self.size.height / 2) - 10);
    self.bottomEdge.position = CGPointMake(0, (-self.size.height / 2) + 10);
    
    for (SKSpriteNode *edge in @[self.leftEdge, self.rightEdge, self.topEdge, self.bottomEdge]){
        edge.colorBlendFactor = 1;
        edge.alpha = 0;
        [self addChild:edge];
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, self.createDelay * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [self launchBall];
    });
    
    //
    
    self.physicsWorld.contactDelegate = self;
}

- (SKSpriteNode *)createPlayerWithColor:(NSString *)color {
    SKSpriteNode *component = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"player%@", color]];
    
    component.physicsBody = [SKPhysicsBody bodyWithTexture:component.texture size:component.size];
    [component.physicsBody setDynamic:NO];
    component.name = color;
    [self.player addChild:component];
    
    return component;
}

- (NSDictionary<NSString *, id> *)pickEdge {
    NSUInteger direction = arc4random_uniform(5);
    
    switch (direction) {
        case 0:
            return @{@"position": [NSValue valueWithCGPoint:CGPointMake(-90, 0)],
                     @"force": [NSValue valueWithCGVector:CGVectorMake(self.moveSpeed, 0)],
                     @"edge": self.leftEdge};
            break;
        case 1:
            return @{@"position": [NSValue valueWithCGPoint:CGPointMake(90, 0)],
                     @"force": [NSValue valueWithCGVector:CGVectorMake(-self.moveSpeed, 0)],
                     @"edge": self.rightEdge};
            break;
        case 2:
            return @{@"position": [NSValue valueWithCGPoint:CGPointMake(0, -100)],
                     @"force": [NSValue valueWithCGVector:CGVectorMake(0, self.moveSpeed)],
                     @"edge": self.bottomEdge};
        default:
            return @{@"position": [NSValue valueWithCGPoint:CGPointMake(0, 100)],
                     @"force": [NSValue valueWithCGVector:CGVectorMake(0, -self.moveSpeed)],
                     @"edge": self.topEdge};
            break;
    }
}

- (SKSpriteNode *)createBallWithColor:(NSString *)color {
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"ball%@", color]];
    ball.name = color;
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:12];
    ball.physicsBody.linearDamping = 0;
    ball.physicsBody.affectedByGravity = NO;
    ball.physicsBody.contactTestBitMask = ball.physicsBody.collisionBitMask;
    
    [self addChild:ball];
    return ball;
}

- (void)launchBall {
    // bail out if the game is over
    if (!self.isPlayerAlive) return;
    
    // pick a random ball color
    NSUInteger ballType = arc4random_uniform((unsigned int)self.colorNames.count);
    
    // create a ball from that random color
    SKSpriteNode *ball = [self createBallWithColor:self.colorNames[ballType]];
    
    // get a random edge to launch from, plus position and force to apply
    NSDictionary<NSString *, id> *dic = [self pickEdge];
    CGPoint position = (CGPoint)^{
        NSValue *value = dic[@"position"];
        return [value CGPointValue];
    }();
    CGVector force = (CGVector)^{
        NSValue *value = dic[@"force"];
        return [value CGVectorValue];
    }();
    SKSpriteNode *edge = dic[@"edge"];
    
    // place the ball at its starting position
    ball.position = position;
    
    SKAction *flashEdge = [SKAction runBlock:^{
        edge.color = self.colorValues[ballType];
        edge.alpha = 1;
    }];
    
    SKAction *resetEdge = [SKAction runBlock:^{
        edge.alpha = 0;
    }];
    
    SKAction *launchBall = [SKAction runBlock:^{
        ball.physicsBody.velocity = force;
    }];
    
    SKAction *sequence = [SKAction sequence:@[
        flashEdge,
        [SKAction waitForDuration:self.alertDelay],
        resetEdge,
        launchBall
    ]];
    [self runAction:sequence];
    self.alertDelay *= 0.98;
}

- (void)ball:(SKNode *)ball hit:(SKNode *)color {
    // don't run this more than once
    if (!self.isPlayerAlive) return;
    
    // destroy the ball no matter what
    [ball removeFromParent];
    
    if ([ball.name isEqualToString:color.name]) {
        // player scored a point!
        self.score += 1;
    } else {
        // gave ovet
        self.isPlayerAlive = NO;
        
        SKSpriteNode *gameOver = [SKSpriteNode spriteNodeWithImageNamed:@"gameOver"];
        gameOver.xScale = 2.0;
        gameOver.yScale = 2.0;
        gameOver.alpha = 0;
        [self addChild:gameOver];
        
        SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
        SKAction *scaleDown = [SKAction scaleTo:1 duration:0.5];
        SKAction *group = [SKAction group:@[fadeIn, scaleDown]];
        [gameOver runAction:group];
    }
}

#pragma mark - WKCrownDelegate
- (void)crownDidRotate:(WKCrownSequencer *)crownSequencer rotationalDelta:(double)rotationalDelta {
    self.player.zRotation -= (CGFloat)rotationalDelta * 20;
}

#pragma mark - SKPhysicsContactDelegate
- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKNode *nodeA = (SKNode *)contact.bodyA.node;
    SKNode *nodeB = (SKNode *)contact.bodyB.node;
    if ((nodeA == nil) || (nodeB == nil)) return;
    
    if (nodeA.parent == self) {
        [self ball:nodeA hit:nodeB];
    } else if (nodeB.parent == self) {
        [self ball:nodeB hit:nodeA];
    } else {
        // neither? Just exit!
        return;
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, self.createDelay * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [self launchBall];
    });
}
@end
