//
//  InterfaceController.h
//  Project4 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/24/21.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *amountLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceSlider *amountSlider;
@property (weak, nonatomic) IBOutlet WKInterfacePicker *currencyPicker;
@property NSString *currentCurrency;
@property NSUInteger currentAmount;

+ (NSArray<NSString *> *)currencies;
+ (NSArray<NSString *> *)defaultCurrencies;
+ (NSString *)selectedCurrenciesKey;
@end
