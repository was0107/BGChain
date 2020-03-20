//
//  BGChanin+Delay.m
//  test
//
//  Created by Micker on 2020/3/20.
//  Copyright © 2020 Micker. All rights reserved.
//

#import "BGChanin+Delay.h"
#import "MNodeTest.h"

@implementation BGChanin (Delay)

- (void) registerChain_Delay {
    [self registerChain: [BGNode node:@"test111"
                                group:@"pop"
                                index:20
                          handleBlock:^(BGNode *node)
    {
        NSLog(@"delay 2s :%@", node);
        [node performSelector:@selector(exeNextNode) withObject:nil afterDelay:2];

    }]];
    
    
    [self registerChain: [MNodeTest1 node:@"MNodeTest111"
                                    group:@"pop"
                                    index:200
                              handleBlock:^(BGNode *node)
    {
        NSLog(@"delay MNodeTest1 2s  :%@", node);
        [node performSelector:@selector(exeNextNode) withObject:nil afterDelay:2];

    }]];
}

@end
