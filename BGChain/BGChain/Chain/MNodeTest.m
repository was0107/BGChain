//
//  MNodeTest.m
//  test
//
//  Created by Micker on 2020/3/20.
//  Copyright © 2020 Micker. All rights reserved.
//

#import "MNodeTest.h"

@implementation MNodeTest

- (void) execute {
    !self.block?:self.block(self);
    NSLog(@"delay 3s:%@", self);
    self.nextStep = 1;
    [self performSelector:@selector(exeNextNode) withObject:nil afterDelay:3];
}
@end

@implementation MNodeTest1

- (void) execute {
    !self.block?:self.block(self);
    NSLog(@"exe:%@", self);
    [self exeNextNode];
}

@end
