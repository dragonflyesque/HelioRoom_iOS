//
//  ScratchPadViewController.m
//  HelioRoom
//
//  Created by admin on 1/31/13.
//  Copyright (c) 2013 Learning Technologies Group. All rights reserved.
//

#import "ScratchPadViewController.h"
#import "AppDelegate.h"


// reset button         -> tag  0
// trash button         -> tag  1
// new textfield button -> tag  3
// mercury-neptune      -> tag 10-17
// red                  -> tag 20
// yellow               -> tag 21
// brown                -> tag 22
// pink                 -> tag 23
// purple               -> tag 24
// green                -> tag 25
// orange               -> tag 26
// blue                 -> tag 27
// new user TextFields start with tag 30

typedef enum
{
    RESET=0,
    TRASH=1,
    BLANK_TEXTFIELD=3,
    MERCURY=10, VENUS, EARTH, MARS, JUPITER, SATURN, URANUS, NEPTUNE,
    RED=20, YELLOW, BROWN, PINK, PURPLE, GREEN, ORANGE, BLUE,
    USER_TEXTFIELDS_BEGIN=30
    
} Tags;


@interface ScratchPadViewController ()
{
    BOOL textFieldsAreLoaded;
}

@property (strong, nonatomic) NSString *strNumUserTextFields;

@end


@implementation ScratchPadViewController

@synthesize planetColorBtns = _planetColorBtns;
@synthesize planetNameBtns = _planetNameBtns;
@synthesize userTextFields = _userTextFields;


/*
 // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 //
 // Overriding setters
 //
 
 -(void)setUserTextFields:(NSMutableArray*)userTextFields
 {
 // make sure we are getting mutable copy so we can add to planetNameBtns
 _userTextFields= [_userTextFields mutableCopy];
 }
 */


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//
//

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"------ initWithCoder");
    if (self = [super initWithCoder:aDecoder])
    {
       // NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // Custom initialization
        _strNumUserTextFields = @"numOfUserTextFields";
        
        //[defaults setInteger:0 forKey:_strNumUserTextFields];   // no user textfields at first launch
        
    // test string version
        //NSLog(@"initWithCoder: set numUserTextFields to 0");
        //[defaults setObject:@"0" forKey:@"test"];
        
        // initialize userTextFields array
        //_userTextFields = _userTextFields?_userTextFields:[[NSMutableArray alloc] init];
        
        textFieldsAreLoaded = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"------ viewDidLoad");
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *hasLaunchedBefore= @"hasLaunchedBefore";
    
    // check if first launch
    if ([defaults boolForKey:hasLaunchedBefore] == YES)
    {
        if (textFieldsAreLoaded == NO)
        {
            
            // initialize userTextFields array
            NSLog(@"------ initializeDefaultData: allocating _userTextFields");
            _userTextFields = _userTextFields?_userTextFields:[[NSMutableArray alloc] init];
            
            // load these before layout occurs (viewDidLoad occurs before viewDidLayoutSubviews
            [self loadTextFields];      // load these only once, because they are actually getting created
            textFieldsAreLoaded = YES;
        }
    }
}

- (void)viewDidLayoutSubviews
{
    NSLog(@"------ viewDidLayoutSubviews");
    [super viewDidLayoutSubviews];
    
    [self initializeDefaultData];
    
    // needs this *here* or else runtime error
    //[self.view layoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"------ viewDidAppear");
    [super viewDidAppear:animated];
    
    //[self initializeDefaultData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self saveDefaultData];                              // save default locations
    [[NSUserDefaults standardUserDefaults] synchronize]; // synchronize to write defaults
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeDefaultData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *hasLaunchedBefore= @"hasLaunchedBefore";
    
    // check if first launch
    if ([defaults boolForKey:hasLaunchedBefore] == YES)
    {
        // load default data here after views are created and added (after viewDidLoad)
        // but before they are shown (before viewDidAppear etc))
        // however, our TouchTextFields are programmatically created and added to the view
        // before in viewDidLoad because layout must occur after they are added
        [self loadDefaultData];
        
        /*
        if (textFieldsAreLoaded == NO)
        {
            [self loadTextFields];      // load these only once, because they are actually getting created
            textFieldsAreLoaded = YES;
        }
         */
    }
    else
    {
        [defaults setBool:YES forKey:hasLaunchedBefore];
        [defaults setInteger:0 forKey:_strNumUserTextFields];   // no user textfields at first launch
        
    // test string version
        //NSLog(@"initializeDefaultData: set numUserTextFields to 0");
    //[defaults setObject:@"0" forKey:@"test"];
    
        [self saveDefaultData];     // if it is then save initial center info for all the buttons
        [self saveOriginalState];   // if it is then save initial center info for all the buttons
        [defaults synchronize];     // write it down
        
        textFieldsAreLoaded = YES;      // first time, so no textFields to load
        //NSLog(@"ScratchPadViewController viewDidLayoutSubviews: First launch!");
        
        // initialize userTextFields array
        NSLog(@"------ initializeDefaultData: allocating _userTextFields");
        _userTextFields = _userTextFields?_userTextFields:[[NSMutableArray alloc] init];
    }
}

/*- (void)initializeDefaultData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // check if first launch
    NSString *hasLaunchedBefore= @"hasLaunchedBefore";
    if ([defaults boolForKey:hasLaunchedBefore] == YES)
    {
        // load default data here after views are created and added (after viewDidLoad)
        // but before they are shown (before viewDidAppear etc))
        [self loadDefaultData];
        [self loadTextFields];
        
        //NSLog(@"ScratchPadViewController viewDidLayoutSubviews: not the first launch!");
    }
    else
    {
        [defaults setBool:YES forKey:hasLaunchedBefore];
        [defaults setInteger:0 forKey:_strNumUserTextFields];   // no user textfields at first launch
        
        // if it is then save initial center info for all the buttons
        [self saveDefaultData];
        
        // set initial number of planet name buttons
        //numPlanetNameBtns = 9;
        //[defaults setInteger:numPlanetNameBtns forKey:_numPlanetNamesStr];
        
        // write it down
        [defaults synchronize];
        
        //NSLog(@"ScratchPadViewController viewDidLayoutSubviews: First launch!");
    }
    
    // initialize userTextFields array
    _userTextFields = _userTextFields?_userTextFields:[[NSMutableArray alloc] init];
}*/


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Delegate implemented methods
//

//
// delegate
-(void)touchTextFieldTouchesMoved:(TouchTextField *)textfield
{
    //NSLog(@"ScratchPadViewController saveTouchTextFieldInfo");
    [self saveTextField:textfield];
    
    if ([self touchTextFieldOverTrash:textfield] == YES)
    {
        _trashBtn.highlighted = YES;
    }
    else
    {
        if (_trashBtn.highlighted == YES)
        {
            _trashBtn.highlighted = NO;
        }
    }
}

//
// delegate
-(void)touchTextFieldTouchesEnded:(TouchTextField *)textfield
{
    //NSLog(@"ScratchPadViewController touchTextFieldTouchesEnded");
    if ([self touchTextFieldOverTrash:textfield] == YES)
    {
        [self moveToTrash:textfield];
        _trashBtn.highlighted = NO;
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Default data handling
// : to ensure that subview (i.e. buttons etc.) information is retained
//   after the Scratch Pad tab is no longer active, app is put in
//   background, or quit
//

-(void)saveDefaultDataForButton:(UIButton *)sender
{
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    
    // saving the position
    NSString *tag = [NSString stringWithFormat:@"%d", [sender tag]];
    NSString *pointString = NSStringFromCGPoint(sender.center);
    [defaults setObject:pointString forKey:tag];
    
    //NSLog(@"ScratchPadViewController saveDefaultDataForButton: %@(%.f,%.f)", tag, sender.center.x, sender.center.y);
}

-(void)loadDefaultDataForButton:(UIButton *)sender
{
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    
    NSString *tag = [NSString stringWithFormat:@"%d", [sender tag]];
    NSString *pointString = [defaults stringForKey:tag];
    CGPoint savedCenter = CGPointFromString(pointString);
    
    [sender setCenter:savedCenter];
    
    //NSLog(@"ScratchPadViewController loadDefaultDataForButton: getCenter (%.f, %.f)", sender.center.x, sender.center.y);
}

-(void)saveTextField:(TouchTextField *)textfield
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *tag = [NSString stringWithFormat:@"%d", [textfield tag]];
    CGPoint origin = textfield.frame.origin;
    CGSize size = textfield.frame.size;
    NSString *textFieldString = [NSString stringWithFormat:@"%.f %.f %.f %.f textFieldString:%@", origin.x, origin.y, size.width, size.height, textfield.text];
    
    [defaults setObject:textFieldString forKey:tag];
    
    //NSLog(@"ScratchPadViewController saveTextField: textfield %@ (%@)", tag, textFieldString);
}

-(void)saveDefaultData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (UIButton *btn in _planetColorBtns)
    {
        NSString *tag = [NSString stringWithFormat:@"%d", [btn tag]];
        NSString *pointString = NSStringFromCGPoint(btn.center);
        [defaults setObject:pointString forKey:tag];
        
        //NSLog(@"ScratchPadViewController saveDefaultData: btn %@ (%.f,%.f)", tag, btn.center.x, btn.center.y);
    }
    
    for (UIButton *btn in _planetNameBtns)
    {
        NSString *tag = [NSString stringWithFormat:@"%d", [btn tag]];
        NSString *pointString = NSStringFromCGPoint(btn.center);
        [defaults setObject:pointString forKey:tag];
        
        //NSLog(@"ScratchPadViewController saveDefaultData: btn %@ (%.f,%.f)", tag, btn.center.x, btn.center.y);
    }
}

//
// save the original state of the static buttons so that they can be reset
-(void)saveOriginalState
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (UIButton *btn in _planetColorBtns)
    {
        NSString *tag = [NSString stringWithFormat:@"orig_%d", [btn tag]];
        NSString *pointString = NSStringFromCGPoint(btn.center);
        [defaults setObject:pointString forKey:tag];
        
        //NSLog(@"ScratchPadViewController saveDefaultData: btn %@ (%.f,%.f)", tag, btn.center.x, btn.center.y);
    }
    
    for (UIButton *btn in _planetNameBtns)
    {
        NSString *tag = [NSString stringWithFormat:@"orig_%d", [btn tag]];
        NSString *pointString = NSStringFromCGPoint(btn.center);
        [defaults setObject:pointString forKey:tag];
        
        //NSLog(@"ScratchPadViewController saveDefaultData: btn %@ (%.f,%.f)", tag, btn.center.x, btn.center.y);
    }
}

-(void)loadDefaultData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // get number of buttons
    //numPlanetNameBtns = [defaults integerForKey:_numPlanetNamesStr];
    
    // load positions for planet color buttons
    for (UIButton *btn in _planetColorBtns)
    {
        NSString *tag = [NSString stringWithFormat:@"%d", [btn tag]];
        NSString *pointString = [defaults stringForKey:tag];
        CGPoint savedCenter = CGPointFromString(pointString);
        
        [btn setCenter:savedCenter];
        //NSLog(@"ScratchPadViewController loadDefaultData: btn %d center(%.f, %.f)", btn.tag, btn.center.x, btn.center.y);
    }
    
    // load positions for planet name buttons
    for (UIButton *btn in _planetNameBtns)
    {
        NSString *tag = [NSString stringWithFormat:@"%d", [btn tag]];
        NSString *pointString = [defaults stringForKey:tag];
        CGPoint savedCenter = CGPointFromString(pointString);
        
        [btn setCenter:savedCenter];
        //NSLog(@"ScratchPadViewController loadDefaultData: btn %d center(%.f, %.f)", btn.tag, btn.center.x, btn.center.y);
    }
}

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Subview creation
//


//
// create a new blank textfield that user can write a label in
-(void)addNewTextField:(UIButton*)button
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    TouchTextField* textfield = [[TouchTextField alloc] initWithFrame:[button frame]];
    int numUserTextFields = [defaults integerForKey:_strNumUserTextFields];
    
    // test string version
    //NSString *numUserTextFieldsS = [defaults stringForKey:@"test"];
    //NSLog(@"ScratchPadViewController loadTextFields: %@ 1 numUserTextFieldsS to load", numUserTextFieldsS);
    
    int tag = USER_TEXTFIELDS_BEGIN + numUserTextFields;
    
    //assign delegate
    textfield.delegate = self;
    //[textfield saveDelegate];
    
    [textfield setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [textfield setText:@"blah blah"];
    //[textfield setTag:(USER_TEXTFIELDS_BEGIN + numUserTextFields - 1)];
    [textfield setTag:tag];
    [textfield setBackground:[UIImage imageNamed:@"tag_gray.png"]];
    textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textfield.textAlignment = NSTextAlignmentCenter;
    
    // add to view, then to array
    [self.view addSubview:textfield];
    [_userTextFields addObject:textfield];
    
    //NSLog(@"ScratchPadViewController addNewTextField: adding textfield to class %@!", NSStringFromClass([self.view class]));
    //NSLog(@"ScratchPadViewController addNewTextField: %d userTextFields", [_userTextFields count]);
    
    textfield.userInteractionEnabled = TRUE;    //make text field editable
    [textfield becomeFirstResponder];           //pop up keyboard
    //NSLog(@"ScratchPadViewController addNewTextField: after responder %@", textfield.text);
    
    // update user defaults
    [defaults setInteger:++numUserTextFields forKey:_strNumUserTextFields];
    [self saveTextField:textfield];
    
    // test string version
    //numUserTextFieldsS = [NSString stringWithFormat:@"%d", numUserTextFields];
    //NSLog(@"ScratchPadViewController addNewTextFields: %@ numUserTextFieldsS to load", numUserTextFieldsS);
    //[defaults setObject:numUserTextFieldsS forKey:@"test"];
    
    //NSLog(@"ScratchPadViewController addNewTextField: %d numUserTextFields", numUserTextFields);
    //NSLog(@"ScratchPadViewController addNewTextField: %d numUserTextFields read from defaults", [defaults integerForKey:_strNumUserTextFields]);
}

//
// load previously created user-defined textfield
-(void)loadTextFields
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int numUserTextFields = [defaults integerForKey:_strNumUserTextFields];
    
    // test string version
    //NSString *numUserTextFieldsS = [defaults stringForKey:@"test"];
    //NSLog(@"ScratchPadViewController loadTextFields: %@ numUserTextFieldsS to load", numUserTextFieldsS);
    
    //NSLog(@"ScratchPadViewController loadTextFields: %d numUserTextFields to load", numUserTextFields);
    //NSLog(@"ScratchPadViewController loadTextFields: strNumUserTextFields = %@", _strNumUserTextFields);
    
    for (int tag=USER_TEXTFIELDS_BEGIN; tag<(USER_TEXTFIELDS_BEGIN+numUserTextFields); tag++)
    {
        NSString *tagString = [NSString stringWithFormat:@"%d", tag];
        NSString *textFieldString = [defaults stringForKey:tagString];
        
        NSArray *components = [textFieldString componentsSeparatedByString:@" textFieldString:"];
        NSArray *compDim = [components[0] componentsSeparatedByString:@" "];
        NSString *text = (NSString *)components[1];
        int x = [compDim[0] integerValue];
        int y = [compDim[1] integerValue];
        int w = [compDim[2] integerValue];
        int h = [compDim[3] integerValue];
    
        TouchTextField* textfield = [[TouchTextField alloc] initWithFrame:CGRectMake(x,y,w,h)];
        
        //assign delegate
        textfield.delegate = self;
        
        [textfield setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
        [textfield setBackground:[UIImage imageNamed:@"tag_gray.png"]];
    
        [textfield setText:text];
        [textfield setTag:tag];
    
        textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textfield.textAlignment = NSTextAlignmentCenter;
    
        [_userTextFields addObject:textfield];
        [self.view addSubview:textfield];
        
       /*
        // constraints
        [self.view addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"|-2-[textfield]"
                              options:0 metrics:nil views:NSDictionaryOfVariableBindings(textfield)]];
        [self.view addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:|-2-[textfield]-2-|"
                              options:0 metrics:nil views:NSDictionaryOfVariableBindings(textfield)]];
        */
 
        textfield.userInteractionEnabled = TRUE;    //make text field editable
        
        //NSLog(@"ScratcPadViewController loadTextField: adding textfield to class %@!", NSStringFromClass([self.view class]));
        
        NSLog(@"ScratchPadViewController loadTextFields: %d) text = %@", tag, text);
        NSLog(@"                                             x,y  = %d,%d", x, y);
        NSLog(@"                                             w,h  = %d,%d", w, h);
        NSLog(@"                                         ==> %d textfields", _userTextFields.count);
    }
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Utilities
//

- (BOOL)touchTextFieldOverTrash:(TouchTextField *) textfield
{
    //NSLog(@"touchTextFieldOverTrash: textfield center = (%.f, %.f)", textfield.center.x, textfield.center.y);
    //NSLog(@"touchTextFieldOverTrash: _trashBtn origin = (%.f, %.f)", _trashBtn.frame.origin.x, _trashBtn.frame.origin.y);
    //NSLog(@"touchTextFieldOverTrash: _trashBtn bounds = %@", NSStringFromCGRect(_trashBtn.bounds));
    
    if (textfield.center.x > _trashBtn.frame.origin.x &&
        textfield.center.x < _trashBtn.frame.origin.x + _trashBtn.frame.size.width &&
        textfield.center.y > _trashBtn.frame.origin.y &&
        textfield.center.y < _trashBtn.frame.origin.y + _trashBtn.frame.size.height)
    {
        return YES;
    }
        
    return NO;
}

- (void) moveToTrash:(TouchTextField *) textfield
{
    //NSLog(@"moveToTrash: 1) %d", _userTextFields.count);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // remove from NSMutable array _userTextFields
    for (TouchTextField *ttextfield in _userTextFields)
    {
        // are the pointers equal?
        if (ttextfield == textfield)
        {
            [_userTextFields removeObjectIdenticalTo:textfield];
        }
    }
    
    // remove from defaults
    NSString *tag = [NSString stringWithFormat:@"%d", [textfield tag]];
    [defaults removeObjectForKey:tag];
    [defaults setInteger:_userTextFields.count forKey:_strNumUserTextFields];
    
    // remove from subview
    [textfield removeFromSuperview];
    
    // refresh view
    
    
    //NSLog(@"moveToTrash: 2) %d", _userTextFields.count);
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Event Handlers
//

- (IBAction)buttonDragInside:(UIButton *)sender forEvent:(UIEvent *)event
{
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.view];
    sender.center=point;
    
    //NSLog(@"ScratchPadViewController buttonDragInside: drag inside event for center(%f,%f)", point.x, point.y);
    
    // In case user hits the home button or force quits from the multitasking bar
    [self saveDefaultDataForButton:sender];
}

- (IBAction)newTextFieldTouchUpInside:(UIButton *)sender forEvent:(UIEvent *)event
{
    [self addNewTextField:sender];
}

- (IBAction)resetTouchUpInside:(UIButton *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
    // load positions for planet color buttons
    for (UIButton *btn in _planetColorBtns)
    {
        NSString *tag = [NSString stringWithFormat:@"orig_%d", [btn tag]];
        NSString *pointString = [defaults stringForKey:tag];
        CGPoint savedCenter = CGPointFromString(pointString);
        
        [btn setCenter:savedCenter];
    }
        
    // load positions for planet name buttons
    for (UIButton *btn in _planetNameBtns)
    {
        NSString *tag = [NSString stringWithFormat:@"orig_%d", [btn tag]];
        NSString *pointString = [defaults stringForKey:tag];
        CGPoint savedCenter = CGPointFromString(pointString);
            
        [btn setCenter:savedCenter];
    }
    
    [self saveDefaultData];
    
    [defaults synchronize];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    //NSLog(@"ScratchPadViewController touchesEnded: %d userTextFields", [_userTextFields count]);
    for (TouchTextField *textfield in _userTextFields)
    {
        // dismiss keyboard if touch outside of textfield
        if ([textfield isFirstResponder] && [touch view] != textfield)
        {
            [textfield resignFirstResponder];
        }
        
        // save new text after closing keyboard
        [self saveTextField:textfield];
    }
}
/*
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    NSLog(@"ScratchPadViewController touchesEnded: %d userTextFields", [_userTextFields count]);
    for (TouchTextField *textfield in _userTextFields)
    {
        // dismiss keyboard if touch outside of textfield
        if ([textfield isFirstResponder] && [touch view] != textfield)
        {
            [textfield resignFirstResponder];
            
            // save new text after closing keyboard
            [self saveTextField:textfield];
        }
    }
}
 */


@end
