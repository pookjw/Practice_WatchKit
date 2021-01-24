//
//  InterfaceController.h
//  Project5 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/25/21.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import "NSMutableArray+Shuffling.h"

@interface InterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceButton *tlButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *blButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *trButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *brButton;
@property NSMutableArray<WKInterfaceButton *> *buttons;
@property NSDate *startTime;
@property NSDictionary<NSString *, UIColor *> *colors;
@property NSUInteger currentLevel;
@end
