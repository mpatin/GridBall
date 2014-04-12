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

int mapHeight = 50200;
int bufferHeight = 200;
int sectionHeight = 500;
int holeSize = 20;
int ballSize = 25;
int speed = 2;

NSTimer * timer;
bool r;
bool l;

@interface ViewController ()

// propery views
@property (nonatomic, weak) UIView* fieldView;
@property (nonatomic, weak) UIView* ballView;

// property timers
@property (nonatomic, strong) NSTimer * timer;
@property (nonatomic, strong) NSTimer * refreshTimer;
@property (strong, nonatomic) NSTimer *ballMoveTimer;

// property buttons
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

// property array to store view obstacles
@property (strong, nonatomic) NSMutableArray *holeArray;


@end


@implementation ViewController


// array initializer to be able to reference and add objects
- (NSMutableArray *)holeArray {
    if (!_holeArray) {
        _holeArray = [[NSMutableArray alloc] init];
    }
    return _holeArray;
}

// from main menu first tap
- (void)viewWillAppear:(BOOL)animated{
    
    // enable and disable appropriate buttons
    self.rightButton.enabled = NO;
    self.leftButton.enabled = NO;
    self.startButton.enabled = YES;
    self.startButton.enabled = NO;

    // begin playing game
    [self startGame];
    
    
    // initialize view that squares are drawn on top of
    UIView* fieldView=[[UIView alloc] initWithFrame:CGRectMake(0, -mapHeight+self.view.frame.size.height, self.view.frame.size.width, mapHeight)];
                    
    self.view.backgroundColor=[UIColor greenColor];  // set background color
    [self.view addSubview:fieldView];                // make a sub view of super view
    self.fieldView = fieldView;                      // define property
    [self.view sendSubviewToBack:fieldView];         // send below buttons
                       
    // create instructions labels
    // ----------------------------------------------------------------------------------------
    UILabel *instructionsLabelLeft =  [[UILabel alloc] initWithFrame: CGRectMake(0,mapHeight-self.view.frame.size.height,self.view.frame.size.width/2,self.view.frame.size.height)];
                       
        // set left label parameters
    instructionsLabelLeft.text = @"Tap to Move Left";
    [self.fieldView addSubview:instructionsLabelLeft];
    [[instructionsLabelLeft layer] setBackgroundColor: [[UIColor redColor] CGColor]];
    instructionsLabelLeft.numberOfLines = 0;
    instructionsLabelLeft.textAlignment = NSTextAlignmentCenter;
    
    
    UILabel *instructionsLabelRight =  [[UILabel alloc] initWithFrame: CGRectMake(self.view.frame.size.width/2,mapHeight-self.view.frame.size.height,self.view.frame.size.width/2,self.view.frame.size.height)];
                       
        // set left label parameters
    instructionsLabelRight.text = @"Tap to Move Right";
    [self.fieldView addSubview:instructionsLabelRight];
    [[instructionsLabelRight layer] setBackgroundColor: [[UIColor yellowColor] CGColor]];
    instructionsLabelRight.textAlignment = NSTextAlignmentCenter;
    
    // ----------------------------------------------------------------------------------------


    // place obstacles on field
    for(int n=1; n<=((mapHeight-bufferHeight)/sectionHeight); n++){
        [self buildSection: n ];
    }
    

    // create user ball
    UIView* ballView=[[UIView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-ballSize)/2, self.view.frame.size.height - ballSize*2, ballSize,ballSize)];
    
        // set user ball parameters
    ballView.backgroundColor=[UIColor blueColor];
    [self.view addSubview:ballView];
    self.ballView = ballView;
    self.ballView.layer.cornerRadius=ballSize/2;
    self.ballView.layer.zPosition = 1;
}

// when game first begins
- (void) startGame {
    
    speed=2; // initialize speed of falling squares
    
    // enable and disable appropriate buttons
    self.rightButton.enabled = YES;
    self.leftButton.enabled = YES;
    self.startButton.enabled = NO;
    
    // initialize timer controlling how fast to refresh screen
    [self.refreshTimer invalidate];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.005
                                                       target:self
                                                     selector:@selector(tick:)
                                                     userInfo:nil
                                                      repeats:YES];
    
}

// collision detection between obstacle holes and user ball
- (bool) viewsDoCollide:(UIView *)view1 and:(UIView *)view2{
    
    // put rectangle around user ball for edge detection
    CGRect ballRect = CGRectMake(view1.frame.origin.x, view1.frame.origin.y+self.fieldView.frame.origin.y, view1.frame.size.width, view1.frame.size.height);
    
    // call detection method
    if(CGRectIntersectsRect(ballRect, view2.frame))
    {
        return 1;
    }
    return 0;
}

// collision detection between obstacles during hole placement
- (bool) viewsDoHolesCollide:(UIView *)view1 and:(UIView *)view2{
    if(CGRectIntersectsRect(view1.frame, view2.frame))
    {
        return 1;
    }
    return 0;
}

// method to place obstacle views in field section
- (void) buildSection: (int) n {
    double v = ceil(log1p(n))*5;
    
    // place number of obstacles for inputted section number based on natural log function
    for (int p=0; p< (int) v; p++){
        int y = (mapHeight-bufferHeight-self.view.frame.size.height) - (arc4random() % (sectionHeight-holeSize) + (n-1)*sectionHeight + holeSize);
        int x = arc4random() % (int) (self.fieldView.frame.size.width-holeSize);
        [self addHole:x and: y];
        
       
        
    }
}

// method to add hole in section
- (void) addHole:(int) x
             and:(int) y
{
    // create new hole
    UIView* hole1=[[UIView alloc] initWithFrame:CGRectMake(x, y, holeSize, holeSize)];
    
    // set hole parameters
    hole1.backgroundColor=[UIColor blackColor];
    [self.fieldView addSubview:hole1];
    [self.holeArray addObject:hole1];
}

// on each tick check for collisions to end game
- (void) tick:(NSTimeInterval)time {
    
    self.fieldView.frame=CGRectMake(0, self.fieldView.frame.origin.y+speed, self.fieldView.frame.size.width, self.fieldView.frame.size.height);

    for (UIView *v in self.holeArray) {
            // check for collision between current array element view (obstacle) and ball
            if([self viewsDoCollide:v and: self.ballView]){
                speed = 0;
                [self gameOver];
                
            }
    }
}

// When the user lost, display score and allow for playing again
- (void) gameOver {
    
    // invalidate timer, enable/disable appropriate buttons
    [self.ballMoveTimer invalidate];
    [self.refreshTimer invalidate];
    self.rightButton.enabled = NO;
    self.leftButton.enabled = NO;
    
    
    //NSLog(@"Game Over! Score: %f", self.fieldView.frame.origin.y+mapHeight);
    
    // create view for game over screen
    UIView* gameOverView=[[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-120, self.view.frame.size.height/2-120, 240,240)];
    
    // set game over view parameters
    gameOverView.backgroundColor=[UIColor redColor];
    [self.view addSubview:gameOverView];
    
    
    
    // create labels for game over view
    // ----------------------------------------------------------------------------------------
    
    
    // display "game over" in a label
    UILabel *gameOverLabel =  [[UILabel alloc] initWithFrame: CGRectMake(0,0,gameOverView.frame.size.width,gameOverView.frame.size.height/2)];
    
        // set gameover label parameters
    gameOverLabel.text = @"Game Over!"; //etc...
    [gameOverView addSubview:gameOverLabel];
    gameOverLabel.textAlignment = NSTextAlignmentCenter;
    [gameOverLabel setFont:[UIFont systemFontOfSize:30]];

    // display user score in a label
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame: CGRectMake(0,0,gameOverView.frame.size.width,gameOverView.frame.size.height)];
    
        // set score label parameters
    scoreLabel.text = [NSString stringWithFormat: @"Score: %d", (int)self.fieldView.frame.origin.y+mapHeight-bufferHeight];
    [gameOverView addSubview:scoreLabel];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    [scoreLabel setFont:[UIFont systemFontOfSize:20]];
    
    // display prompt for user to play again
    UILabel *playAgainLabel =  [[UILabel alloc] initWithFrame: CGRectMake(0,gameOverView.frame.size.height/2,gameOverView.frame.size.width,gameOverView.frame.size.height/2)];
    
        // set play again label parameters
    playAgainLabel.text = @"Tap to Play Again";
    [gameOverView addSubview:playAgainLabel];
    playAgainLabel.textAlignment = NSTextAlignmentCenter;
    [playAgainLabel setFont:[UIFont systemFontOfSize:20]];
    
    
    // ----------------------------------------------------------------------------------------
    
    
    // create button to play again (back to main menu)
    UIButton *playAgain =  [UIButton buttonWithType:UIButtonTypeSystem];
    
        // set play again button parameters
    [playAgain setTitle:@"" forState:UIControlStateNormal];
    playAgain.frame=CGRectMake(0, 0, gameOverView.frame.size.width, gameOverView.frame.size.height);
    [gameOverView addSubview:playAgain];
    [playAgain addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];

}

// go back to main menu
-(void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}




// FUNCTIONS TO MOVE THE USER BALL


@synthesize timer;

// initialize ball move timer
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


// top level logic handling for moving user ball based on button presses/holds
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
