//
//  GameScene.m
//
//
//  Created by Steve Weintraut LLC

//

#import "GameScene.h"


@implementation GameScene

- (id) init {
    self = [super init];
    if (self != nil)
	{
		myActualGameLayer =[GameLayer node];
		[self addChild: myActualGameLayer z:2];		
    }
    return self;
}

-(void)onExit
{
	[myActualGameLayer removeAllChildrenWithCleanup:YES];
	[self removeChild:myActualGameLayer cleanup:YES];
	[self removeAllChildrenWithCleanup:YES];
	[self cleanup];
}

@end
