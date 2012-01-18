//
//  ViewController.h
//  RPN_Calculator
//
//  Created by Graham Cottew on 13/12/11.
//  Copyright (c) 2011 Zendata Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *statusDisplay;
@property (weak, nonatomic) IBOutlet UILabel *descriptionOfUse;
@property (weak, nonatomic) IBOutlet UILabel *varDisplay;

@end
