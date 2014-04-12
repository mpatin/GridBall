//
//  ViewController.m
//  First/Users/mitchellrpatin/Documents/First/First.xcodeproj
//
//  Created by Mitchell Patin on 4/11/14.
//  Copyright (c) 2014 Mitchell Patin. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#include <math.h>

int mapHeight = 50100;
int bufferHeight = 200;
int sectionHeight = 500;
int holeSize = 20;
int ballSize = 25;
int speed = 2;

NSTimer * timer;
bool r;
bool l;

@interface ViewController ()
@property (nonatomic, weak) UIView* myView;
@property (nonatomic, weak) UIView* ballView;
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) NSTimer * speedTimer;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) NSMutableArray *holeArray;
@property (strong, nonatomic) NSTimer *ballMoveTimer;


@end


@implementation ViewController

- (NSMutableArray *)holeArray {
    if (!_holeArray) {
        _holeArray = [[NSMutableArray alloc] init];
    }
    return _holeArray;
}

- (void)viewWillAppear:(BOOL)animated{
    
    self.rightButton.enabled = NO;
    self.leftButton.enabled = NO;
    self.startButton.enabled = YES;
    self.startButton.enabled = NO;

    [self startGame];
    
    
    UIView* myView=[[UIView alloc] initWithFrame:CGRectMake(0, -mapHeight+self.view.frame.size.height, self.view.frame.size.width, mapHeight)];
    self.view.backgroundColor=[UIColor greenColor];
    [self.view addSubview:myView];
    self.myView = myView;
    [self.view sendSubviewToBack:myView];
    
    UILabel *instructionsLabelLeft =  [[UILabel alloc] initWithFrame: CGRectMake(0,mapHeight-self.view.frame.size.height,self.view.frame.size.width/2,self.view.frame.size.height)];
    instructionsLabelLeft.text = @"Tap to Move Left"; //etc...
    [self.myView addSubview:instructionsLabelLeft];
    [[instructionsLabelLeft layer] setBackgroundColor: [[UIColor redColor] CGColor]];
    //instructionsLabelLeft.lineBreakMode = NSLineBreakByWordWrapping;
    instructionsLabelLeft.numberOfLines = 0;
    instructionsLabelLeft.textAlignment = NSTextAlignmentCenter;
    
    UILabel *instructionsLabelRight =  [[UILabel alloc] initWithFrame: CGRectMake(self.view.frame.size.width/2,mapHeight-self.view.frame.size.height,self.view.frame.size.width/2,self.view.frame.size.height)];
    instructionsLabelRight.text = @"Tap to Move Right"; //etc...
    [self.myView addSubview:instructionsLabelRight];
    [[instructionsLabelRight layer] setBackgroundColor: [[UIColor yellowColor] CGColor]];
    instructionsLabelRight.textAlignment = NSTextAlignmentCenter;
    
    
    //for(int n=1; n<=(mapHeight-bufferHeight)/sectionHeight; n++){
    for(int n=1; n<=((mapHeight-bufferHeight)/sectionHeight); n++){
        [self buildSection: n ];
    }
    

    
    
    UIView* ballView=[[UIView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-ballSize)/2, self.view.frame.size.height - ballSize*2, ballSize,ballSize)];
    ballView.backgroundColor=[UIColor blueColor];
    [self.view addSubview:ballView];
    self.ballView = ballView;
    self.ballView.layer.cornerRadius=ballSize/2;
    
    self.ballView.layer.zPosition = 1;
}

- (bool) viewsDoCollide:(UIView *)view1 and:(UIView *)view2{
    CGRect myRect = CGRectMake(view1.frame.origin.x, view1.frame.origin.y+self.myView.frame.origin.y, view1.frame.size.width, view1.frame.size.height);
    if(CGRectIntersectsRect(myRect, view2.frame))
    {
        return 1;
    }
    return 0;
}

- (bool) viewsDoHolesCollide:(UIView *)view1 and:(UIView *)view2{
    if(CGRectIntersectsRect(view1.frame, view2.frame))
    {
        return 1;
    }
    return 0;
}

- (void) buildSection: (int) n {
    double v = ceil(log1p(n))*5;
    for (int p=0; p< (int) v; p++){
        int y = (mapHeight-bufferHeight-self.view.frame.size.height) - (arc4random() % (sectionHeight-holeSize) + (n-1)*sectionHeight + holeSize);
        int x = arc4random() % (int) (self.myView.frame.size.width-holeSize);
        [self addHole:x and: y];
        
       
        
    }
}

- (void) addHole:(int) x
             and:(int) y
{
    
    UIView* hole1=[[UIView alloc] initWithFrame:CGRectMake(x, y, holeSize, holeSize)];
    hole1.backgroundColor=[UIColor blackColor];
    [self.myView addSubview:hole1];
    [self.holeArray addObject:hole1];
}

//
- (void) tick:(NSTimeInterval)time {
    self.myView.frame=CGRectMake(0, self.myView.frame.origin.y+speed, self.myView.frame.size.width, self.myView.frame.size.height);
//    NSArray *blocks = [self.myView subviews];
    for (UIView *v in self.holeArray) {
        //if( v.frame.origin.y>self.myView.frame.size.height/2 && v.frame.origin.y<self.myView.frame.size.height){
          //  NSLog(@"Rect: %f %f", v.frame.origin.x, v.frame.origin.y );
         //   NSLog(@"Ball: %f %f", self.ballView.frame.origin.x, self.ballView.frame.origin.y);
            if([self viewsDoCollide:v and: self.ballView]){
                speed = 0;
                //NSLog(@"COLLISION");
                [self gameOver];
                
            }
       // }
    }
    //NSLog(@"%f, %f", ((UIView *)self.myView.subviews[0]).frame.origin.x,((UIView *)self.myView.subviews[0]).frame.origin.y);
}

- (void) gameOver {
    [self.ballMoveTimer invalidate];
    self.rightButton.enabled = NO;
    self.leftButton.enabled = NO;
    
    NSLog(@"Game Over! Score: %f", self.myView.frame.origin.y+mapHeight);
    [self.speedTimer invalidate];
    UIView* gameOverView=[[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-120, self.view.frame.size.height/2-120, 240,240)];
    gameOverView.backgroundColor=[UIColor redColor];
    [self.view addSubview:gameOverView];
    
    UILabel *gameOverLabel =  [[UILabel alloc] initWithFrame: CGRectMake(0,0,gameOverView.frame.size.width,gameOverView.frame.size.height/2)];
    gameOverLabel.text = @"Game Over!"; //etc...
    [gameOverView addSubview:gameOverLabel];
    ;
    gameOverLabel.textAlignment = NSTextAlignmentCenter;
    [gameOverLabel setFont:[UIFont systemFontOfSize:30]];

    
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame: CGRectMake(0,0,gameOverView.frame.size.width,gameOverView.frame.size.height)];
    scoreLabel.text = [NSString stringWithFormat: @"Score: %d", (int)self.myView.frame.origin.y+mapHeight-bufferHeight];
    [gameOverView addSubview:scoreLabel];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    [scoreLabel setFont:[UIFont systemFontOfSize:20]];
    
    UILabel *playAgainLabel =  [[UILabel alloc] initWithFrame: CGRectMake(0,gameOverView.frame.size.height/2,gameOverView.frame.size.width,gameOverView.frame.size.height/2)];
    playAgainLabel.text = @"Tap to Play Again"; //etc...
    [gameOverView addSubview:playAgainLabel];
    ;
    playAgainLabel.textAlignment = NSTextAlignmentCenter;
    [playAgainLabel setFont:[UIFont systemFontOfSize:20]];

    
    UIButton *playAgain =  [UIButton buttonWithType:UIButtonTypeSystem];
    [playAgain setTitle:@"" forState:UIControlStateNormal];
    playAgain.frame=CGRectMake(0, 0, gameOverView.frame.size.width, gameOverView.frame.size.height);
    [gameOverView addSubview:playAgain];
    [playAgain addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];

}
-(void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void) startGame {
    NSLog(@"button tapped");
    speed=2;
    self.rightButton.enabled = YES;
    self.leftButton.enabled = YES;
    self.startButton.enabled = NO;
    /*[UIView animateWithDuration:30
                     animations:^(){
                         self.myView.frame=CGRectMake(0, mapHeight, self.myView.frame.size.width, self.myView.frame.size.height);
                         NSArray *blocks = [self.myView subviews];
                         for (UIView *v in blocks) {
                             [self viewsDoCollide:self.myView.subviews.v and: self.ballView];

                         }
                     }];
     */
    [self.speedTimer invalidate];
    self.speedTimer = [NSTimer scheduledTimerWithTimeInterval:0.005
                                     target:self
                                   selector:@selector(tick:)
                                   userInfo:nil
                                    repeats:YES];
    
}



@synthesize timer;

-(void)viewDidLoad {
    r = false;
    l = false;
    self.ballMoveTimer =[NSTimer scheduledTimerWithTimeInterval:0.006
                                     target:self
                                   selector:@selector(moveBall:)
                                   userInfo:nil
                                    repeats:YES];
}

-(IBAction)theTouchDownRight {
    r = true;
}

-(IBAction)theTouchUpInsideRight {
    r = false;
}

-(IBAction)theTouchUpOutsideRight {
    r = false;
}

-(IBAction)theTouchDownLeft {
    l = true;
}

-(IBAction)theTouchUpInsideLeft {
    l = false;
}

-(IBAction)theTouchUpOutsideLeft {
    l = false;
}

- (void) moveBall:(id)sender {
    int newPos;
    if (r == true){
        newPos = self.ballView.center.x+2;
        if(newPos<self.view.bounds.size.width-ballSize/2)
            self.ballView.center=CGPointMake(newPos, self.ballView.center.y);
    }
    else if (l == true){
        newPos = self.ballView.center.x-2;
        if(newPos>ballSize/2)
            self.ballView.center=CGPointMake(newPos, self.ballView.center.y);
    }
}






@end
