//
//  ConcurrentOperation.m
//
//  Apple is silly and makes you manage state for concurrency
//  See: https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationObjects/OperationObjects.html#//apple_ref/doc/uid/TP40008091-CH101-SW1
//
//  
//  
//

#import "ConcurrentOperation.h"

@interface ConcurrentOperation()
@property (atomic, assign) BOOL _executing;
@property (atomic, assign) BOOL _finished;
@end

@implementation ConcurrentOperation
{
  completion_block_t _completionHandler;
}

- (id)initWithCompletionHandler:(completion_block_t)completionHandler
{
  if (self = [super init]) {
    _completionHandler = [completionHandler copy];
  }
  return self;
}

- (void) start;
{
  if ([self isCancelled])
  {
    [self willChangeValueForKey:@"isFinished"];
    self._finished = YES;
    [self didChangeValueForKey:@"isFinished"];
    return;
  }
  
  [self willChangeValueForKey:@"isExecuting"];
  
  [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
  self._executing = YES;
  [self didChangeValueForKey:@"isExecuting"];
  
}

- (void) main;
{
  if ([self isCancelled]) {
    return;
  }
  
}

- (BOOL) isAsynchronous;
{
  return YES;
}

- (BOOL)isExecuting {
  return self._executing;
}

- (BOOL)isFinished {
  return self._finished;
}

- (void)completeOperation {
  [self willChangeValueForKey:@"isFinished"];
  [self willChangeValueForKey:@"isExecuting"];
  
  self._executing = NO;
  self._finished = YES;
  
  [self didChangeValueForKey:@"isExecuting"];
  [self didChangeValueForKey:@"isFinished"];
  
  completion_block_t completionHandler = _completionHandler;
  _completionHandler = nil;
  
  if (completionHandler) {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
      completionHandler(_result);
    });
  }
}
@end
