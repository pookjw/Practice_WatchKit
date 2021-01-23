//
//  InterfaceController.m
//  Project3 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/23/21.
//

#import "InterfaceController.h"


@interface InterfaceController ()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self testUserDefaults];
    [self testUserDefaults];
    [self testKeychain];
    [self testKeychain];
    [self testFile];
    [self testFile];
}

- (void)testUserDefaults {
    // get hold of our app's user defaults
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSString *contents = [defaults stringForKey:@"shared_default"];
    
    if (contents) {
        // save data was found!
        NSLog(@"Reading from defaults");
        NSLog(@"%@", contents);
    } else {
        // no saved data - create it!
        NSLog(@"Writing to defaults");
        [defaults setObject:@"This is the saved default" forKey:@"shared_default"];
    }
}

- (void)testKeychain {
    // TODO
}

- (NSURL *)getDocumentsDirectory {
    NSArray<NSURL *> *paths = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return paths[0];
}

- (void)testFile {
    NSURL *savedURL = [[self getDocumentsDirectory] URLByAppendingPathComponent:@"shared_file"];
    NSString *contents = [NSString stringWithContentsOfURL:savedURL encoding:NSUTF8StringEncoding error:nil];
    
    if (contents) {
        NSLog(@"Reading from file");
        NSLog(@"%@", contents);
    } else {
        NSLog(@"Writing to file");
        [@"This is the saved file" writeToURL:savedURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

@end



