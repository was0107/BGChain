//
//  BGChanin.m
//  test
//
//  Created by Micker on 2020/3/20.
//  Copyright © 2020 Micker. All rights reserved.
//

#import "BGChanin.h"
#import <objc/runtime.h>

static BOOL G_CHAIN_NODE_DEBUG = NO;

#pragma mark BGNode

@implementation BGNode
+ (instancetype)    node:(NSString *) node
                   group:(NSString *) group
                   index:(NSInteger) index
             handleBlock:(BGNodeBlock) block
{
    return  [[[self class] alloc] initWithNode:node
                                         group:group
                                         index:index
                                   handleBlock:block];
}

- (instancetype)    initWithNode:(NSString *) node
                           group:(NSString *) group
                           index:(NSInteger) index
                     handleBlock:(BGNodeBlock) block
{
    self = [super init];
    if (self) {
        self.nodeIdentifier = node;
        self.groupIdentifier = group;
        self.index = index;
        self.block = block;
    }
    return self;
}

- (void) execute {
    !self.block?:self.block(self);
}

- (void) exePreNode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(preNode:)]) {
        BGNode *node = [self.delegate preNode:self];
        [node execute];
    }
}

- (void) exeNextNode {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nextNode:)]) {
        BGNode *node = [self.delegate nextNode:self];
        [node execute];
    }
}

- (NSString *) description {
    return [self debugDescription];
}

- (NSString *) debugDescription {
    return [NSString stringWithFormat:@"-[%@:%@:%@:%@", [self class], self.groupIdentifier, self.nodeIdentifier, @(self.index)];
}

@end

#pragma mark BGChanin()

@interface BGChanin()
@property (nonatomic, strong) NSMutableDictionary *chains;
@end

#pragma mark BGChanin

@implementation BGChanin

+ (instancetype) sharedChain {
    static BGChanin *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BGChanin alloc] init];
    });
    return instance;
}

- (id) init {
    self = [super init];
    if (self) {
        self.chains = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

- (id) start {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self __internalStart];
    });

    return self;
}

- (id) __internalStart {
    //read from plist file
    NSString *chainDataPath = [[NSBundle mainBundle]  pathForResource:@"chain" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:chainDataPath];
    [self registerChains:dictionary];
    
    unsigned int count;
    Method *methods = class_copyMethodList([self class], &count);
    for (int i = 0; i < count; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);
        if ([name hasPrefix:@"registerChain_"]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:selector withObject:nil];
#pragma clang diagnostic pop
        }
    }
    
    free(methods);
    return self;
}

- (NSMutableArray *) chainsForIdentifier:(NSString *) chainIdentifier {
    return [self.chains valueForKey:chainIdentifier];
}

- (void) runChain:(NSString *) identifier {
    NSArray *identifiers = [identifier componentsSeparatedByString:@":"];
    if ([identifiers count] == 0) {
        return;
    }
    NSString *gIdentifier = [identifiers objectAtIndex:0];
    NSArray * nodes = [self chainsForIdentifier:gIdentifier];
    BGNode *node = nil;

    if ([identifiers count] == 2) {
        NSString *nodeIdentifier = [identifiers objectAtIndex:1];
        NSArray *nodeIdentifiers = [nodes valueForKeyPath:@"nodeIdentifier"];
        NSUInteger index = [nodeIdentifiers indexOfObject:nodeIdentifier];
        if (index>=0 && index < [nodeIdentifiers count]) {
            node = [nodes objectAtIndex:index];
        }
    } else {
        node = [nodes firstObject];
    }
    
    if (G_CHAIN_NODE_DEBUG) {
        NSLog(@"开始执行链路 %@ : %@", identifier, node);
    }
    [node execute];
}

- (BGNode *) preNode:(BGNode *) currentNode {
    
    NSArray * nodes = [self chainsForIdentifier:currentNode.groupIdentifier];
    NSUInteger index = [nodes indexOfObject:currentNode];
    if (index > 0) {
        return [nodes objectAtIndex:(index-1)];
    }
    return nil;
}

- (BGNode *) nextNode:(BGNode *) currentNode {
    NSArray * nodes = [self chainsForIdentifier:currentNode.groupIdentifier];
    NSUInteger index = [nodes indexOfObject:currentNode];
    if (index < [nodes count] -1) {
        return [nodes objectAtIndex:(index+1)];
    }
    return nil;
}

- (void) registerChains:(NSDictionary *) resolvers {
    
    NSArray *keys = [resolvers allKeys];
    [keys enumerateObjectsUsingBlock:^(NSString *groupName, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *object_list = [resolvers valueForKey:groupName];
        [object_list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dic = (NSDictionary *) obj;
            NSString *controlName = dic[@"class"];
            NSAssert(controlName, @"class 不能为空");
            BGNode *node = [NSClassFromString(controlName) new];
            if(node) {
                node.groupIdentifier = groupName;
                node.nodeIdentifier = dic[@"name"] ? : controlName;;
                node.index = dic[@"index"] ? [dic[@"index"] integerValue]: 100;;
                [self registerChain:node];
            }
        }];
    }];
}

- (void) registerChain:(BGNode *) node {
    @synchronized(self) {
        static NSUInteger _index = 0;
        __block NSInteger index = -1;
        
        NSMutableArray *chains = [self chainsForIdentifier:node.groupIdentifier];
        if (!chains) {
            chains = [NSMutableArray arrayWithCapacity:10];
        }
        [chains enumerateObjectsUsingBlock:^( BGNode *nodeTmp, NSUInteger idx, BOOL * _Nonnull stop) {
        
            if (node.index < nodeTmp.index ) {
                index = idx;
                *stop = YES;
            }
        }];
        if (-1 != index) {
            [chains insertObject:node atIndex:index];
        } else {
            [chains addObject:node];
        }
        node.delegate = self;
        if ([chains count] == 1) {
            [self.chains setValue:chains forKey:node.groupIdentifier];
        }
        if (G_CHAIN_NODE_DEBUG) {
            NSLog(@"正在注册执行链路 [%2lu]:%@",(unsigned long)_index++, node);
        }
    }
}

- (void) unRegisterChain:(BGNode *) node {
    NSMutableArray *chains = [self chainsForIdentifier:node.groupIdentifier];
    @synchronized(self) {
        __block BGNode *bgNode = nil;
        [chains enumerateObjectsUsingBlock:^(BGNode * nodeTmp, NSUInteger idx, BOOL * _Nonnull stop) {

            if ([node.nodeIdentifier isEqualToString:nodeTmp.nodeIdentifier]) {
                bgNode = nodeTmp;
                *stop = YES;
            }
        }];
        if (bgNode) {
            [chains removeObject:bgNode];
        }
    }
}

- (id) enableDebug {
    G_CHAIN_NODE_DEBUG = YES;
    return self;
}

@end
