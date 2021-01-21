//
//  DetailInterfaceController.m
//  Project1 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/22/21.
//

#import "DetailInterfaceController.h"

@implementation DetailInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSDictionary<NSString *, NSString *> *contextDictionary = context;
    if (context == nil) return;
    
    [self.textLabel setText:contextDictionary[@"note"]];
    NSString *index = contextDictionary[@"index"];
    [self setTitle:[NSString stringWithFormat:@"Note %@", index]];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



