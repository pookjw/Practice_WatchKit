//
//  InterfaceController.m
//  Project1 WatchKit Extension
//
//  Created by Jinwoo Kim on 1/21/21.
//

#import "InterfaceController.h"

@implementation InterfaceController

- (void)setup {
    self.notes = [@[] mutableCopy];
    self.savePath = [InterfaceController getDocumentsDirectory];
}

- (void)awakeWithContext:(id)context {
    [self setup];
    [super awakeWithContext:context];
    
    //
    
    NSData *data = [NSData dataWithContentsOfURL:self.savePath];
    if (data) {
        NSMutableArray<NSString *> *notes  = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSMutableArray<NSString *> self]
                                                                               fromData:data
                                                                                  error:nil];
        if (notes) {
            self.notes = notes;
        }
    }
    
    [self.table setNumberOfRows:self.notes.count withRowType:@"Row"];
    
    [self.notes enumerateObjectsUsingBlock:^(NSString * _Nonnull note, NSUInteger rowIndex, BOOL * _Nonnull stop){
        [self setRow:rowIndex to:note];
    }];
}

- (void)setRow:(NSUInteger)rowIndex to:(NSString *)text {
    NoteSelectRow *row = (NoteSelectRow *)[self.table rowControllerAtIndex:rowIndex];
    if (row) [row.textLabel setText:text];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
}

- (IBAction)addNewNote {
    // 1. request user input
    [self presentTextInputControllerWithSuggestions:nil allowedInputMode:WKTextInputModePlain completion:^(NSArray * _Nullable results){
        // 2. convert the returned item to a string if possible, otherwise bail out
        NSString *result = (NSString *)[results firstObject];
        if (result == nil) return;
        
        // 3. insert a new row at the end of our table
        NSIndexSet *index = [NSIndexSet indexSetWithIndex:self.notes.count];
        [self.table insertRowsAtIndexes:index withRowType:@"Row"];
        
        // 4. give our new row the correct text
        [self setRow:self.notes.count to:result];
        
        // 5. append the new note to our array
        [self.notes addObject:result];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.notes requiringSecureCoding:NO error:nil];
        [data writeToFile:self.savePath.absoluteString atomically:YES];
    }];
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    return @{@"index": [NSString stringWithFormat:@"%lu", rowIndex + 1],
             @"note": self.notes[rowIndex]};
}

+ (NSURL *)getDocumentsDirectory {
    NSArray<NSURL *> *paths = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return paths[0];
}

@end



