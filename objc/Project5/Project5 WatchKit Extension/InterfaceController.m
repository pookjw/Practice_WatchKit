//
//  InterfaceController.m
//  Project5 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/25/21.
//

#import "InterfaceController.h"

@implementation InterfaceController

- (void)setup {
    self.buttons = [@[] mutableCopy];
    self.startTime = [NSDate new];
    self.colors = @{
        @"Red": UIColor.redColor,
        @"Green": [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1],
        @"Blue": UIColor.blueColor,
        @"Orange": UIColor.orangeColor,
        @"Purple": UIColor.purpleColor,
        @"Black": UIColor.blackColor
    };
    self.currentLevel = 0;
}

- (void)awakeWithContext:(id)context {
    [self setup];
    [super awakeWithContext:context];
    [self.buttons addObjectsFromArray:@[self.tlButton, self.trButton, self.blButton, self.brButton]];
    [self startNewGame];
    [self setPlayReminder];
}

- (void)levelUp {
    self.currentLevel += 1;
    
    if (self.currentLevel == 10) {
        WKAlertAction *playAgain = [WKAlertAction actionWithTitle:@"Play Again"
                                                            style:WKAlertActionStyleDefault
                                                          handler:^(){ [self startNewGame]; }];
        
        NSTimeInterval timePasssed = [[NSDate new] timeIntervalSinceDate:self.startTime];
        [self presentAlertControllerWithTitle:@"You win!"
                                      message:[NSString stringWithFormat:@"You finished in %d", (NSInteger)round(timePasssed)]
                               preferredStyle:WKAlertControllerStyleAlert
                                      actions:@[playAgain]];
        return;
    }
    
    // pull out the color names and shuffle them with the buttons
    NSMutableArray<NSString *> *colorKeys = [self.colors.allKeys mutableCopy];
    [colorKeys shuffle];
    [self.buttons shuffle];
    
    // loop over all the buttons
    [self.buttons enumerateObjectsUsingBlock:^(WKInterfaceButton * _Nonnull button, NSUInteger idx, BOOL * _Nonnull stop){
        // give them a color from the `color` dictionary
        [button setBackgroundColor:self.colors[colorKeys[idx]]];
        
        // make sure they are enabled
        [button setEnabled:YES];
        
        if (idx == 0) {
            // this should have the wrong title
            [button setTitle:colorKeys[colorKeys.count - 1]];
        } else {
            // this should have the correct title
            [button setTitle:colorKeys[idx]];
        }
    }];
}

- (void)buttonTapped:(WKInterfaceButton *)button {
    if (button == self.buttons[0]) {
        // correct buttom!
        [self levelUp];
    } else {
        // wrong - make them try again
        [button setEnabled:NO];
    }
}

- (IBAction)startNewGame {
    self.startTime = [NSDate new];
    self.currentLevel = 0;
    [self levelUp];
}

- (IBAction)tlButtonTapped {
    [self buttonTapped:self.tlButton];
}

- (IBAction)trButtonTapped {
    [self buttonTapped:self.trButton];
}

- (IBAction)blButtonTapped {
    [self buttonTapped:self.blButton];
}

- (IBAction)brButtonTapped {
    [self buttonTapped:self.brButton];
}

- (void)createNotification {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"We miss you!";
    content.body = @"Come back and play the game some more!";
    content.categoryIdentifier = @"play_reminder";
    content.sound = [UNNotificationSound defaultSound];
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSUUID new].UUIDString
                                                                          content:content
                                                                          trigger:trigger];
    [center addNotificationRequest:request withCompletionHandler:nil];
}

- (void)setPlayReminder {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound
                          completionHandler:^(BOOL granted, NSError * _Nullable error){
        [center removeAllDeliveredNotifications];
        [self createNotification];
        [self registerCategories];
    }];
}

- (void)registerCategories {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNNotificationAction *play = [UNNotificationAction actionWithIdentifier:@"play"
                                                                      title:@"Play Now"
                                                                    options:UNNotificationActionOptionForeground];
    
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"play_reminder"
                                                                              actions:@[play]
                                                                    intentIdentifiers:@[]
                                                                              options:0];
    
    [center setNotificationCategories:[NSSet setWithArray:@[category]]];
}

@end



