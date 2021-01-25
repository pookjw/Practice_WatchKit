//
//  InterfaceController.m
//  Project6 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/26/21.
//

#import "InterfaceController.h"

@implementation InterfaceController

- (NSURL *)getDocumentsDirectory {
    NSArray<NSURL *> *paths = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return paths[0];
}

- (IBAction)dictateTapped {
    [self presentTextInputControllerWithSuggestions:nil
                                   allowedInputMode:WKTextInputModePlain
                                         completion:^(NSArray * _Nullable results){
        NSString * _Nullable result = [results firstObject];
        if (result) NSLog(@"%@", result);
    }];
}

- (IBAction)multiInputTapped {
    [self presentTextInputControllerWithSuggestions:@[@"Hacking with Swift", @"Hacking with macOS", @"Server-Side Swift"]
                                   allowedInputMode:WKTextInputModeAllowEmoji
                                         completion:^(NSArray * _Nullable results){
        NSString * _Nullable result = [results firstObject];
        if (result) NSLog(@"%@", result);
    }];
}

- (IBAction)recordingTapped {
    // set where we'll read and save from
    NSURL *saveURL = [[self getDocumentsDirectory] URLByAppendingPathComponent:@"recording.wav"];
    
    if ([NSFileManager.defaultManager fileExistsAtPath:saveURL.path]) {
        // if we have a recording already, play it
        NSDictionary<NSString *, id> *options = @{WKMediaPlayerControllerOptionsAutoplayKey: @YES};
        
        [self presentMediaPlayerControllerWithURL:saveURL
                                          options:options
                                       completion:^(BOOL didPlayToEnd, NSTimeInterval endTime, NSError * _Nullable error){
            // do nothing here
        }];
    } else {
        // we don't have a recording; make one
        NSDictionary<NSString *, id> *options = @{
            WKAudioRecorderControllerOptionsMaximumDurationKey: @60,
            WKAudioRecorderControllerOptionsActionTitleKey: @"Done"
        };
        
        [self presentAudioRecorderControllerWithOutputURL:saveURL
                                                   preset:WKAudioRecorderPresetNarrowBandSpeech
                                                  options:options
                                               completion:^(BOOL success, NSError * _Nullable error){
            if (success) {
                NSLog(@"Saved successfully!");
            } else {
                NSString *str = (error.localizedDescription == nil) ? @"Unknown error" : error.localizedDescription;
                NSLog(@"%@", str);
            }
        }];
    }
}

@end



