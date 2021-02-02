//
//  SharedCode.m
//  Project12
//
//  Created by Jinwoo Kim on 2/3/21.
//

#import "SharedCode.h"

NSURL * getDocumentsDirectory(void) {
    NSArray<NSURL *> *paths = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    return paths[0];
}
