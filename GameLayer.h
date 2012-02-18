//
//
//
//  Created by Steve Weintraut LLC
//  Copyright 2012 by Steve Weintraut LLC
//

#import <Foundation/Foundation.h>

#import "SpaceManagerCocos2d.h"

#define kWorldRightWall 545
#define kWorldLeftWall 364
#define kWorldBottomWall 323
#define kWorldTopWall 623

#define kLeftGameAreaWallCollisionID 91
#define kTopGameAreaWallCollisionID 92
#define kRightGameAreaWallCollisionID 93
#define kBottomGameAreaWallCollisionID 94

#define kTerrainCollisionID 892

#define kItemIsPartOfTheTankGroup 87

#define kMaxTorqueValue 100

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "chipmunk.h"
#import "SpaceManager.h"
#import "cpCCSprite.h"
#import "cpShape.h"
#import "cpShapeNode.h"

@interface GameLayer : CCLayer <UIAccelerometerDelegate>
{
	ccTime t;
	
	NSMutableArray *myTerrainDataArray;

	int myTotalGameLayerWidth;
	
	SpaceManagerCocos2d *mySpaceManager;
	
	CCLayer *myBackgroundLayer;
	
	CCLayer *mySpriteLayer;	
}

-(void)PixelTracker:(NSString*)myImageName;
-(CGContextRef)initARGBBitmapContextFromImage:(CGImageRef) inImage;
-(CGPoint)GetStartingWheelPosition;
-(void)AddWheel;
@end
