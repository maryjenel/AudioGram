//
//  MyLoginViewController.m
//  AudioGram
//
//  Created by Mary Jenel Myers on 2/3/15.
//  Copyright (c) 2015 Mary Jenel Myers. All rights reserved.
//

#import "MyLoginViewController.h"

@interface MyLoginViewController ()

@end

@implementation MyLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.logInView.dismissButton setHidden:YES];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AudioGram"]]];
}

@end
