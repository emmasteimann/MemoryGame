//
//  SKActionOperation.m
//  MemoryGame
//
//  
//  
//

#import "SKActionOperation.h"
@import SpriteKit;

@interface SKActionOperation ()

@property (nonatomic, readwrite, getter = isFinished)  BOOL finished;
@property (nonatomic, readwrite, getter = isExecuting) BOOL executing;

@property (nonatomic, strong) SKNode *node;
@property (nonatomic, strong) SKAction *action;

@end

@implementation SKActionOperation

@synthesize finished  = _finished;
@synthesize executing = _executing;

- (instancetype)initWithNode:(SKNode *)node action:(SKAction *)action
{
  self = [super init];
  if (self) {
    _node = node;
    _action = action;
  }
  return self;
}

- (void)start
{
  if ([self isCancelled]) {
    self.finished = YES;
    return;
  }
  
  self.executing = YES;
  
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    [self.node runAction:self.action completion:^{
      self.executing = NO;
      self.finished = YES;
    }];
  }];
}

#pragma mark - NSOperation methods

- (BOOL)isConcurrent
{
  return YES;
}

- (void)setExecuting:(BOOL)executing
{
  [self willChangeValueForKey:@"isExecuting"];
  _executing = executing;
  [self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished
{
  [self willChangeValueForKey:@"isFinished"];
  _finished = finished;
  [self didChangeValueForKey:@"isFinished"];
}

@end