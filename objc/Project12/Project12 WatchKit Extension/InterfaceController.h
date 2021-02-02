//
//  InterfaceController.h
//  Project12 WatchKit Extension
//
//  Created by Jinwoo Kim on 2/2/21.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import <ClockKit/ClockKit.h>
#import "SharedCode.h"

@interface InterfaceController : WKInterfaceController <WCSessionDelegate>
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *receivedData;
@end
