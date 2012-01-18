//
//  CalculatorBrain.m
//  RPN_Calculator
//
//  Created by Graham Cottew on 14/12/11.
//  Copyright (c) 2011 Zendata Pty Ltd. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@property (nonatomic, strong) NSDictionary *variableList;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;
@synthesize variableList = _variableList;

- (NSMutableArray *)programStack
{
    if (_programStack == nil) _programStack = [[NSMutableArray alloc] init];
    return _programStack;
}

- (id)program
{
    return [self.programStack copy];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    // grab the program array    
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    // step through the array looking for variables by removing anything that is not a variable
    // variables are identified by being prefixed with a %
    int index = 0; // Hamster is this OK to initialse an index?
    BOOL varFound;
    for (index = 0; index < [stack count]; index++) {
        varFound = NO;
        id stackElement = [stack objectAtIndex:index];
        if ([stackElement isKindOfClass:[NSString class]]) {
            if ([stackElement  isEqualToString:@"%x"]) {
                // note that this has been found
                varFound = YES;
            }
            if ([stackElement  isEqualToString:@"%y"]) {
                // note that this has been found
                varFound = YES;
            }
            if ([stackElement  isEqualToString:@"%foo"]) {
                // note that this has been found                    
                varFound = YES;
            }
            if (varFound == NO) {
                
                [stack removeObjectAtIndex:index];
                // removed a stack element so start again
                index = -1;
            }
        } else {        
            [stack removeObjectAtIndex:index]; 
            // removed a stack element so start again
            index = -1; // Hamster I had to use this cludge to start looking the start of the stack again ???
        }
    }
    
    // only variable objects are left in the aray so add it to the set        
    NSSet *variablesUsed = [NSSet setWithArray:stack];
    
    return variablesUsed;
}

+ (BOOL)isOperation:(NSString *)operation {
    
    BOOL isOperation; 
    // set up set of valid operations
    NSSet *ops;
    ops = [NSSet setWithObjects:@"+",@"-",@"*",@"/", nil];
    // see if our operation is valid
    isOperation = [ops containsObject:operation];
    return isOperation;
}

+ (BOOL)isSingleOperation:(NSString *)operation {
    
    BOOL isOperation; 
    // set up set of valid operations
    NSSet *ops;
    ops = [NSSet setWithObjects:@"sin",@"cos",@"tan",@"log",@"sqrt", nil];
    // see if our operation is valid
    isOperation = [ops containsObject:operation];
    return isOperation;
}

+ (BOOL)isVariable:(NSString *)operation {
    
    BOOL isVariable; 
    // set up set of valid variables
    NSSet *ops;
    ops = [NSSet setWithObjects:@"%x",@"%y",@"%foo", nil];
    // see if our variable is valid
    isVariable = [ops containsObject:operation];
    return isVariable;
}

+ (BOOL)isConstant:(NSString *)operation {
    
    BOOL isVariable; 
    // set up set of valid contants
    NSSet *ops;
    ops = [NSSet setWithObjects:@"pi",@"e", nil];
    // see if our variable is valid
    isVariable = [ops containsObject:operation];
    return isVariable;
}

+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)stack
{
    // this displays the RPN program that has been input since the last Clear and displays it in in-fix notation
    NSString *descriptionComponent;
    NSString *firstOperand;
    NSString *secondOperand;
    
    // grab the top item of the program stack
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    // if it is a number just return it
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        descriptionComponent = [NSString stringWithFormat:@"%@", topOfStack];
    }
    // if it not a number it may be an operation, a constant or a variable
    if ([topOfStack isKindOfClass:[NSString class]]) {
        // if it is a double operand operation
        if ([self isOperation:topOfStack]) {
            //return the description
            secondOperand = [self descriptionOfTopOfStack:stack];
            firstOperand = [self descriptionOfTopOfStack:stack];
            // if the first character of the description so far is a ( then do not add a redundant pair of ()            
            // if ([firstOperand hasPrefix:@"("]) {
            //    descriptionComponent = [NSString stringWithFormat:@"%@ %@ %@", firstOperand,topOfStack, secondOperand];
            //} else {
                descriptionComponent = [NSString stringWithFormat:@"(%@ %@ %@)", firstOperand,topOfStack, secondOperand];                
            //}
        }
        // if it is a single operand operation
        if ([self isSingleOperation:topOfStack]) {
            //return the description
            //secondOperand = [self descriptionOfTopOfStack:stack];
            firstOperand = [self descriptionOfTopOfStack:stack];
            // if the first character of the description so far is a ( then do not add a redundant pair of ()            
            if ([firstOperand hasPrefix:@"("] && [firstOperand hasSuffix:@")"]) {
                descriptionComponent = [NSString stringWithFormat:@"%@ %@",topOfStack, firstOperand];
            } else {
                descriptionComponent = [NSString stringWithFormat:@"%@ (%@)",topOfStack, firstOperand];
            }
            
        }
        // if it is a variable
        if ([self isVariable:topOfStack]) {
            //return the description
            // Remove % sign that indicates a variable
            topOfStack = [topOfStack stringByReplacingOccurrencesOfString:@"%" withString:@""];
            descriptionComponent = [NSString stringWithFormat:@"%@",topOfStack];
        }
        // if it is a constant
        if ([self isConstant:topOfStack]) {
            //return the description
            descriptionComponent = [NSString stringWithFormat:@"%@",topOfStack];
        }
    }
    
     return descriptionComponent;
}

+ (NSString *)descriptionOfProgram:(id)program
{
        NSMutableArray *stack;
        if ([program isKindOfClass:[NSArray class]]) {
            stack = [program mutableCopy];
        }
        return [self descriptionOfTopOfStack:stack];
}

- (void)pushOperand:(double)operand
{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}

-(void)pushVariable:(NSString *)variable
{
    variable = [@"%" stringByAppendingString:variable];
    [self.programStack addObject:[NSString stringWithString:variable]];
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

- (void)clearStack {
    [self.programStack removeAllObjects];
}

+ (double)popOperandOffProgramStack:(NSMutableArray *)stack
{
    double result = 0;
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    if ([topOfStack isKindOfClass:[NSNumber class]])
    {
        // top of the stack is a number so just return this
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        NSString *operation = topOfStack;
        // Perform our operations here and store answer in result
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] +
            [self popOperandOffProgramStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffProgramStack:stack] *
            [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            if (divisor) result = [self popOperandOffProgramStack:stack] / divisor;
        } else if ([@"sin" isEqualToString:operation]) {
            result = sin([self popOperandOffProgramStack:stack]);        
        } else if ([@"cos" isEqualToString:operation]) {
            result = cos([self popOperandOffProgramStack:stack]);        
        } else if ([@"log" isEqualToString:operation]) {
            result = log10([self popOperandOffProgramStack:stack]);        
        } else if ([@"sqrt" isEqualToString:operation]) {
            double toBeRooted = [self popOperandOffProgramStack:stack];
            if (toBeRooted > 0.0) {
                result = sqrt(toBeRooted);   
            } else {
                result = toBeRooted;
            }
        } else if ([@"pi" isEqualToString:operation]) {
            result = 3.1415926;        
        } else if ([@"+/-" isEqualToString:operation]) {
            result = -1.0*[self popOperandOffProgramStack:stack];        
        } else if ([@"e" isEqualToString:operation]) {
            result = 2.718281828;        
        }
    }
    return result;
}

+ (double)runProgram:(id)program 
{
    // if there are no variables supplied then use a value of 0 for these variables
    // and allow the original runProgram method to be backwards compatible
    return [self runProgram:program usingVariableValues:nil]; 
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    if (variableValues) { // if we have a dictionary
        
        // go through the stack and look for variables and relpace with the dictionary values
        // NSLog(@"when running the program the stack is: %@", stack);
        
        // Hamster this looks repetative - can you suggest a better test?
        
        // look for variable x
        NSString *varName = @"x";
        int index = 0;
        for (index = 0; index < [stack count]; index++) {
            
            id stackElement = [stack objectAtIndex:index];
            if ([stackElement isKindOfClass:[NSString class]]) {
                if ([stackElement  isEqualToString:@"%x"]) {
                    // replace any variables found with the values supplied in the dictionary
                    NSNumber *varValue = [variableValues objectForKey:varName];
                    if (!varValue) { 
                        varValue = [NSNumber numberWithFloat:0.0]; // Thanks Hamster!
                    } 
                    [stack replaceObjectAtIndex:index withObject:varValue];
                }
            }          
        }
        
        // look for variable y
        varName = @"y";
        index = 0;
        for (index = 0; index < [stack count]; index++) {
            
            id stackElement = [stack objectAtIndex:index];
            if ([stackElement isKindOfClass:[NSString class]]) {
                if ([stackElement  isEqualToString:@"%y"]) {
                    // replace any variables found with the values supplied in the dictionary
                    NSNumber *varValue = [variableValues objectForKey:varName];
                    if (!varValue) { 
                        varValue = [NSNumber numberWithFloat:0.0]; 
                    } 
                    [stack replaceObjectAtIndex:index withObject:varValue];
                }
            }
        }
        
        // look for variable foo
        varName = @"foo";
        index = 0;
        for (index = 0; index < [stack count]; index++) {
            
            id stackElement = [stack objectAtIndex:index];
            if ([stackElement isKindOfClass:[NSString class]]) {
                if ([stackElement  isEqualToString:@"%foo"]) {
                    // replace any variables found with the values supplied in the dictionary
                    NSNumber *varValue = [variableValues objectForKey:varName];
                    if (!varValue) { 
                        varValue = [NSNumber numberWithFloat:0.0]; 
                    } 
                    [stack replaceObjectAtIndex:index withObject:varValue];
                }
            }      
        }
        
    }
    // NSLog(@"after variable substitution the stack looks like: %@", stack);       
    return [self popOperandOffProgramStack:stack];
}

@end
