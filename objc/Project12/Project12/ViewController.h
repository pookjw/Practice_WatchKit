//
//  ViewController.h
//  Project12
//
//  Created by Jinwoo Kim on 2/2/21.
//

#import <UIKit/UIKit.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "SharedCode.h"

@interface ViewController : UIViewController <WCSessionDelegate>
@property (weak, nonatomic) IBOutlet UITextView *receivedData;
@end

