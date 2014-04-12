//
//  ViewController.m
//  First/Users/mitchellrpatin/Documents/First/First.xcodeproj
//
//  Created by Mitchell Patin on 4/11/14.
//  Copyright (c) 2014 Mitchell Patin. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

int mapHeight = 5100;
int bufferHeight = 100;
int sectionHeight = 500;
int holeSize = 20;
int ballSize = 30;
int speed = 1;

NSTimer * timer;
bool r;
bool l;

@interface ViewController ()
@property (nonatomic, weak) UIView* myView;
@property (nonatomic, weak) UIView* ballView;
@property (nonatomic, retain) NSTimer * timer;


@end


@implementation ViewController

- (void)viewWillAppear:(BOOL)animated{
    UIView* myView=[[UIView alloc] initWithFrame:CGRectMake(0, -mapHeight+self.view.frame.size.height, self.view.frame.size.width, mapHeight)];
    self.view.backgroundColor=[UIColor greenColor];
    [self.view addSubview:myView];
    self.myView = myView;
    [self.view sendSubviewToBack:myView];
    
    //for(int n=1; n<=(mapHeight-bufferHeight)/sectionHeight; n++){
    for(int n=1; n<=12; n++){
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

- (void) buildSection: (int) n {
    for (int p=0; p<n; p++){
        int y = (mapHeight-bufferHeight) - (arc4random() % (sectionHeight-holeSize) + (n-1)*sectionHeight + holeSize);
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
}


- (void) tick:(NSTimeInterval)time {
    self.myView.frame=CGRectMake(0, self.myView.frame.origin.y+speed, self.myView.frame.size.width, self.myView.frame.size.height);
    NSArray *blocks = [self.myView subviews];
    for (UIView *v in blocks) {
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
    NSLog(@"Game Over! Score: %f", self.myView.frame.origin.y+mapHeight);
}
- (IBAction)button1:(id)sender {
    NSLog(@"button tapped");
    /*[UIView animateWithDuration:30
                     animations:^(){
                         self.myView.frame=CGRectMake(0, mapHeight, self.myView.frame.size.width, self.myView.frame.size.height);
                         NSArray *blocks = [self.myView subviews];
                         for (UIView *v in blocks) {
                             [self viewsDoCollide:self.myView.subviews.v and: self.ballView];

                         }
                     }];
     */
    [NSTimer scheduledTimerWithTimeInterval:0.05
                                     target:self
                                   selector:@selector(tick:)
                                   userInfo:nil
                                    repeats:YES];
    
}



@synthesize timer;

-(void)viewDidLoad {
    r = false;
    l = false;
    [NSTimer scheduledTimerWithTimeInterval:0.006
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
