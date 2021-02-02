//
//  ViewController.m
//  Project12
//
//  Created by Jinwoo Kim on 2/2/21.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *complication = [[UIBarButtonItem alloc] initWithTitle:@"Complication"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(sendComplicationTapped)];
    UIBarButtonItem *message = [[UIBarButtonItem alloc] initWithTitle:@"Message"
                                                                style:UIBarButtonItemStylePlain
                                                                target:self
                                                               action:@selector(sendMessageTapped)];
    UIBarButtonItem *appInfo = [[UIBarButtonItem alloc] initWithTitle:@"Context"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector((sendAppContextTapped))];
    UIBarButtonItem *file = [[UIBarButtonItem alloc] initWithTitle:@"File"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(sendFileTapped)];
    self.navigationItem.leftBarButtonItems = @[complication, message, appInfo, file];
    
    if ([WCSession isSupported]) {
        WCSession *session = WCSession.defaultSession;
        session.delegate = self;
        [session activateSession];
    }
}

- (void)sendMessageTapped {
    WCSession *session = WCSession.defaultSession;
    
    /// 1번
    if (session.activationState == WCSessionActivationStateActivated) {
        NSDictionary<NSString *, NSString *> *data = @{@"text": @"User info from the phone"};
        [session transferUserInfo:data];
    }
    
    /// isReachable : A Boolean value indicating whether the counterpart app is available for live messaging.
    
    /// 2번
    if (session.isReachable) {
        NSDictionary<NSString *, NSString *> *data = @{@"text": @"A message from phone"};
        [session sendMessage:data replyHandler:nil errorHandler:nil];
    }
    
    /// 3번
    if (session.isReachable) {
        NSDictionary<NSString *, NSString *> *data = @{@"text": @"A message from phone"};
        [session sendMessage:data
                replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.receivedData.text = [NSString stringWithFormat:@"Received response: %@", replyMessage];
            });
        }
                errorHandler:nil];
    }
}

- (void)sendAppContextTapped {
    WCSession *session = WCSession.defaultSession;
    
    /// 4번
    /*
     context 전송
     - 전송이 반드시 보장된다. 당장은 아니더라도, 언젠가. Watch 쪽에서 앱이 종료된 상태에 전송되어도, 앱이 실행될 때 전송된다.
     - 실패할 경우 error handling이 가능하다.
     - 이전에 보낸 내용들이 replace 된다. 만약 서로 다른 내용의 A, B, C를 보내면, C만 보내진다.
     - reachable이 아니여도 작동한다.
     */
    if (session.activationState == WCSessionActivationStateActivated) {
        NSDictionary<NSString *, NSString *> *data = @{@"text": [NSString stringWithFormat:@"Hello from the phone %@", [NSDate new]]};
        
        NSError *error = nil;
        [session updateApplicationContext:data error:&error];
        if (error) NSLog(@"%@", error.localizedDescription);
    }
}

- (void)sendComplicationTapped {
    WCSession *session = WCSession.defaultSession;
    
    /// 6번
    // check that we are good to send
    if ((session.activationState == WCSessionActivationStateActivated) && (session.isComplicationEnabled)) {
        // pick a random number and wrap it in a dictionary
        NSUInteger randomNumber = arc4random_uniform(10);
        NSDictionary<NSString *, NSString *> *message = @{@"number": [NSString stringWithFormat:@"%lu", randomNumber]};
        
        // transfer it across using a high-priority send
        [session transferCurrentComplicationUserInfo:message];
        
        // output how many high-priority sends we have left
        NSLog(@"%@", [NSString stringWithFormat:@"Attempted so send complication data. Remaining transfers: %lu", session.remainingComplicationUserInfoTransfers]);
    }
}

- (void)sendFileTapped {
    WCSession *session = WCSession.defaultSession;
    
    /// 5번
    if (session.activationState == WCSessionActivationStateActivated) {
        // create a URL for where the file is/will be saved
        NSFileManager *fm = NSFileManager.defaultManager;
        NSURL *sourceURL = [getDocumentsDirectory() URLByAppendingPathComponent:@"saved_file"];
        
        if (![fm fileExistsAtPath:sourceURL.relativeString]) {
            // the file doesn't exist - create it now
            NSError *error = nil;
            [@"Hello, form a phone file!" writeToURL:sourceURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (error) NSLog(@"%@", error.localizedDescription);
        }
        
        // the file exists now; send it across the session
        [session transferFile:sourceURL metadata:nil];
    }
}

#pragma mark - WCSessionDelegate

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (activationState == WCSessionActivationStateActivated) {
            if ([session isWatchAppInstalled]) {
                self.receivedData.text = @"Watch app is installed!";
            }
        }
    });
}

/// 0번
- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = userInfo[@"text"];
        if (text) self.receivedData.text = text;
    });
}

- (void)sessionDidBecomeInactive:(WCSession *)session {
    
}

- (void)sessionDidDeactivate:(WCSession *)session {
    
}

@end
