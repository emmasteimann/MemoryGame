//
//  SKActionOperation.h
//  MemoryGame
//
//  
//  
//

#import <Foundation/Foundation.h>

@class SKNode;
@class SKAction;

@interface SKActionOperation : NSOperation

- (instancetype)initWithNode:(SKNode *)node action:(SKAction *)action;

@end