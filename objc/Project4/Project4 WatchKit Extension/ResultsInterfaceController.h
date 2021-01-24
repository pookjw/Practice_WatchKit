//
//  ResultsInterfaceController.h
//  Project4 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/24/21.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "InterfaceController.h"
#import "CurrencyRow.h"
#import "NSArray+containsString.h"
#define appID @"051bce45cd804955bfdfedbab80dd347"

@interface ResultsInterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *status;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *done;
@property NSDictionary<NSString *, NSNumber *> *fetchedCurrencies;
@property float amountToConvert;
@end
