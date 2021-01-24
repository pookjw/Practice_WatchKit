//
//  ResultsInterfaceController.m
//  Project4 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/24/21.
//

#import "ResultsInterfaceController.h"

@implementation ResultsInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSDictionary<NSString *, NSString *> *settings = context;
    if (settings == nil) return;
    NSString *amount = settings[@"amount"];
    if (amount == nil) return;
    NSString *baseCurrency = settings[@"base"];
    if (baseCurrency == nil) return;
    
    self.amountToConvert = [amount floatValue];
    [self setTitle:[NSString stringWithFormat:@"%@ %@", amount, baseCurrency]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchDataFor:baseCurrency];
    });
}

- (void)willActivate {
    [super willActivate];
    [WKExtension.sharedExtension setAutorotating:YES];
}

- (void)didDeactivate {
    [super didDeactivate];
    [WKExtension.sharedExtension setAutorotating:NO];
}

- (IBAction)doneTapped {
    [WKInterfaceController reloadRootPageControllersWithNames:@[@"Home", @"Currencies"]
                                                     contexts:nil
                                                  orientation:WKPageOrientationHorizontal
                                                    pageIndex:0];
}

- (void)fetchDataFor:(NSString *)baseCurrency {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://openexchangerates.org/api/latest.json?app_id=%@&base=%@", appID, baseCurrency]];
    if (url) {
        NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
        
        [[NSURLSession.sharedSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
            if (data) {
                [self parse:data];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.status setText:@"Fetch failed"];
                    [self.done setHidden:NO];
                });
            }
        }] resume];
    } else {
        [self.status setText:@"Fetch failed"];
        [self.done setHidden:NO];
    }
}

- (void)parse:(NSData *)contents {
    NSError * _Nullable jsonError = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:contents options:0 error:&jsonError];
    if ((jsonError != nil) || (dic == nil)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.status setText:@"Fetch failed"];
            [self.done setHidden:NO];
        });
        return;
    }
    
    // load their currency selection
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSArray *selectedCurrencies = [defaults arrayForKey:[InterfaceController selectedCurrenciesKey]];
    if (selectedCurrencies == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.status setText:@"Fetch failed"];
            [self.done setHidden:NO];
        });
        return;
    }
    
    NSDictionary<NSString *, NSNumber *> *rates = dic[@"rates"];
    if (rates == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.status setText:@"Fetch failed"];
            [self.done setHidden:NO];
        });
        return;
    }
    
    NSMutableDictionary<NSString *, NSNumber *> *fetched = [@{} mutableCopy];
    [rates enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull currency, NSNumber * _Nonnull rate, BOOL * _Nonnull stop){
        // only include currencies the user wants
        if (![selectedCurrencies containsString:currency]) return;
        [fetched addEntriesFromDictionary:@{currency: rate}];
    }];
    self.fetchedCurrencies = fetched;
    
    [self updateTable];
    [self.status setHidden:YES];
    [self.table setHidden:NO];
    [self.done setHidden:NO];
}

- (void)updateTable {
    // load as many rows as we have currencies
    [self.table setNumberOfRows:self.fetchedCurrencies.count withRowType:@"Row"];
    
    // loop over each cuurency, getting its position and symbol
    NSUInteger __block index = 0;
    [self.fetchedCurrencies enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull currency, NSNumber * _Nonnull rate, BOOL * _Nonnull stop){
        // find the row at that position
        CurrencyRow *row = [self.table rowControllerAtIndex:index];
        if (row == nil) *stop = YES;
        
        // multiply the rate by the user's input amount
        float value = self.amountToConvert * [rate floatValue];
        
        // convert it to a rounded string
        NSString *formattedValue = [NSString stringWithFormat:@"%.2f", value];
        
        // show it in the label
        [row.textLabel setText:[NSString stringWithFormat:@"%@ %@", formattedValue, currency]];
        index += 1;
    }];
}

@end



