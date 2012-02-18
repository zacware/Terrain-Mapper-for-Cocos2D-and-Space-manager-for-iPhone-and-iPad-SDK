//
//  GameScene.h
//
//
//  Created by Steve Weintraut LLC

//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "GameLayer.h"

@interface GameScene : CCScene
{
	GameLayer *myActualGameLayer;
}

@end
