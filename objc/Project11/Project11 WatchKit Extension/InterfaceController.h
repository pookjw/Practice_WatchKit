//
//  InterfaceController.h
//  Project11 WatchKit Extension
//
//  Created by Jinwoo Kim on 2/1/21.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
//#import "GameScene.h"

@class GameScene;
@interface InterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceSKScene *gameInterface;
@property GameScene *gameScene;
@end
