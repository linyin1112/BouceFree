//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Benjamin Encz on 10/10/13.
//  Copyright (c) 2014 MakeGamesWithUs inc. Free to use for all purposes.
//

#import "MainScene.h"
#import "Obstacle.h"
#import "Coin.h"
#import "Ghost.h"
#import "Fence.h"

@interface CGPointObject : NSObject{
    CGPoint _ratio;
    CGPoint _offset;
    CCNode *__unsafe_unretained _child; //weak ref
}

@property (nonatomic, readwrite) CGPoint ratio;
@property (nonatomic, readwrite) CGPoint offset;
@property (nonatomic, readwrite, unsafe_unretained) CCNode *child;
+(id) pointWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
-(id) initWithCGPoint:(CGPoint)point offset:(CGPoint)offset;
@end

@implementation MainScene {
    
    CCNode *_parallaxContainer;
    CCParallaxNode *_parallaxBackground;
    
  
    
    NSTimeInterval _sinceTouch;
    
    NSMutableArray *_obstacles;
    
    NSMutableArray *_coins;
    
    NSMutableArray *_fences;
    
    CCButton *_restartButton;
    
    BOOL _gameOver;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_scoreTotal;
    CCLabelTTF *_nameLabel;
    int cnt;
    int points;
    int highScore;
}


- (void)didLoadFromCCB {
    self.userInteractionEnabled = TRUE;
    _parallaxBackground = [CCParallaxNode node];
    [_parallaxContainer addChild:_parallaxBackground];
    
    // set this class as delegate
    physicsNode.collisionDelegate = self;
    
    _obstacles = [NSMutableArray array];
    _coins = [NSMutableArray array];
    _fences = [NSMutableArray array];
    points = 0;
    _scoreLabel.visible = true;
    _scoreTotal.visible = true;
    
    [super initialize];
    character.physicsBody.velocity = ccp(character.physicsBody.velocity.x, 100);
    cnt = 0;
}

#pragma mark - Touch Handling

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    if (!_gameOver) {
        
        
        @try
        {
            [super touchBegan:touch withEvent:event];
        }
        @catch(NSException* ex)
        {
            
        }

    }
}

#pragma mark - Game Actions

- (void)gameOver {
    if (!_gameOver) {
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        
        character.physicsBody.velocity = ccp(0.0f, character.physicsBody.velocity.y);
        character.rotation = 90.f;
        character.physicsBody.allowsRotation = FALSE;
        [character stopAllActions];
        
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        
        [self runAction:bounce];
    }
    //TODO: game over
}


- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

#pragma mark - Obstacle Spawning

- (void)addObstacle {
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    CGPoint screenPosition = [self convertToWorldSpace:ccp(568, 0)];
    CGPoint worldPosition = [physicsNode convertToNodeSpace:screenPosition];
    obstacle.position = worldPosition;
    
    Fence *fence = (Fence *)[CCBReader load:@"Fence"];
    fence.position = worldPosition;
    
    Coin *coin = (Coin *)[CCBReader load:@"Coin"];
    coin.position = worldPosition;
    
    Ghost *ghost = (Ghost *)[CCBReader load:@"Ghost"];
    ghost.position = worldPosition;


    CGSize size = [[CCDirector sharedDirector] viewSize];
    NSUInteger r = arc4random_uniform(6);
    if (r == 0) {
        //NSUInteger b = 20 + arc4random_uniform(260);

        obstacle.rotation = 180.0f;
        obstacle.position = ccp(obstacle.position.x, size.height);
        //obstacle.position = ccp(obstacle.position.x ,b);
        obstacle.zOrder = DrawingOrderPipes;
        [physicsNode addChild:obstacle];
        [_obstacles addObject:obstacle];
    }
    else if (r == 1 || r == 2){//cactus
        obstacle.zOrder = DrawingOrderPipes;
        [physicsNode addChild:obstacle];
        [_obstacles addObject:obstacle];
    }
    else if (r == 4 || r == 3){//coin
        float b = ((float)rand()/RAND_MAX);
        coin.position = ccp(coin.position.x, size.height*b);
        coin.zOrder = DrawingOrderPipes;
        [physicsNode addChild:coin];
        
        [_coins addObject:coin];
        
        
    }
    else if (r == 5 || r == 6){//ghost
        float b = ((float)rand()/RAND_MAX);
        ghost.position = ccp(ghost.position.x, size.height*b);
        obstacle.zOrder = DrawingOrderPipes;
        [physicsNode addChild:ghost];
        [ghost fly];
    }/*
    else{
        
        coin.position = ccp(coin.position.x, coin.position.y+280);
        coin.zOrder = DrawingOrderPipes;
        [physicsNode addChild:coin];
        [_coins addObject:coin];
    }*/
    
}



#pragma mark - Update

- (void)showScore
{
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    _scoreLabel.visible = true;

    highScore = [[[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"] unsignedLongLongValue];
    _scoreTotal.string = [NSString stringWithFormat:@"%d", highScore];
    _scoreTotal.visible = true;
}

- (void)update:(CCTime)delta
{
    _sinceTouch += delta;
    
    //character.rotation = clampf(character.rotation, -30.f, 90.f);
    
    
    
    if (character.physicsBody.allowsRotation) {
        float angularVelocity = clampf(character.physicsBody.angularVelocity, -2.f, 1.f);
        character.physicsBody.angularVelocity = angularVelocity;
    }
    
    if ((_sinceTouch > 0.5f)) {
        [character.physicsBody applyAngularImpulse:-40000.f*delta];
    }
    
    physicsNode.position = ccp(physicsNode.position.x - (character.physicsBody.velocity.x * delta), physicsNode.position.y);
       _parallaxBackground.position = ccp(_parallaxBackground.position.x - (character.physicsBody.velocity.x * delta), _parallaxBackground.position.y);

    CGSize size = [[CCDirector sharedDirector] viewSize];
    
    if (character.position.y > size.height*0.98f) {
        character.position = ccp(character.position.x, size.height*0.02f);
    }

    if (character.position.y < size.height*0.01f) {
        character.position = ccp(character.position.x, size.height*0.97f);
    }

    
    NSMutableArray *offScreenObstacles = nil;
    
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
    }

    
    NSMutableArray *offScreenCoins = nil;
    
    for (CCNode *coin in _coins) {
        CGPoint coinWorldPosition = [physicsNode convertToWorldSpace:coin.position];
        CGPoint coinScreenPosition = [self convertToNodeSpace:coinWorldPosition];
        if (coinScreenPosition.x < -coin.contentSize.width) {
            if (!offScreenCoins) {
                offScreenCoins = [NSMutableArray array];
            }
            [offScreenCoins addObject:coin];
        }
    }
    
    for (CCNode *coinToRemove in offScreenCoins) {
        [coinToRemove removeFromParent];
        [_obstacles removeObject:coinToRemove];
    }
    
    
    if (!_gameOver)
    {
        @try
        {
            character.physicsBody.velocity = ccp(180.f, clampf(character.physicsBody.velocity.y, -MAXFLOAT, 200.f));

            [super update:delta];
        }
        @catch(NSException* ex)
        {
            
        }
    }
    
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair character:(CCSprite*)character minus:(CCNode*)minus {
    [minus removeFromParentAndCleanup:YES];
    points -= 2;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    return FALSE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair character:(CCSprite*)character bonus:(CCNode*)bonus {

    [bonus removeFromParentAndCleanup:YES];
    points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    
    return FALSE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair bonus:(CCSprite*)bonus ghost:(CCSprite*)ghost {
    [bonus removeFromParentAndCleanup:YES];
    return FALSE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair minus:(CCSprite*)minus ghost:(CCSprite*)ghost {
    [minus removeFromParentAndCleanup:YES];
    return FALSE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair*)pair character:(CCSprite*)character ghost:(CCSprite*)ghost {
    //highScore = [[[NSUserDefaults standardUserDefaults] objectForKey:@"HighScore"] intValue ];


    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedLongLong:highScore] forKey:@"highScore"];
    [self gameOver];
    //[minus removeFromParentAndCleanup:YES];
    //points--;
    //_scoreLabel.string = [NSString stringWithFormat:@"%d", points];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)character edge:(CCNode *)edge{
    [self gameOver];
    return TRUE;
}

@end
