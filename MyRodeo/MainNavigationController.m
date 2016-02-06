//
//  MainNavigationController.m
//  MyRodeo
//
//  Created by mansoor shaikh on 09/01/14.
//  Copyright (c) 2014 ClientsSolution. All rights reserved.
//

#import "MainNavigationController.h"

@interface MainNavigationController ()

@end

@implementation MainNavigationController
@synthesize appDelegate;
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
    appDelegate=[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view from its nib.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (appDelegate.isLandscapeOK) {
        // for iPhone, you could also return UIInterfaceOrientationMaskAllButUpsideDown
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
