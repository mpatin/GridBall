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
int score = 0;
int sectionNum = 1;

bool r;
bool l;

@interface ViewController ()

// propery views
@property (nonatomic, weak) UIView* fieldView;
@property (nonatomic, weak) UIView* sectionView;
@property (nonatomic, weak) UIView* ballView;

// property timers
@property (nonatomic, strong) NSTimer *refreshTimer;
@property (strong, nonatomic) NSTimer *ballMoveTimer;

// property buttons
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

// property array to store view obstacles
@property (strong, nonatomic) NSMutableArray *holeArray;
@property (strong, nonatomic) NSMutableArray *sectionsArray;

// propery labels
@property (weak, nonatomic) UILabel *rightInstructionLabel;
@property (weak, nonatomic) UILabel *leftInstructionLabel;
@property (weak, nonatomic) UILabel *topTitle;
@property (weak, nonatomic) IBOutlet UILabel *currentScoreLabel;

@property (weak, nonatomic) IBOutlet UIView *gameOverView;

@end


@implementation ViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

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
                    
    self.view.backgroundColor=[UIColor blackColor];  // set background color
    [self.view addSubview:fieldView];                // make a sub view of super view
    self.fieldView = fieldView;                      // define property
    [self.view sendSubviewToBack:fieldView];         // send below buttons
                       
    // create instructions labels
    // ----------------------------------------------------------------------------------------
    UILabel *instructionsLabelLeft =  [[UILabel alloc] initWithFrame: CGRectMake(0,mapHeight-self.view.frame.size.height+215,self.view.frame.size.width/2,self.view.frame.size.height-225)];
                       
        // set left label parameters
    instructionsLabelLeft.text = @"Tap Here to Move Left";
    [self.fieldView addSubview:instructionsLabelLeft];
    [[instructionsLabelLeft layer] setBackgroundColor: [[UIColor whiteColor] CGColor]];
    instructionsLabelLeft.numberOfLines = 2;
    instructionsLabelLeft.textAlignment = NSTextAlignmentCenter;
    self.leftInstructionLabel = instructionsLabelLeft;
    
    UILabel *instructionsLabelRight =  [[UILabel alloc] initWithFrame: CGRectMake(self.view.frame.size.width/2,mapHeight-self.view.frame.size.height+215,self.view.frame.size.width/2,self.view.frame.size.height-225)];
                       
        // set left label parameters
    instructionsLabelRight.text = @"Tap Here to Move Right";
    [self.fieldView addSubview:instructionsLabelRight];
    instructionsLabelRight.numberOfLines = 2;
    [[instructionsLabelRight layer] setBackgroundColor: [[UIColor greenColor] CGColor]];
    instructionsLabelRight.textAlignment = NSTextAlignmentCenter;
    self.rightInstructionLabel = instructionsLabelRight;
    
    UILabel *topTitle =  [[UILabel alloc] initWithFrame: CGRectMake(0,0,self.view.frame.size.width,100)];
    
    // set left label parameters
    topTitle.text = @"Cube Juke";
    [self.fieldView addSubview:topTitle];
    [[topTitle layer] setBackgroundColor: [[UIColor blackColor] CGColor]];
    topTitle.textAlignment = NSTextAlignmentCenter;
    self.topTitle = topTitle;
    
    // ----------------------------------------------------------------------------------------


    // place obstacles on field
    //for(int n=1; n<=((mapHeight-bufferHeight)/sectionHeight); n++){
    for(int n=1; n<=5; n++){
        [self buildSection: n ];
    }
    

    // create user ball
    UIView* ballView=[[UIView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-ballSize)/2, self.view.frame.size.height - ballSize*2, ballSize,ballSize)];
    
        // set user ball parameters
    ballView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:ballView];
    self.ballView = ballView;
    self.ballView.layer.cornerRadius=ballSize/2;
    self.ballView.layer.zPosition = 1;
}


// method to place obstacle views in field section
- (UIView*) buildSection: (int) n {
    UIView* sectionView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.bounds.size.width, sectionHeight)];
    double v = ceil(log1p(n))*5;
    
    // place number of obstacles for inputted section number based on natural log function
    for (int p=0; p < (int) v; p++){
        int y =  arc4random() % (sectionHeight-holeSize);
        int x = arc4random() % (int)(self.view.bounds.size.width - holeSize);
        [self addHole: sectionView on: x and: y];
    }
    //sectionView.backgroundColor = [UIColor greenColor];
    return sectionView;
}

// method to add hole in section
- (void) addHole: (UIView *) currentView
              on:(int) x
             and:(int) y
{
    // create new hole
    UIView* hole1=[[UIView alloc] initWithFrame:CGRectMake(x, y, holeSize, holeSize)];
    
    // set hole parameters
    hole1.backgroundColor=[UIColor greenColor];
    [currentView addSubview:hole1];
}

// when game first begins
- (void) startGame {
    
    score=0;
    speed=2; // initialize speed of falling squares
    
    self.sectionsArray = [NSMutableArray array];
    for (sectionNum =1; sectionNum<4; sectionNum++) {
        UIView* section = [self buildSection:sectionNum];
        section.frame = CGRectMake(0, -sectionNum*sectionHeight, section.frame.size.width, sectionHeight);
        [self.sectionsArray addObject:section];
        [self.view addSubview:section];
        [self.view sendSubviewToBack:section];
    }
    
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
    UIView *sect = [self.sectionsArray firstObject];
    CGRect ballRect = CGRectMake(view1.frame.origin.x, view1.frame.origin.y+sect.frame.origin.y, view1.frame.size.width, view1.frame.size.height);
    
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

// on each tick check for collisions to end game
- (void) tick:(NSTimeInterval)time {
    
    
    self.leftInstructionLabel.frame = CGRectMake(0, self.leftInstructionLabel.frame.origin.y+speed, self.leftInstructionLabel.frame.size.width, self.leftInstructionLabel.frame.size.height);
    
    self.rightInstructionLabel.frame = CGRectMake(self.view.bounds.size.width/2, self.rightInstructionLabel.frame.origin.y+speed, self.rightInstructionLabel.frame.size.width, self.rightInstructionLabel.frame.size.height);
    
    score+=1; // increment user score on each tick
    self.currentScoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];

    
    for (UIView *sect in self.sectionsArray) {
        sect.frame = CGRectMake(0, sect.frame.origin.y+speed, sect.frame.size.width, sect.frame.size.height);
    }
    
    UIView *bottom = [self.sectionsArray firstObject];
    if(bottom.frame.origin.y>self.view.bounds.size.height){
        [bottom removeFromSuperview];
        [self.sectionsArray removeObject: bottom];
        NSLog(@"%@", @"Deleted");
        UIView* section = [self buildSection:sectionNum];
        section.frame = CGRectMake(0, self.view.bounds.size.height-1500, section.frame.size.width, sectionHeight);
        [self.sectionsArray addObject:section];
        [self.view addSubview:section];
        [self.view bringSubviewToFront:self.rightButton];
        [self.view bringSubviewToFront:self.leftButton];
        sectionNum++; // increment section count
    }
    
    UIView *sect = [self.sectionsArray firstObject];
    for (UIView *block in sect.subviews) {
        if([self viewsDoCollide:block and: self.ballView]){
            speed = 0;
            [self gameOver];
        }
    }
    
    //move the ball
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


// When the user lost, display score and allow for playing again
- (void) gameOver {
    self.gameOverView.hidden = NO;
    [self.view bringSubviewToFront:self.gameOverView];
    
    //save the score
    
    int hs = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
    
    if(score>hs){
        [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"highScore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // invalidate timer, enable/disable appropriate buttons
    [self.ballMoveTimer invalidate];
    [self.refreshTimer invalidate];
    self.rightButton.enabled = NO;
    self.leftButton.enabled = NO;
    
    
    // create view for game over screen
    //int w = 3 * self.view.frame.size.width / 4;
    //int h = self.view.frame.size.height / 4;
    
   // UIView* gameOverView=[[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - w/2, self.view.frame.size.height/2 - h/2, w, h)];
    
    // set game over view parameters
    self.gameOverView.backgroundColor=[UIColor whiteColor];
  //  [self.view addSubview:gameOverView];
    
    
    
    // create labels for game over view
    // ----------------------------------------------------------------------------------------
    
    
    // display "game over" in a label
    UILabel *gameOverLabel =  [[UILabel alloc] initWithFrame: CGRectMake(0,0,self.gameOverView.frame.size.width,self.gameOverView.frame.size.height/2)];
    
        // set gameover label parameters
    gameOverLabel.text = @"Game Over!"; //etc...
    [self.gameOverView addSubview:gameOverLabel];
    gameOverLabel.textAlignment = NSTextAlignmentCenter;
    [gameOverLabel setFont:[UIFont systemFontOfSize:28]];

    // display user score in a label
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame: CGRectMake(0,0,self.gameOverView.frame.size.width,self.gameOverView.frame.size.height)];
    
        // set score label parameters
    scoreLabel.text = [NSString stringWithFormat: @"Score: %d", score];
    [self.gameOverView addSubview:scoreLabel];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    [scoreLabel setFont:[UIFont systemFontOfSize:20]];
    
    // display prompt for user to play again
    UILabel *playAgainLabel =  [[UILabel alloc] initWithFrame: CGRectMake(0,self.gameOverView.frame.size.height/2,self.gameOverView.frame.size.width,self.gameOverView.frame.size.height/2)];
    
        // set play again label parameters
    playAgainLabel.text = @"Tap to Play Again";
    [self.gameOverView addSubview:playAgainLabel];
    playAgainLabel.textAlignment = NSTextAlignmentCenter;
    [playAgainLabel setFont:[UIFont systemFontOfSize:20]];
    
    
    // ----------------------------------------------------------------------------------------
    
    
    // create button to play again (back to main menu)
    UIButton *playAgain =  [UIButton buttonWithType:UIButtonTypeSystem];
    
        // set play again button parameters
    [playAgain setTitle:@"" forState:UIControlStateNormal];
    playAgain.frame=CGRectMake(0, 0, self.gameOverView.frame.size.width, self.gameOverView.frame.size.height);
    [self.gameOverView addSubview:playAgain];
    [playAgain addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];

}

// go back to main menu
-(void)goBack
{
    [self dismissViewControllerAnimated:NO completion:nil];
}




// FUNCTIONS TO MOVE THE USER BALL

// initialize ball move timer
-(void)viewDidLoad {
    r = false;
    l = false;
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
