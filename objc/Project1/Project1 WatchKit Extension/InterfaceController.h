//
//  InterfaceController.h
//  Project1 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/21/21.
//

#import <WatchKit/WatchKit.h>
#import "NoteSelectRow.h"

@interface InterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@property NSMutableArray<NSString *>* notes;
@property NSURL *savePath;
@end
