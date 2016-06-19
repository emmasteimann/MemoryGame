//
//  EarnedHeartsNode.m
//  MemoryGame
//
//  
//  
//

#import "EarnedHeartsNode.h"
#import "HeartNode.h"

@implementation EarnedHeartsNode
- (instancetype)init
{
  self = [super init];
  if (self) {
    self.name = @"earned-node";
    
    for (int i = 0; i < 3; i++) {
      HeartNode *heartNode = [HeartNode spriteNodeWithImageNamed:@"heart-grey"];
      heartNode.name = [NSString stringWithFormat:@"heart-node-%d", i+1];
      heartNode.size = CGSizeMake(40, 40);
      heartNode.position = CGPointMake((40 * (i-1)), 0);
      [self addChild:heartNode];
    }
  }
  return self;
}

-(void)setActiveHeart:(int)activeNumber {
  HeartNode *heartNode = (HeartNode *)[self childNodeWithName:[NSString stringWithFormat:@"heart-node-%d", activeNumber]];
  heartNode.isActiveHeart = YES;
  heartNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"heart-orange"]];
}

-(void)resetHeartCounter {
  for (int i = 1; i < 4; i++) {
    HeartNode *heartNode = (HeartNode *)[self childNodeWithName:[NSString stringWithFormat:@"heart-node-%d", i]];
    heartNode.isActiveHeart = NO;
    heartNode.texture = [SKTexture textureWithImage:[UIImage imageNamed:@"heart-grey"]];
  }
}

@end
