//
//  TheoriesViewController.m
//  HelioRoom
//
//  Created by admin on 1/18/13.
//  Copyright (c) 2013 Learning Technologies Group. All rights reserved.
//

#import "TheoriesViewController.h"
#import "AppDelegate.h"


@interface TheoriesViewController ()
@property (nonatomic,strong) PlanetObservationModel *planetModel;
@end

@implementation TheoriesViewController
@synthesize reasonPopover = _reasonPopover;
@synthesize allDropAreas = _allDropAreas;
@synthesize mercuryDropArea =_mercuryDropArea;
@synthesize venusDropArea = _venusDropArea;
@synthesize earthDropArea = _earthDropArea;
@synthesize marsDropArea = _marsDropArea;
@synthesize jupiterDropArea = _jupiterDropArea;
@synthesize saturnDropArea = _saturnDropArea;
@synthesize uranusDropArea = _uranusDropArea;
@synthesize neptuneDropArea = _neptuneDropArea;
//@synthesize plutoDropArea = _plutoDropArea;

//@synthesize reasonViewController = _reasonViewController;

-(PlanetObservationModel *)planetModel{
    if(!_planetModel) _planetModel=[[PlanetObservationModel alloc] init];
    return _planetModel;
}

- (NSMutableArray *) allDropAreas{
    if(!_allDropAreas) _allDropAreas=[[NSMutableArray alloc] initWithObjects:mercuryDrop,venusDrop,earthDrop,marsDrop,jupiterDrop,saturnDrop,uranusDrop,neptuneDrop, nil];
    return _allDropAreas;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mercuryDropArea = [[NSMutableArray alloc] initWithCapacity:5];
    self.venusDropArea = [[NSMutableArray alloc] initWithCapacity:5];
    self.earthDropArea = [[NSMutableArray alloc] initWithCapacity:5];
    self.marsDropArea = [[NSMutableArray alloc] initWithCapacity:5];
    self.jupiterDropArea = [[NSMutableArray alloc] initWithCapacity:5];
    self.saturnDropArea = [[NSMutableArray alloc] initWithCapacity:5];
    self.uranusDropArea = [[NSMutableArray alloc] initWithCapacity:5];
    self.neptuneDropArea = [[NSMutableArray alloc] initWithCapacity:5];
    //self.plutoDropArea = [[NSMutableArray alloc] initWithCapacity:5];
    
    
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Default Reason Database"];
    [self.planetModel setReasonDatabase:[[UIManagedDocument alloc] initWithFileURL:url]]; // setter will create this for us on disk
    self.planetModel.othersTheoryDelegate=self;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

//EVENT HANDLERS
- (IBAction)planetDragInside:(UIButton *)sender forEvent:(UIEvent *)event {
    
    //  NSString * planetName = [self tagToPlanet:sender.tag];
    
    //NSLog(@"drag inside event");
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    sender.center=point;

    
    [[self appDelegate] writeDebugMessage:@"drag inside event"];
}

- (IBAction)planetTouchUpInside:(UIButton *)sender forEvent:(UIEvent *)event  {
    
    //if in view area of planet. Create new button
    UIButton * newPlanet =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [newPlanet setTitle:[self getPlanetColor:sender.tag] forState:UIControlStateNormal];
    CGPoint dropLocation=[self isValidDrop:sender :event :newPlanet];
    if(dropLocation.x !=0){
        [newPlanet setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [newPlanet setBackgroundImage:[UIImage imageNamed:[self getPlanetImage:sender.tag]] forState:UIControlStateNormal];
        [newPlanet setFrame:CGRectMake(0,0,78, 78)];
        [newPlanet addTarget:self action:@selector(createdPlanetDragInside:forEvent:) forControlEvents:UIControlEventTouchDragInside];
        [newPlanet addTarget:self action:@selector(createdPlanetTouchUpInside:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:newPlanet];
       // CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
        newPlanet.center=dropLocation;
        //create popover event
        NSString * dropPlanetName = [self getDropAreaName:sender :event];
        [self createdPlanetPopover:newPlanet :dropPlanetName];//TODO change to proper destination
        [sender setAlpha:0];
        [sender setUserInteractionEnabled:NO];
    }
    //else do nothing
    
}

- (IBAction)createdPlanetDragInside:(UIButton *)sender forEvent:(UIEvent *)event{
    //TODO : remove??
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    sender.center=point;
    
    
    [[self appDelegate] writeDebugMessage:@"created planet drag inside event"];
}
- (IBAction)createdPlanetTouchUpInside:(UIButton *)sender forEvent:(UIEvent *)event {
    //Get previous reason popover and display.
    [[self appDelegate] writeDebugMessage:@"created planet touch up inside event"];
//    
//    if([self getCurrentArea:sender :event]== -1){//outside drop areas
//        //remove planet from drop area and view
//        [sender removeFromSuperview];
        [self.view viewWithTag:[self getTag:sender.currentTitle]].userInteractionEnabled=YES;
        [self.view viewWithTag:[self getTag:sender.currentTitle]].alpha=1;
//    }else{
//        [self.view addSubview:sender];//reload view
//        //sender restore to original place
//    }
    
}
//HELPER FUNCTIONS
 -(void) createdPlanetPopover:(UIButton *)created:(NSString *)planet{
     //popover with reasons and delete option.
     TheoryReasonViewController *reasonViewController=[self.storyboard instantiateViewControllerWithIdentifier:@"theoryReason"];
     [reasonViewController setName:created.titleLabel.text :planet];
     [reasonViewController.view setNeedsDisplay];
     
     UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:reasonViewController];
     reasonViewController.delegate=self;
     self.reasonPopover = [[UIPopoverController alloc] initWithContentViewController:nav];
     self.reasonPopover.passthroughViews = [[NSArray alloc] initWithObjects:self.view, nil];
     [self.reasonPopover presentPopoverFromRect:created.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
     
 }
//-(int)getCurrentArea:(UIButton *)sender:(UIEvent *)event{
//    for (UIImageView *dropArea in self.allDropAreas){
//        CGPoint pointInDropView = [[[event allTouches] anyObject] locationInView:dropArea];
//        int i=1;
//        if ([dropArea pointInside:pointInDropView withEvent:nil]) {
//            NSMutableArray * dropArea = [self getDropArea:i];
//            for (UIButton *createdPlanet in dropArea){
//                if([createdPlanet.titleLabel.text isEqualToString:sender.titleLabel.text]){
//                    //color already present
//                    [[self appDelegate] writeDebugMessage:@"dropped in same drop area"];
//                    //TODO: What about others classmates count
//                    return i;
//                }
//            }
//            NSLog(@"in area i=%d",i);
//            return i;
//        }
//        i++;
//    }
//    return -1;
//}
-(NSString *)getPlanetImage:(NSInteger)tag{
    int tagInt =tag;
    //printf("tag is %d\n",tagInt);
    switch (tagInt) {
        case 1:return @"redLg.png";
        case 2:return @"blueLg.png";
        case 3:return @"yellowLg.png";
        case 4:return @"orangeLg.png";
        case 5:return @"brownLg.png";
        case 6:return @"pinkLg.png";
        case 7:return @"greenLg.png";
        case 8:return @"purpleLg.png";
            
        default:
            return @"An error occured in getPlanetImage";
    }
    return @"An error occured in getPlanetImage";
}
-(NSString *)getPlanetColor:(NSInteger)tag{
    int tagInt =tag;
    //printf("tag is %d\n",tagInt);
    switch (tagInt) {
        case 1:return @"red";
        case 2:return @"blue";
        case 3:return @"yellow";
        case 4:return @"orange";
        case 5:return @"brown";
        case 6:return @"pink";
        case 7:return @"green";
        case 8:return @"purple";
            
        default:
            return @"An error occured in getPlanetImage";
    }
    return @"An error occured in getPlanetImage";
}
-(int)getTag:(NSString *)name{
        if([name isEqualToString: @"red"])
            return 1;
        else if([name isEqualToString: @"blue"])
            return 2;
        else if([name isEqualToString: @"yellow"])
            return 3;
        else if([name isEqualToString: @"orange"])
            return 4;
        else if([name isEqualToString: @"brown"])
            return 5;
        else if([name isEqualToString: @"pink"])
            return 6;
        else if([name isEqualToString: @"green"])
            return 7;
        else if([name isEqualToString: @"purple"])
            return 8;
    
    return -100;//error
}

-(NSMutableArray *)getDropArea:(int)i{
    //printf("tag is %d\n",tagInt);
    switch (i) {
        case 1:return self.mercuryDropArea;
        case 2:return self.venusDropArea;
        case 3:return self.earthDropArea;
        case 4:return self.marsDropArea;
        case 5:return self.jupiterDropArea;
        case 6:return self.saturnDropArea;
        case 7:return self.uranusDropArea;
        case 8:return self.neptuneDropArea;
        //case 9:return self.plutoDropArea;
            
        default:
            return nil;
    }
    return nil;
}
-(CGPoint)isValidDrop:(UIButton *)sender:(UIEvent *)event:(UIButton *)newPlanet{
    UIControl *control = sender;
    BOOL droppedViewInKnownArea = NO;
    int i=1;
    for (UIImageView *dropArea in self.allDropAreas){
        CGPoint pointInDropView = [[[event allTouches] anyObject] locationInView:dropArea];
        if ([dropArea pointInside:pointInDropView withEvent:nil]) {
            droppedViewInKnownArea =YES;
            //check not drop on top of other planet guess
            CGPoint dropAreaPlacement = [self getDropAreaOpening:i:newPlanet];
            if(dropAreaPlacement.x ==0 || dropAreaPlacement.y==-1){
                printf("drop area not open");
                droppedViewInKnownArea=NO;
                [self.view addSubview:sender];
                return dropAreaPlacement;
            }else{
                control.center = dropArea.center;
                CGRect frame = control.frame;
                [sender setFrame:frame];
                [[self appDelegate] writeDebugMessage:@"was in valid drop area!"];
                //control.center = dropAreaPlacement;
                return dropAreaPlacement;
            }
        }
        i++;
    }
    if (!droppedViewInKnownArea) {
//        CGRect frame = sender.frame;
//        frame.origin=[self getOriginalNameLocation:planetName];
//        control.frame =frame;
        [[self appDelegate] writeDebugMessage:@"was not in drop area"];
        [self.view addSubview:sender];
        return CGPointMake(0, 0); 
    }
    
}
-(NSString *)getDropAreaName:(UIButton *)sender:(UIEvent *)event{
    UIControl *control = sender;
    int i=1;
    for (UIImageView *dropArea in self.allDropAreas){
        CGPoint pointInDropView = [[[event allTouches] anyObject] locationInView:dropArea];
        if (![dropArea pointInside:pointInDropView withEvent:nil]) {
            i++;
        }
        
    }
    switch (i) {
        case 1:return @"Mercury";
        case 2:return @"Venus";
        case 3:return @"Earth";
        case 4:return @"Mars";
        case 5:return @"Jupiter";
        case 6:return @"Saturn";
        case 7:return @"Uranus";
        case 8:return @"Neptune";
            
        default:
            return @"Error: drop area name unrecognized.";
    }
    
    
}

-(CGPoint)getDropAreaOpening:(int) i:(UIButton *)newPlanet{
    //iterate and see next open space
    //else return nil;
    NSMutableArray * dropArea = [self getDropArea:i];
    float j=0;
    for (UIButton *createdPlanet in dropArea){
        if([createdPlanet.titleLabel.text isEqualToString:newPlanet.titleLabel.text]){
            //color already present
            [[self appDelegate] writeDebugMessage:@"color already in drop area"];
             return CGPointMake(0, -1);
        }
        j++;
    }
    if(j<=4){//can add another button
        CGFloat x = 170.0 + j*100.0;
        CGFloat y = 14.0 + i*76.0;
        [dropArea addObject:newPlanet];
        return CGPointMake(x,y);  
    }
    return CGPointMake(0, 0);
}

#pragma mark - TheoryReason Popover delegate methods
//Delegate Functions
-(void) cancel{
    [self.reasonPopover dismissPopoverAnimated:YES];
}
- (void)reasonSelected:(NSString *)reason:(NSString *) planetColor:(NSString *)planetName{
    
    NSLog(@"reason %@ color: %@ name:%@",reason,planetColor,planetName);
    [[self planetModel] identify:planetColor :planetName :reason];
    //[[self planetModel] orderReasonGroupMessage:reason];
    [self.reasonPopover dismissPopoverAnimated:YES];
    
}

#pragma mark - OthersTheory delegate methods
- (void)addOthersTheory:(NSString *) color:(NSString *) anchor:(NSString *)reason{
     NSLog(@"Another Students Theory: \n reason %@ color: %@ name:%@",reason,color,anchor);
}
@end
