//
//  CurrenciesInterfaceController.h
//  Project4 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/24/21.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "InterfaceController.h"
#import "CurrencyRow.h"
#import "NSMutableArray+containsString.h"

@interface CurrenciesInterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@property UIColor *selectedColor;
@property UIColor *deselectedColor;
@end
