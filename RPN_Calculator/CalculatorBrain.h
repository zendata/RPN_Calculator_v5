//
//  CalculatorBrain.h
//  RPN_Calculator
//
//  Created by Graham Cottew on 14/12/11.
//  Copyright (c) 2011 Zendata Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

-(void)pushOperand:(double)operand;
-(void)pushVariable:(NSString *)variable;
-(double)performOperation:(NSString *)operation;
-(void)clearStack;

@property (nonatomic, readonly) id program;

+ (NSString *)descriptionOfProgram:(id)program;
+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;
+ (NSSet *)variablesUsedInProgram:(id)program;

@end

/*You will almost certainly want to use recursion to implement descriptionOfProgram: (just like we did to implement runProgram:). You might find it useful to write yourself a descriptionOfTopOfStack: method too (just like we wrote ourselves a popOperandOffStack: method to help us implement runProgram:). If you find recursion a challenge, think “simpler,” not “more complex.” Your descriptionOfTopOfStack: method should be less than 20 lines of code and will be very similar to popOperandOffStack:. The next hint will also help.
4. One of the things your descriptionOfProgram: method is going to need to know is whether a given string on the stack is a two-operand operation, a single-operand operation, a no-operand operation or a variable (because it gives a different description for each of those kinds of things). Implementing some private helper method(s) to determine this is probably a good idea. You could implement such a method with a lot of if-thens, of course, but you might also think about whether NSSet (and its method containsObject:) might be helpful.
5. You might find the private helper methods mentioned in Hint #4 useful in distinguishing between variables and operations in your other methods as well. It’s very likely that you’re going to want a + (BOOL)isOperation:(NSString *)operation method.
6. It might be a good idea not to worry about extraneous parentheses in your descriptionOfProgram: output at first, then, when you have it working, go back and figure out how to suppress them in certain cases where you know they are going to be redundant. As you’re thinking about this, at least consider handling the case of the highest precedence operations in your CalculatorBrain where you clearly do not need parentheses. Also think about the need for parentheses inside parentheses when doing function notation (e.g. sqrt((5 + 3)) is ugly). */