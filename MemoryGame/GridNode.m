//
//  GridNode.m
//  MemoryGame
//
//  
//  
//

#import "GridNode.h"
 #import "AlbumSquareNode.h"
#import "SKActionOperation.h"
#import "NSMutableArray+Shuffle.h"

@interface GridNode()
@property (assign, nonatomic) int horizontal;
@property (assign, nonatomic) int vertical;
@property (assign, nonatomic) float sizeOfSquares;
@property (strong, nonatomic) NSMutableArray *allNodes;
@property (strong, nonatomic) NSMutableDictionary *activeNodeTable;
@end

@implementation GridNode {
  NSOperationQueue *_queue;
}

static int gridPadding = 30;

- (instancetype)initWithWidth:(float)width andX:(int)x andY:(int)y {
  
  float offsetOfMeasurementBasedOnGap = (x - 1) * gridPadding/2;
  float sizeOfSquares = (width - gridPadding - offsetOfMeasurementBasedOnGap) / x;
  float height = width;
  
  if (y == 1) {
    height = sizeOfSquares + gridPadding;
  }
  
  if ((self = [GridNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(width, height)])) {
    _allNodes = [NSMutableArray array];
    _activeNodes = [NSMutableArray array];
    _activeNodeTable = [NSMutableDictionary dictionary];
    _queue = [[NSOperationQueue alloc] init];
    _activatedNodeCounter = 0;
    _queue.maxConcurrentOperationCount = 1;
    _horizontal = x;
    _vertical = y;
    _sizeOfSquares = sizeOfSquares;
    
  }
  return self;
}

- (void)loadSquares:(int)number withImage:(UIImage *)image {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  BOOL firstTimeLoaded = [defaults boolForKey:@"FirstTimeLoaded"];
  
  int range = _vertical * _horizontal;
  
  if (number > range) {
    number = range;
  }
  
  NSArray *randomNumbers = [self getRandomNumbersWithRange:range andTotal:number];
  
  int i = 0;
  for (int y = 0; y < _vertical; y++) {
    for (int x = 0; x < _horizontal; x++) {
      AlbumSquareNode *newNode = [AlbumSquareNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(_sizeOfSquares, _sizeOfSquares)];
      newNode.isAnActiveNode = NO;
      [_allNodes addObject:newNode];
      newNode.name = [NSString stringWithFormat:@"square-%d", i];
      if ([randomNumbers containsObject:[NSNumber numberWithInt:i]]) {
        [_activeNodes addObject:newNode];
        newNode.texture = [SKTexture textureWithImage:image];
        newNode.isAnActiveNode = YES;
      } else {
        newNode.alpha = 0.65;
      }
      
      
      float additionalXPadding = (gridPadding/2) * x;
      float additionalYPadding = (gridPadding/2) * y;

      
      float nodeXPosition = (_sizeOfSquares * x) + additionalXPadding;
      float nodeYPosition = (_sizeOfSquares * y) + additionalYPadding;
      
      CGPoint point = [self positionNode:newNode atPoint:CGPointMake(nodeXPosition, nodeYPosition)];
      
      SKAction *addAction = [SKAction runBlock:^{
        newNode.position = point;
        [self addChild:newNode];
      }];
      
      if (firstTimeLoaded) {
        [_queue addOperation:[[SKActionOperation alloc] initWithNode:self action:addAction]];
      } else {
        newNode.position = point;
        [self addChild:newNode];
      }
      i += 1;
    }
  }
  
  [defaults setBool:NO forKey:@"FirstTimeLoaded"];
  [defaults synchronize];
  
  SKAction *runDelegate = [SKAction runBlock:^{
    [_delegate gridFullyLoaded];
  }];
  
  [_queue addOperation:[[SKActionOperation alloc] initWithNode:self action:runDelegate]];
}

- (void)hideAndWaitGuess {
  for (AlbumSquareNode *node in _activeNodes) {
    node.alpha = 0.65;
    node.texture = nil;
  }
}

- (NSMutableArray *)getRandomNumbersWithRange:(int)range andTotal:(int)total{
  NSMutableArray *newArray = [NSMutableArray array];
  for (int i = 0; i < range; i++) {
    [newArray addObject:[NSNumber numberWithInt:i]];
  }
  [newArray shuffle];
  return [[newArray subarrayWithRange:(NSRange){0,total}] copy];
}

- (CGPoint)positionNode:(AlbumSquareNode *)node atPoint:(CGPoint)point {
  float xOffset = self.frame.size.width / 2;
  float yOffset = self.frame.size.height / 2;
  float newX = point.x - xOffset + (gridPadding/2) + (_sizeOfSquares/2);
  float newY = point.y - yOffset + (gridPadding/2) + (_sizeOfSquares/2);
  node.position = CGPointMake(newX, 1000);
  return CGPointMake(newX, newY);
}

@end
