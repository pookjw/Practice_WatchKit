//
//  InterfaceController.h
//  Project9 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/27/21.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceImage *image;
@property NSUInteger animation;
@end
