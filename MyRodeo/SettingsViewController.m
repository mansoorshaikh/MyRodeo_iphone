//
//  SettingsViewController.m
//  MyRodeo
//
//  Created by mansoor shaikh on 25/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#import "SettingsViewController.h"
#import "HomeViewController.h"
@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize tblview,settingsoptionsArray,appDelegate,imgview,currentSetting;
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
    HomeViewController *hvc;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    hvc=[[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    else
    hvc=[[HomeViewController alloc] initWithNibName:@"HomeViewController_iPad" bundle:nil];
    [self.navigationController pushViewController:hvc animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%@", [alertView textFieldAtIndex:0].text);
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if([title isEqualToString:@"OK"]){
        if(![[alertView textFieldAtIndex:0].text isEqualToString:@""]){
        if([currentSetting isEqualToString:@"timeformat"])
        [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"timeformat"];
        else if([currentSetting isEqualToString:@"scoreformat"])
            [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"scoreformat"];
        else if([currentSetting isEqualToString:@"numberofrounds"])
            [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"numberofrounds"];
        else if([currentSetting isEqualToString:@"noofcontestants"])
            [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"noofcontestants"];
        else if([currentSetting isEqualToString:@"noofplacespaid"])
            [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"noofplacespaid"];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate=[[UIApplication sharedApplication] delegate];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if(height>=568){
        imgview.image=[UIImage imageNamed:@"innerbg.png"];
    }else{
        imgview.image=[UIImage imageNamed:@"innerbg_.png"];
    }
    
    // Do any additional setup after loading the view from its nib.
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
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:24] forKey:NSFontAttributeName];
    }else{
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:40] forKey:NSFontAttributeName];
    }    self.navigationItem.title=@"Settings";

    tblview.separatorColor=[UIColor grayColor];
    settingsoptionsArray=[[NSMutableArray alloc] initWithObjects:@"Time Format (# of decimals) : ",@"Score Format (# of decimals) : ",@"Number of Rounds : ",@"Number of Contestants : ",@"Number of Places Paid (Avg and Rnd) : ", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma tableview delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [settingsoptionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellbg.png"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellbg_selected.png"]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        cell.textLabel.font = [UIFont fontWithName:@"Segoe Print" size:16];
    }else{
        cell.textLabel.font = [UIFont fontWithName:@"Segoe Print" size:40];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(indexPath.row==0)
    cell.textLabel.text=[settingsoptionsArray objectAtIndex:indexPath.row];
    if(indexPath.row==1)
        cell.textLabel.text=[settingsoptionsArray objectAtIndex:indexPath.row];
    if(indexPath.row==2)
        cell.textLabel.text=[settingsoptionsArray objectAtIndex:indexPath.row];
    if(indexPath.row==3)
        cell.textLabel.text=[settingsoptionsArray objectAtIndex:indexPath.row];
    if(indexPath.row==4){
        cell.textLabel.text=[settingsoptionsArray objectAtIndex:indexPath.row];
    }
    cell.textLabel.textColor=[UIColor blackColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(indexPath.row==0){
        currentSetting=@"timeformat";
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                          message:@"Time Format (# of decimals)."
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:@"Cancel",nil];
        message.alertViewStyle = UIAlertViewStylePlainTextInput;
        [message textFieldAtIndex:0].text=[defaults objectForKey:@"timeformat"];
        [[message textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [message show];
    }else if(indexPath.row==1){
        currentSetting=@"scoreformat";
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                          message:@"Score Format (# of decimals)."
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:@"Cancel",nil];
        message.alertViewStyle = UIAlertViewStylePlainTextInput;
        [message textFieldAtIndex:0].text=[defaults objectForKey:@"scoreformat"];
        [[message textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [message show];
    }else if(indexPath.row==2){
        currentSetting=@"numberofrounds";
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                          message:@"Number of Rounds"
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:@"Cancel",nil];
        message.alertViewStyle = UIAlertViewStylePlainTextInput;
        [message textFieldAtIndex:0].text=[defaults objectForKey:@"numberofrounds"];
        [[message textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [message show];
    }else if(indexPath.row==3){
        currentSetting=@"noofcontestants";
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                          message:@"Number of Contestants"
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:@"Cancel",nil];
        message.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[message textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [message textFieldAtIndex:0].text=[defaults objectForKey:@"noofcontestants"];
        [message show];
    }else if(indexPath.row==4){
        currentSetting=@"noofplacespaid";
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                          message:@"Number of Places Paid (Avg and Rnd)"
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:@"Cancel",nil];
        message.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[message textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [message textFieldAtIndex:0].text=[defaults objectForKey:@"noofplacespaid"];
        [message show];
    }
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return 40;
    else
        return 70;
}

@end
