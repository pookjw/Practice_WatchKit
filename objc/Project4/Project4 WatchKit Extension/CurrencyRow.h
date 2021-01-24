//
//  CurrencyRow.h
//  Project4 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/24/21.
//

#import <WatchKit/WatchKit.h>

@interface CurrencyRow : NSObject
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *group;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *textLabel;
@end
