//
//  ViewController.m
//  filecheckerexample
//
//  Created by Samir Hadi on 25/02/13.
//  Copyright (c) 2013 Samir Hadi. All rights reserved.
//

#import "ViewController.h"
#import "FVFileValidator.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [FVFileValidator setSecret:@"asda8r32ijiwesjza9sa9idsadi0saidas0kdo3"];
    [FVFileValidator validateFile:@"filetosecure.plist"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
