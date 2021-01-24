//
//  InterfaceController.m
//  Project4 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/24/21.
//

#import "InterfaceController.h"

@implementation InterfaceController

+ (NSArray<NSString *> *)currencies {
    static NSArray<NSString *> *currencies = nil;
    if (currencies == nil) {
        currencies = @[@"USD", @"AUD", @"CAD", @"CHF", @"CNY", @"EUR", @"GBP", @"HKD", @"JPY", @"SGD"];
    }
    return currencies;
}

+ (NSArray<NSString *> *)defaultCurrencies {
    static NSArray<NSString *> *defaultCurrencies = nil;
    if (defaultCurrencies == nil) {
        defaultCurrencies = @[@"USD", @"EUR"];
    }
    return defaultCurrencies;
}

+ (NSString *)selectedCurrenciesKey {
    static NSString *selectedCurrenciesKey = nil;
    if (selectedCurrenciesKey == nil) {
        selectedCurrenciesKey = @"SelectedCurrencies";
    }
    return selectedCurrenciesKey;
}

- (void)awakeWithContext:(id)context {
    [self setup];
    [super awakeWithContext:context];
    
    NSMutableArray<WKPickerItem *> *items = [@[] mutableCopy];
    
    for (NSString *currency in [[self class] currencies]) {
        WKPickerItem *item = [WKPickerItem new];
        item.title = currency;
        [items addObject:item];
    }
    
    [self.currencyPicker setItems:items];
}

- (void)setup {
    self.currentCurrency = @"USD";
    self.currentAmount = 500;
}

- (IBAction)amountChanged:(float)value {
    self.currentAmount = (int)value;
    [self.amountLabel setText:[NSString stringWithFormat:@"%d", self.currentAmount]];
}

- (IBAction)convertTapped {
    NSDictionary<NSString *, NSString *> *context = @{@"amount": [NSString stringWithFormat:@"%d", self.currentAmount],
                              @"base": self.currentCurrency};
    [WKInterfaceController reloadRootPageControllersWithNames:@[@"Results"]
                                                     contexts:@[context]
                                                  orientation:WKPageOrientationHorizontal
                                                    pageIndex:0];
}

- (IBAction)baseCurrencyChanged:(NSInteger)value {
    self.currentCurrency = [[self class] currencies][value];
}

@end



