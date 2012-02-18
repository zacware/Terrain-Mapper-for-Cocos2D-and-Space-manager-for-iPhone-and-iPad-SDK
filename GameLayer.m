//
//
//
//  Created by Steve Weintraut LLC
//  Copyright 2012 by Steve Weintraut LLC
//

#import "GameLayer.h"

#import "RootViewController.h"
#import "OpenGL_Internal.h"
#import "AppDelegate.h"
#import "chipmunk.h"
#import "SpaceManager.h"
#import "cpConstraintNode.h"
#import "cpShapeNode.h"
#import "cpCCSprite.h"
#import "cpShape.h"
#import "cpCCNode.h"

#import "ccMacros.h"

#import "GameScene.h"

@implementation GameLayer

-(id) init
{
	int x;
	
	if( ! [super init] )
		return nil;
	
	self.anchorPoint=cpv(0,0);
	
	//isTouchEnabled = YES;	

	myTerrainDataArray=[[NSMutableArray alloc] init];
	
	//Setup the 2D world
	
	mySpaceManager=[[SpaceManagerCocos2d alloc] init];	
	mySpaceManager.constantDt = 1.0/55.0;	
	mySpaceManager.gravity=cpv(0,-700);
	
	//This cool routine analyses the background image and creates an array of data points to follow the curves of the data so we can make a collision shape
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		[myTerrainDataArray removeAllObjects];
		[self PixelTracker:@"terrain_ipad.png"];
	}
	else
	{
		[myTerrainDataArray removeAllObjects];
		[self PixelTracker:@"terrain_iphone.png"];
	}
	
	//Create the Actual CCSprite Containing CCLayer
	
	mySpriteLayer=[[CCLayer alloc] init];
	
	mySpriteLayer.anchorPoint=cpv(0,0);
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		UIImage *myTempImage;	
		myTotalGameLayerWidth=0;
		myTempImage=[UIImage imageNamed:@"terrain_ipad.png"];
		myTotalGameLayerWidth+=myTempImage.size.width;
	}
	else
	{
		UIImage *myTempImage;	
		myTotalGameLayerWidth=0;
		myTempImage=[UIImage imageNamed:@"terrain_iphone.png"];
		myTotalGameLayerWidth+=myTempImage.size.width;
	}
	
	//We load the background images
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		CCSprite *localBackgroundSprite=[CCSprite spriteWithFile:@"terrain_ipad.png"];
		localBackgroundSprite.position=cpv([UIImage imageNamed:@"terrain_ipad.png"].size.width/2,384);
		[mySpriteLayer addChild:localBackgroundSprite];
	}
	else
	{
		CCSprite *localBackgroundSprite=[CCSprite spriteWithFile:@"terrain_iphone.png"];
		localBackgroundSprite.position=cpv([UIImage imageNamed:@"terrain_iphone.png"].size.width/2,160);
		[mySpriteLayer addChild:localBackgroundSprite];
	}
	
	//Here we create the shapes to follow the terrain images
	
	cpVect myPreviousCPVect=cpv(0,[[myTerrainDataArray objectAtIndex:0] integerValue]);
	
	cpShape *localTempShape;
	
	cpVect myCurrentCPVect;
	
	for(x=1;x<=[myTerrainDataArray count]-1;x=x+40)
	{
		myCurrentCPVect = cpv(x,[[myTerrainDataArray objectAtIndex:x] integerValue]);
		
		localTempShape=[mySpaceManager addSegmentAt:cpv(0,0) fromLocalAnchor:myPreviousCPVect toLocalAnchor:myCurrentCPVect mass:STATIC_MASS radius:0];
		localTempShape->u=1.0;
		localTempShape->collision_type=kTerrainCollisionID;
		
		myPreviousCPVect=myCurrentCPVect;
	}
	
	// we have to make sure we plot the last point since it might get skipped because of the increment!
	
	myCurrentCPVect = cpv([myTerrainDataArray count]-1,[[myTerrainDataArray objectAtIndex:[myTerrainDataArray count]-1] integerValue]);
	
	localTempShape=[mySpaceManager addSegmentAt:cpv(0,0) fromLocalAnchor:myPreviousCPVect toLocalAnchor:myCurrentCPVect mass:STATIC_MASS radius:0];
	localTempShape->u=1.0;
	localTempShape->collision_type=kTerrainCollisionID;
	
	//These are invisible walls we put around the game to keep things from escaping
	
	int localConditionalHeight=0;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		localConditionalHeight=768;
	}
	else
	{
		localConditionalHeight=320;
	}
	
	cpVect localBottomLeft=cpv(0,0);
	cpVect localTopLeft=cpv(0,localConditionalHeight);
	cpVect localTopRight=cpv(myTotalGameLayerWidth,localConditionalHeight);
	cpVect localBottomRight=cpv(myTotalGameLayerWidth, 0);
	
	localTempShape=[mySpaceManager addSegmentAt:cpv(0,0) fromLocalAnchor:localBottomLeft toLocalAnchor:localTopLeft mass:STATIC_MASS radius:0];
	localTempShape->u=1.0;
	localTempShape->collision_type=kLeftGameAreaWallCollisionID;
	
	localTempShape=[mySpaceManager addSegmentAt:cpv(0,0) fromLocalAnchor:cpv(0,localConditionalHeight) toLocalAnchor:cpv(myTotalGameLayerWidth,localConditionalHeight) mass:STATIC_MASS radius:0];
	localTempShape->u=0.0;
	localTempShape->collision_type=kTopGameAreaWallCollisionID;
	
	localTempShape=[mySpaceManager addSegmentAt:cpv(0,0) fromLocalAnchor:localTopRight toLocalAnchor:localBottomRight mass:STATIC_MASS radius:0];
	localTempShape->u=1.0;
	localTempShape->collision_type=kRightGameAreaWallCollisionID;
	
	localTempShape=[mySpaceManager addSegmentAt:cpv(0,0) fromLocalAnchor:localBottomRight toLocalAnchor:localBottomLeft mass:STATIC_MASS radius:0];
	localTempShape->u=1.0;
	localTempShape->collision_type=kBottomGameAreaWallCollisionID;
    
    //we are going to setup a collision monitor so that when the wheel hits the right wall it starts all over again
	
    [mySpaceManager addCollisionCallbackBetweenType:kItemIsPartOfTheTankGroup otherType:kRightGameAreaWallCollisionID target:self selector:@selector(HandleRightWallCollision:arbiter:space:)];
	
	//OK, now we are going to drop a simple wheel onto the scene
    
    [self AddWheel];
    
    //ok, we finish up now
	
	[self addChild:mySpriteLayer z:(-2)];
    
    [mySpaceManager start];
	
	return self;
}

-(int)HandleRightWallCollision:(CollisionMoment)moment arbiter:(cpArbiter*)arb space:(cpSpace*)space
{
    cpCCSprite *localSprite=(cpCCSprite*)[mySpriteLayer getChildByTag:100];
    if (localSprite)
    {
        [mySpaceManager removeShape:localSprite.shape];
        localSprite.tag=0;
        [mySpriteLayer removeChild:localSprite cleanup:YES];
        
        [self performSelector:@selector(AddWheel) withObject:nil afterDelay:0.1];
    }

    return 1;
}

-(void) dealloc
{	
	[super dealloc];
}

-(void) onQuit: (id) sender
{	
	[[CCDirector sharedDirector] end];	
}

-(void)PixelTracker:(NSString*)myImageName
{
	UIImage *myOtherImage=[UIImage imageNamed:myImageName];
	
	CGContextRef currentContext=[self initARGBBitmapContextFromImage:[myOtherImage CGImage]];
	
    size_t w = CGImageGetWidth([myOtherImage CGImage]);
	size_t h = CGImageGetHeight([myOtherImage CGImage]);
	CGRect rect = {{0,0},{w,h}}; 
	
	CGContextDrawImage(currentContext, rect, [myOtherImage CGImage]); 
	
	unsigned char *pixelData = CGBitmapContextGetData (currentContext); 
    if (pixelData != NULL) 
    { 
		unsigned char *alpha; 
		
		int myCurrentRow,myCurrentColumn;
		
		int myCurrentActualY=0;
		
		int myRowTotal=CGBitmapContextGetHeight(currentContext);
		int myColumnTotal=CGBitmapContextGetBytesPerRow(currentContext);
		
		
		for (myCurrentColumn = 0; myCurrentColumn <= myColumnTotal-1; myCurrentColumn += 4 )
		{ 
			//myCurrentActualX=(myCurrentColumn)/4;				
			for (myCurrentRow = 0; myCurrentRow <= myRowTotal-1; myCurrentRow += 1 )
			{
				myCurrentActualY=myCurrentRow;
				
				size_t index=(myCurrentRow*myColumnTotal)+myCurrentColumn;				
				alpha = pixelData + index;
				if (*alpha!=0)
				{
					[myTerrainDataArray addObject:[NSNumber numberWithInt:(h-myCurrentActualY)]]; 
					break;
				}				
			}
		}
		
	}
	
	UIGraphicsEndImageContext();	

    char *localBitmapData = CGBitmapContextGetData(currentContext);
    
    CGContextRelease(currentContext);	

	if (localBitmapData)
	{
		free(localBitmapData);
	}
}

- (CGContextRef) initARGBBitmapContextFromImage:(CGImageRef) inImage {
	
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedFirst);
	if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
	
	// Make sure and release colorspace before returning
	CGColorSpaceRelease( colorSpace );
	
	return context;
}

-(CGPoint)GetStartingWheelPosition
{
    
	int localWheelX=0;
	int localWheelY=0;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		localWheelX=40;
		localWheelY=675;
	}
	else
	{
		localWheelX=10;
		localWheelY=310;
	}
    
    return CGPointMake(localWheelX, localWheelY);
}

-(void)AddWheel
{
    cpShape *localPlayerShape;
    cpCCSprite *localPlayerSprite;
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		localPlayerShape = [mySpaceManager addCircleAt:[self GetStartingWheelPosition] mass:2 radius:15];
		localPlayerSprite = [cpCCSprite spriteWithFile:@"wheel_ipad.png"];
	}
	else
	{
		localPlayerShape = [mySpaceManager addCircleAt:[self GetStartingWheelPosition] mass:2 radius:7];
		localPlayerSprite = [cpCCSprite spriteWithFile:@"wheel_iphone.png"];
	}
	
    localPlayerSprite.shape=localPlayerShape;
    
    localPlayerSprite.shape->group=kItemIsPartOfTheTankGroup;
    localPlayerSprite.shape->collision_type=kItemIsPartOfTheTankGroup;
    
    localPlayerSprite.shape->u=4.5;
    
    localPlayerSprite.tag=100;
    
    [mySpriteLayer addChild:localPlayerSprite];
}

@end

