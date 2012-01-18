//
//  ViewController.m
//  RPN_Calculator
//
//  Created by Graham Cottew on 13/12/11.
//  Copyright (c) 2011 Zendata Pty Ltd. All rights reserved.
//

#import "ViewController.h"
#import "CalculatorBrain.h"

@interface ViewController () 
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic,strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;
@end

@implementation ViewController

@synthesize display;
@synthesize statusDisplay = _statusDisplay;
@synthesize descriptionOfUse = _descriptionOfUse;
@synthesize varDisplay = _varDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *)brain {
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return  _brain;
}

-(void)updateStatusDisplay:(NSString *)somethingPressed {
    
    // Remove last = sign
    self.statusDisplay.text = [self.statusDisplay.text stringByReplacingOccurrencesOfString:@"=" withString:@""];
    
    // Add our new stuff
    self.statusDisplay.text = [self.statusDisplay.text stringByAppendingString:somethingPressed];
    
    // Now make sure our status display does not get too big
    
    if (self.statusDisplay.text.length > 35) {
        // Trunate the oldest status
        self.statusDisplay.text = [self.statusDisplay.text substringFromIndex:5];
    }
    
    self.descriptionOfUse.text = [CalculatorBrain descriptionOfProgram:self.brain.program];

}

-(void)displayVariables
{
    // Clear existing display and show any variables found in the dictionary
    self.varDisplay.text = @"";
    
    // Get a set of all the variables that are in the program
    NSSet *foundVars = [CalculatorBrain variablesUsedInProgram:self.brain.program];

    // now only for the variables that are in the program show their values
    NSEnumerator *enumerator = [foundVars objectEnumerator];
    id value;
    while ((value = [enumerator nextObject])) {
        
        // remove the % sign that prefixes all variables (to distinguish from an operation)
        NSString *strippedVar =  [value stringByReplacingOccurrencesOfString:@"%" withString:@""]; 
        // look up the value of the variable from the dictionary
        NSNumber *varValue = [self.testVariableValues objectForKey:strippedVar];
        // display the variable on screen
        self.varDisplay.text = [self.varDisplay.text stringByAppendingString:[NSString stringWithFormat:@" %@ = %@ ", strippedVar, varValue]];

    }
 }

- (IBAction)digitPressed:(UIButton *)sender {
    
    NSString *digit =  [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
    self.display.text = [self.display.text stringByAppendingString:digit];
    [self updateStatusDisplay:digit];
    } else {       
    self.display.text = digit;
    // Update the top status display
    [self updateStatusDisplay:digit];
    userIsInTheMiddleOfEnteringANumber = YES;
    }
    
}

- (IBAction)dotPressed {
    
    if (self.userIsInTheMiddleOfEnteringANumber) {
        
        // Do not allow more than one dot
        NSRange range = [self.display.text rangeOfString:@"."];
        if (range.location == NSNotFound) { 
            // No dots found already so add the dot
            self.display.text = [self.display.text stringByAppendingString:@"."];        
            [self updateStatusDisplay:@"."];
        }
    } else {       
        
        // If the user starts off with a dot assume we need a leading zero
        self.display.text = @"0."; 
        
        // Update the top status display
        [self updateStatusDisplay:@"."]; 
        
        userIsInTheMiddleOfEnteringANumber = YES;
    }
    
}

- (IBAction)backspacePressed {
    // remove the last digit from the display if we are in the middle of entering a number
    if (userIsInTheMiddleOfEnteringANumber && self.display.text.length > 0) {
        // NSUInteger *displayLength = 0;
        // displayLength = self.display.text.length;
        self.display.text = [self.display.text substringToIndex:(self.display.text.length-1)];
        self.statusDisplay.text = [self.statusDisplay.text substringToIndex:(self.statusDisplay.text.length-1)];
        if (self.display.text.length == 0) {
            self.display.text = @"0";
        }
    }
    
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    [self updateStatusDisplay:@" "];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)xPressed:(id)sender {
    // Add a few variable buttons (e.g, x, y, foo). 
    // These are buttons that push a variable into the CalculatorBrain.
    NSString *variable =  [sender currentTitle];
    // Update the top status display
    
    NSString *paddedOperation = [NSString stringWithFormat:@" %@", variable];
    [self updateStatusDisplay:paddedOperation];
    
    // now display the result   
    self.display.text =  [NSString stringWithFormat:@" %@", variable]; 

    [self.brain pushVariable:variable];

}

- (IBAction)testPressed:(id)sender {
    
    // Add a few different “test” buttons which set testVariableValues to some preset testing values. One of them should set testVariableValues to nil.
    NSString *testButton =  [sender currentTitle];
    
    if ([@"Test 1" isEqualToString:testButton]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithDouble:33.3], @"x", [NSNumber numberWithDouble:77.95], @"y", nil]; 
    }
    // Hamster what is the best way of putting a number in the dictionary?
    // the method above using [NSNumber numberWithDouble:33.3] or the method below using a string?
    if ([@"Test 2" isEqualToString:testButton]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"3", @"x", @"4", @"y", @"8762863.12", @"foo", nil];
    }
    if ([@"Test 3" isEqualToString:testButton]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"-1000000", @"x", @"0", @"y", nil];
    }
    
    // Update the variable display status
    [self displayVariables];
    
    // Run the program with these test variable values
    [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    
}

- (IBAction)operationPressed:(id)sender {
    NSString *operation =  [sender currentTitle];
    if (userIsInTheMiddleOfEnteringANumber) {
        
        // If we are changing sign then do not do an automatic enter
        if (operation == @"+/-") {            
        } else {
        [self enterPressed];
        }
    }
    double result = [self.brain performOperation:operation];
    
    // Update the original status display
    
    NSString *paddedOperation = [NSString stringWithFormat:@" %@ = ", operation];
    [self updateStatusDisplay:paddedOperation];
    
    // now display the result    
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

- (IBAction)clearPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    [self updateStatusDisplay:@" Clear "];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.display.text = @"0";
    self.statusDisplay.text = @"";
    self.varDisplay.text = @"";
    self.descriptionOfUse.text = @"";
    [self.brain clearStack];
}

- (void)viewDidUnload {
    [self setStatusDisplay:nil];
    [self setDescriptionOfUse:nil];
    [self setVarDisplay:nil];
    [super viewDidUnload];
}

@end
