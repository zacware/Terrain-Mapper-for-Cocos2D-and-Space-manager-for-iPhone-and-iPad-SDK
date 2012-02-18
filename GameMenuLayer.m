#import "GameMenuLayer.h"
#import "GameScene.h"

@implementation GameMenuLayer

- (id) init {
    self = [super init];
    if (self != nil)
	{
		CCSprite *localSprite;
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			localSprite=[CCSprite spriteWithFile:@"purple_background_ipad.jpg"];
		}
		else
		{
			localSprite=[CCSprite spriteWithFile:@"purple_background.jpg"];
		}
		
		localSprite.position=cpv(self.contentSize.width/2,self.contentSize.height/2);
		
		[self addChild:localSprite];
		
		[CCMenuItemFont setFontSize:60];
        [CCMenuItemFont setFontName:@"Marker Felt"];
        CCMenuItem *nothing1 = [CCMenuItemFont itemFromString:@" "
													   target:self
													 selector:@selector(menuCallbackDisabled:)];
		CCMenuItem *nothing2 = [CCMenuItemFont itemFromString:@" "
													   target:self
													 selector:@selector(menuCallbackDisabled:)];
		CCMenuItem *nothing3 = [CCMenuItemFont itemFromString:@" "
													   target:self
													 selector:@selector(menuCallbackDisabled:)];
        CCMenuItem *start = [CCMenuItemFont itemFromString:@"Show the Demo"
													target:self
												  selector:@selector(startGame:)];
        CCMenu *menu = [CCMenu menuWithItems:nothing1,nothing2,nothing3,start, nil];
        [menu alignItemsVertically];
        [self addChild:menu z:10];
    }
    return self;
}

-(void)startGame:(id)sender
{
	GameScene *localScene=[GameScene node];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipAngular transitionWithDuration:1 scene:localScene]];
}

-(void) menuCallbackDisabled:(id) sender
{
}


@end
