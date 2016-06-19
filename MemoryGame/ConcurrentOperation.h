//
//  ConcurrentOperation.h
//
//  
//  
//

#import <Foundation/Foundation.h>

typedef void (^completion_block_t)(id result);

@interface ConcurrentOperation : NSOperation
- (id)initWithCompletionHandler:(completion_block_t)completionHandler;
- (void)completeOperation;
@property (nonatomic, strong) id result;
@property (nonatomic, copy) completion_block_t completionHandler;
@end
