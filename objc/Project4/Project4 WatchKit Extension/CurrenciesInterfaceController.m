//
//  CurrenciesInterfaceController.m
//  Project4 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/24/21.
//

#import "CurrenciesInterfaceController.h"
@implementation CurrenciesInterfaceController

- (void)setup {
    self.selectedColor = [UIColor colorWithRed:0 green:0.55 blue:0.25 alpha:1];
    self.deselectedColor = [UIColor colorWithRed:0.3 green:0 blue:0 alpha:1];
}

- (void)awakeWithContext:(id)context {
    [self setup];
    [super awakeWithContext:context];
    
    // Set up as many rows as we have currencies
    [self.table setNumberOfRows:[InterfaceController currencies].count withRowType:@"Row"];
    
    // load the list of selected currencies, or use the default list
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSArray<NSString *> *selectedCurrencies = [defaults arrayForKey:[InterfaceController selectedCurrenciesKey]];
    if (selectedCurrencies == nil) selectedCurrencies = [InterfaceController defaultCurrencies];
    
    // loop over all the currencies, configuring the table rows
    [[InterfaceController currencies] enumerateObjectsUsingBlock:^(NSString * _Nonnull currency, NSUInteger index, BOOL * _Nonnull stop){
        CurrencyRow *row = [self.table rowControllerAtIndex:index];
        if (row == nil) return;
        
        [row.textLabel setText:currency];
        
        // color the row's group depending on whether it's selected
        if ([selectedCurrencies containsObject:currency]) {
            [row.group setBackgroundColor:self.selectedColor];
        } else {
            [row.group setBackgroundColor:self.deselectedColor];
        }
    }];
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    // 1: grab the row controller and safely typecast
    CurrencyRow *row = [table rowControllerAtIndex:rowIndex];
    if (row == nil) return;
    
    // 2: pull out the current list of selected currencies, or use the default list
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSMutableArray *selectedCurrencies = [[defaults arrayForKey:[InterfaceController selectedCurrenciesKey]] mutableCopy];
    if (selectedCurrencies == nil) selectedCurrencies = [[InterfaceController defaultCurrencies] mutableCopy];
    
    // 3: find the name of the tapped currency
    NSString *selectedCurrency = [InterfaceController currencies][rowIndex];
    
    // 4: if that currency was found in our selected currencies, remove it
    if ([selectedCurrencies containsString:selectedCurrency]) {
        [selectedCurrencies removeObject:selectedCurrency];
        [row.group setBackgroundColor:self.deselectedColor];
    } else {
        // 5: otherwise add it
        [selectedCurrencies addObject:selectedCurrency];
        [row.group setBackgroundColor:self.selectedColor];
    }
    
    // 6: save the new selected currencies
    [defaults setObject:selectedCurrencies forKey:[InterfaceController selectedCurrenciesKey]];
}

@end
