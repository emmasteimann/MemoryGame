//
//  GridNode.h
//  MemoryGame
//
//  
//  
//

#import <SpriteKit/SpriteKit.h>

@protocol GridDelegate
@optional
- (void)gridFullyLoaded;
@end

@interface GridNode : SKSpriteNode
@property (weak) id <GridDelegate> delegate;
@property (assign, nonatomic) int activatedNodeCounter;
@property (strong, nonatomic) NSMutableArray *activeNodes;

- (instancetype)initWithWidth:(float)width andX:(int)x andY:(int)y;
- (void)loadSquares:(int)number withImage:(UIImage *)image;
- (void)hideAndWaitGuess;
@end
