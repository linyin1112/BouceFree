//
//  Character.m
//  FlappyBird
//
//  Created by Gerald on 2/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Character.h"
#import "GamePlayScene.h"

@implementation Character

- (void)didLoadFromCCB
{
    self.position = ccp(115, 20);
    self.zOrder = DrawingOrderHero;
    self.physicsBody.collisionType = @"character";
}

- (void)flap
{   //self.rotation = 180.0f;
    //self.position = ccp(self.position.x+1, 320 - self.position.y);
    if (self.physicsNode.position.y >= 300) {
        self.physicsBody.velocity = ccp(self.physicsBody.velocity.x,  self.physicsBody.velocity.y -100);
    }
    self.physicsBody.velocity = ccp(self.physicsBody.velocity.x, 100 - self.physicsBody.velocity.y);

}

@end
