//
//  BGChanin.h
//  test
//
//  Created by Micker on 2020/3/20.
//  Copyright © 2020 Micker. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BGNode;

typedef void (^BGNodeBlock)(BGNode *node);

/// 主要适用于前后关联顺序
@protocol BGNodeProtocol <NSObject>

@optional

- (BGNode *) preNode:(BGNode *) currentNode;
- (BGNode *) nextNode:(BGNode *) currentNode;

@end

#pragma mark BGNode

/// 此类主要用于构建执行node节点，通常与BGChain结合起来使用
@interface BGNode : NSObject

/// 分组标示符
@property (nonatomic, copy) NSString *groupIdentifier;

/// 组内标示符
@property (nonatomic, copy) NSString *nodeIdentifier;

/// 执行block
@property (nonatomic, copy) BGNodeBlock block;

/// 索引位置， 默认为100，值越小，执行顺序越靠前，越大越靠后
@property (nonatomic, assign) NSInteger index;

/// 链接向前可执行的步数，默认值为0,即不限制， 1则表示仅执行当前execute方法
@property (nonatomic, assign) NSUInteger preStep;

/// 链接向后可执行的步数，默认值为0,即不限制， 1则表示仅执行当前execute方法
@property (nonatomic, assign) NSUInteger nextStep;

/// Node相关信息
@property (nonatomic, strong) NSDictionary *userInfo;


/// 关联前后顺序的代理
@property (nonatomic, weak) id<BGNodeProtocol> delegate;


+ (instancetype)    node:(NSString *) node
                   group:(NSString *) group
                   index:(NSInteger) index
             handleBlock:(BGNodeBlock) block;

- (instancetype) initWithNode:(NSString *) node
                        group:(NSString *) group
                        index:(NSInteger) index
                  handleBlock:(BGNodeBlock) block;

/// 执行具体方法，默认执行的是block内的内容
- (void) execute;

/// 执行前一个node的内容，倒序
- (void) exePreNode;

/// 执行后一个node的内容，顺序
- (void) exeNextNode;

@end

#pragma mark BGChanin

/// 主要用于链式构建顺应关联，可将各执行节点分散在不同的库中，根据group、node identifier 进行关联起来；
@interface BGChanin : NSObject <BGNodeProtocol>

+ (instancetype) sharedChain;

/**
 *  启动注册
 *  备注：此处会通过反射调用BGChanin的Category中的，以registerChain_开头的方法；
 *       可以通过编写对应的Category来进行加载
 *
 *  @return self
 */
- (id) start:(NSString *) fileName;

/**
 *  开启调试模式，会打印相关日志信息
 *
 *  @return self
 */
- (id) enableDebug;


/// 注册Node到Chain中去
/// @param info info description
- (void) registerChain:(BGNode *) info;


/// 反注册Node到Chain中去
/// @param info info description
- (void) unRegisterChain:(BGNode *) info;


/// 开始执行 identifier 分组下的链条
///  分两种情况，不带":"，则为groupIdentifier下的链路， 带":"则直接执行group和node唯一确定后的链路
/// @param identifier 分组标示符
/// @param info     用户附加信息
- (void) runChain:(NSString *) identifier userInfo:(NSDictionary *) info;

@end

