//
//  GettingStartedViewController.m
//  MyRodeo
//
//  Created by mansoor shaikh on 27/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#import "GettingStartedViewController.h"

@interface GettingStartedViewController ()

@end

@implementation GettingStartedViewController
@synthesize appDelegate,imgview,gettingstartedTextView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations
{
    appDelegate.isLandscapeOK=NO;
    return UIInterfaceOrientationMaskPortrait;
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.isLandscapeOK=NO;
}


-(void)popviewController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate=[[UIApplication sharedApplication] delegate];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    gettingstartedTextView.frame=CGRectMake(10, 10, width-20, height-40);
    [self.gettingstartedTextView scrollRangeToVisible:NSMakeRange(0, 1)];
    if(height>=568){
        imgview.image=[UIImage imageNamed:@"innerbg.png"];
    }else{
        imgview.image=[UIImage imageNamed:@"innerbg_.png"];
    }
    
    self.navigationController.navigationBar.hidden=NO;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [backButton setFrame:CGRectMake(0,0,50,30)];
    else
        [backButton setFrame:CGRectMake(0,0,80,48)];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.userInteractionEnabled = YES;
    [backButton addTarget:self
                   action:@selector(popviewController)
         forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"backbtn.png"] forState:UIControlStateNormal];
    
    // ASSIGNING THE BUTTON WITH IMAGE TO BACK BAR BUTTON
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    backBarButton.title=@"Back";
    self.navigationItem.leftBarButtonItem = backBarButton;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar.png"]];
    self.navigationController.navigationBar.translucent = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        //gettingstartedTextView.font=[UIFont fontWithName:@"Segoe Print" size:20];
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:24] forKey:NSFontAttributeName];
    }else{
        //gettingstartedTextView.font=[UIFont fontWithName:@"Segoe Print" size:30];
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:40] forKey:NSFontAttributeName];
    }
    self.navigationItem.title=@"Getting Started";

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
