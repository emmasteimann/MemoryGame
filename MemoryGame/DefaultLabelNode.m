//
//  DefaultLabelNode.m
//  MemoryGame
//
//  
//  
//

#import "DefaultLabelNode.h"

@implementation DefaultLabelNode
- (instancetype)init
{
  self = [super init];
  if (self) {
    self.fontColor = [UIColor whiteColor];
    self.fontName = @"HelveticaNeue-Bold";
    self.fontSize = 20.0f;
  }
  return self;
}
@end
