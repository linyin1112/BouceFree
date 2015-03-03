//
//  Ghost.m
//  BounceFree
//
//  Created by Yin Lin on 3/2/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Ghost.h"

@implementation Ghost{
    CCNode *_ghost;
}
- (void)didLoadFromCCB{
    _ghost.physicsBody.collisionType = @"ghost";
    _ghost.physicsBody.sensor = YES;
}
- (void)randomFly{
    NSUInteger r = arc4random_uniform(50);
    self.physicsBody.velocity = ccp(-150, r-100);
}
@end
