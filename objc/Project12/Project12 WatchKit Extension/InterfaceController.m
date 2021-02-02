//
//  InterfaceController.m
//  Project12 WatchKit Extension
//
//  Created by Jinwoo Kim on 2/2/21.
//

#import "InterfaceController.h"

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    if ([WCSession isSupported]) {
        WCSession *session = WCSession.defaultSession;
        session.delegate = self;
        [session activateSession];
    }
}

/// 0번
- (IBAction)sendMessageTapped {
    WCSession *session = WCSession.defaultSession;
    
    if (session.activationState == WCSessionActivationStateActivated) {
        NSDictionary<NSString *, NSString *> *data = @{@"text": @"Hello from the watch"};
        [session transferUserInfo:data];
    }
}

#pragma mark - WCSessionDelegate

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error {

}

/// 1번, 6번
- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = userInfo[@"text"];
        NSString *number = userInfo[@"number"];
        if (text) {
            [self.receivedData setText:text];
        } else if (number) {
            [NSUserDefaults.standardUserDefaults setValue:number forKey:@"complication_number"];
            
            CLKComplicationServer *server = CLKComplicationServer.sharedInstance;
            NSArray<CLKComplication *> *complications = server.activeComplications;
            if (complications == nil) return;
            
            for (CLKComplication *complication in complications) {
                [server reloadTimelineForComplication:complication];
            }
        }
    });
}

/// 2번
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = message[@"text"];
        if (text) [self.receivedData setText:text];
    });
}

/// 3번
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *text = message[@"text"];
        if (text) {
            // use our message data locally
            [self.receivedData setText:text];
            
            // send back our reply
            replyHandler(@{@"response": @"Be excellent to each other"});
        }
    });
}

/// 4번
- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    NSLog(@"Application state received!");
    NSLog(@"%@", applicationContext);
}

/// 5번
- (void)session:(WCSession *)session didReceiveFile:(WCSessionFile *)file {
    NSLog(@"File received!");
    
    // create a URL representing where to save the file
    NSFileManager *fm = NSFileManager.defaultManager;
    NSURL *destURL = [getDocumentsDirectory() URLByAppendingPathComponent:@"saved_file"];
    
    if ([fm fileExistsAtPath:destURL.relativeString]) {
        // the file already exists - delete it!
        NSError *error1 = nil;
        [fm removeItemAtURL:destURL error:&error1];
        if (error1) {
            NSLog(@"File copy failed");
            return;
        }
    }
    
    // copy the file from its temporary location
    NSError *error2 = nil;
    [fm copyItemAtURL:file.fileURL toURL:destURL error:&error2];
    if (error2) {
        NSLog(@"File copy failed");
        return;
    }
    
    // load the file and print it out
    NSError *error3 = nil;
    NSString *contents = [NSString stringWithContentsOfURL:destURL encoding:NSUTF8StringEncoding error:&error3];
    if (error3) {
        NSLog(@"File copy failed");
        return;
    }
    
    NSLog(@"%@", contents);
}

@end



