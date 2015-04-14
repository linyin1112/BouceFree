#import "GamePlayScene.h"
#import "Character.h"
#import "Obstacle.h"
#import "PlaySound.h"
#import "AppKit";

@implementation GamePlayScene



- (void) initialize{
    // your code here
    
    character = (Character*)[CCBReader load:@"Character"];
    [physicsNode addChild:character];
    [self addObstacle];
    time = 0;
    timeSinceObstacle = 0.0f;

}

-(void)update:(CCTime)delta//////////////
{
    time += delta;
    timeSinceObstacle += delta; //

    if(timeSinceObstacle > 0.7f){
        [self addObstacle];
        timeSinceObstacle = 0.0f;
        time++;
    }
    
    if(time%10 == 0){
       // [character speedup];
    }
    
}

// put new methods here
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event{/////////
    [character flap];
    [bouncesound bouceSound];
    [[NSSound soundNamed:@"Hero"] play];

}

-(void)speedup{
    [character speedup];
}
@end
