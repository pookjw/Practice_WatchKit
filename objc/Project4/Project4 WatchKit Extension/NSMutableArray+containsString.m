//
//  NSMutableArray+containsString.m
//  Project4 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/24/21.
//

#import "NSMutableArray+containsString.h"

@implementation NSMutableArray (containsString)
- (BOOL)containsString:(NSString *)comparision {
    BOOL __block result = NO;
    [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop){
        NSString *str = (NSString *)obj;
        if (str == nil) return;
        if ([str isEqualToString:comparision]) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}
@end
