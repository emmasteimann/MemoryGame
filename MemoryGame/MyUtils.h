//
//  MyUtils.h
//  MemoryGame
//
//  
//  
//
#import <Foundation/Foundation.h>

static void addtoNodeWithRoundedCorners(id containerNode, SKSpriteNode *nodeToBeCropped) {
  CGFloat cornerRadius = 15;
  SKCropNode *cropNode = [SKCropNode node];
  SKShapeNode *maskNode = [SKShapeNode shapeNodeWithRectOfSize:nodeToBeCropped.size cornerRadius:cornerRadius];
  maskNode.position = CGPointMake(nodeToBeCropped.position.x, nodeToBeCropped.position.y);
  [maskNode setLineWidth:0.0];
  [maskNode setFillColor:[UIColor whiteColor]];
  [cropNode setMaskNode:maskNode];
  [cropNode addChild:nodeToBeCropped];
  
  [containerNode addChild:cropNode];
}