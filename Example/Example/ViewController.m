//
//  ViewController.m
//  Example
//
//  Created by Pavel Maksimov on 9/3/16.
//  Copyright © 2016 Pavel Maksimov. All rights reserved.
//

#import "ViewController.h"
#import "PMActivityIndicator.h"


@interface ViewController ()

@property (nonatomic, strong) PMActivityIndicator *activityIndicator;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.activityIndicator = [PMActivityIndicator new];
    [self.activityIndicator show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
