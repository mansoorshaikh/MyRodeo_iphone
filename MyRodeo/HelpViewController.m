//
//  HelpViewController.m
//  MyRodeo
//
//  Created by mansoor shaikh on 13/04/15.
//  Copyright (c) 2015 ClientsSolution. All rights reserved.
//

#import "HelpViewController.h"
#import "HomeViewController.h"
@interface HelpViewController ()

@end

@implementation HelpViewController
@synthesize helpTextView,imgview;
- (void)viewDidLoad {
    [super viewDidLoad];
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
        helpTextView.font=[UIFont fontWithName:@"Segoe Print" size:20];
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:24] forKey:NSFontAttributeName];
    }else{
        helpTextView.font=[UIFont fontWithName:@"Segoe Print" size:30];
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:40] forKey:NSFontAttributeName];
    }
    self.navigationItem.title=@"Help";    // Do any additional setup after loading the view from its nib.
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    [imgview removeFromSuperview];
    imgview=[[UIImageView alloc]init];
    imgview.frame=CGRectMake(0, 0, width, height-20);
    imgview.image=[UIImage imageNamed:@"innerbg.png"];
    [self.view addSubview:imgview];
    helpTextView=[[UITextView alloc]init];
    helpTextView.text=@"If you are experiencing problems with the function of the My Rodeo App.  First ensure that when entering data that you are hitting 'Done' at the conclusion of every entry.  Or if Creating a Rodeo that your hitting '+' at the end of every event entry. If you are experiencing difficulty with location while creating Rodeo shut off your device and restart it. If you are still experiencing difficulties please feel free to email us at help@myrodeoapp.com. To leave us feedback so we can better improve the app please also respond to help@myrodeoapp.com. To leave us feedback in the appstore please follow this link www.myrodeo.com";
    helpTextView.frame=CGRectMake(10, 10, width-20, height-80);
    helpTextView.font=[UIFont fontWithName:@"Segoe Print" size:20];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:24] forKey:NSFontAttributeName];
    [helpTextView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:helpTextView];
    [self.view bringSubviewToFront:helpTextView];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)popviewController{
    HomeViewController *hvc;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    hvc=[[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    else
    hvc=[[HomeViewController alloc] initWithNibName:@"HomeViewController_iPad" bundle:nil];
    [self.navigationController pushViewController:hvc animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
