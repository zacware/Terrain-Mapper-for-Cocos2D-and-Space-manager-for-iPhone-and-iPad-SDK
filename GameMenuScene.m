//
//
//
//  Created by Steve Weintraut LLC

//

#import "GameMenuScene.h"

@implementation GameMenuScene

- (id) init {
    self = [super init];
    if (self != nil)
	{
		myGameMenuLayer =[GameMenuLayer node];
		[self addChild: myGameMenuLayer z:2];
    }
    return self;
}

@end
