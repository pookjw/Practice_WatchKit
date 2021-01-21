//
//  InterfaceController.h
//  Project2 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/22/21.
//

#import <WatchKit/WatchKit.h>
#import "NSMutableArray+Shuffling.h"

@interface InterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *result;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *question;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *answers;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *rock;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *paper;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *scissors;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *levelCounter;
@property (weak, nonatomic) IBOutlet WKInterfaceTimer *timer;
@property NSMutableArray<NSString *> *allMoves;
@property BOOL shouldWin;
@property NSUInteger level;
@end
