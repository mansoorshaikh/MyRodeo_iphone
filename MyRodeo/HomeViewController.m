//
//  HomeViewController.m
//  MyRodeo
//
//  Created by mansoor shaikh on 19/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#import "HomeViewController.h"
#import "CreateRodeoViewController.h"
#import "RodeoListViewController.h"
#import "SettingsViewController.h"
#import "GettingStartedViewController.h"
#import "AboutViewController.h"
#import "HelpViewController.h"
@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize createRodeobtn,lookupRodeobtn,gettingstartedbtn,settingsbtn,aboutbtn,helpbtn,appDelegate,scrollview,bgimage;
@synthesize logoimage;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


//autorotate method
- (BOOL)shouldAutorotate
{
    return YES;
}

- (void) copyDatabaseIfNeeded
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSString *dbPath = [self getDestPath];
    NSLog(@"dbPath  = %@", dbPath);
	BOOL success = [fileManager fileExistsAtPath:dbPath];
	
	if(!success) {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Rodeo.sqlite"];
        
        NSLog(@"DefaultDBPath.....>>%@",defaultDBPath);
		success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
		
		if (!success)
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
	}
}

-(NSString*)getDestPath
{
    NSString* srcPath = [[NSBundle mainBundle]pathForResource:@"Rodeo" ofType:@"sqlite"];
    NSArray* arrayPathComp = [NSArray arrayWithObjects:NSHomeDirectory(),@"Documents",@"Rodeo.sqlite", nil];
    
    NSString* destPath = [NSString pathWithComponents:arrayPathComp];
    NSLog(@"src path:%@",srcPath);
    NSLog(@"dest path:%@",destPath);
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:destPath]!=YES) {
        NSError *error;
        
        if ([manager copyItemAtPath:srcPath toPath:destPath error:&error]!=YES) {
            NSLog(@"Failed");
            
            NSLog(@"Reason = %@",[error localizedDescription]);
        }
    }
    return  destPath;
}

-(void)viewDidAppear:(BOOL)animated{
    [self loadDefaultSettings];
    [self copyDatabaseIfNeeded];
}

-(void)loadDefaultSettings{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![[defaults objectForKey:@"defaultsset"] isEqualToString:@"yes"]){
        [defaults setObject:@"yes" forKey:@"defaultsset"];
        [defaults setObject:@"2" forKey:@"timeformat"];
        [defaults setObject:@"1" forKey:@"scoreformat"];
        [defaults setObject:@"1" forKey:@"numberofrounds"];
        [defaults setObject:@"8" forKey:@"noofcontestants"];
        [defaults setObject:@"3" forKey:@"noofplacespaid"];
    }
    [defaults synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate=[[UIApplication sharedApplication] delegate];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"rodeolist.plist"]; //3
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path]) //4
    {
        NSString *bundle = [[NSBundle mainBundle] pathForResource:@"rodeolist" ofType:@"plist"]; //5
        [fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        createRodeobtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:24];
        lookupRodeobtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:24];
        gettingstartedbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:24];
        settingsbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:24];
        
        aboutbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:24];
        helpbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:24];
        
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Brush Script Std" size:24] forKey:NSFontAttributeName];
    }else{
        createRodeobtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:50];
        lookupRodeobtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:50];
        gettingstartedbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:50];
        settingsbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:50];
        aboutbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:50];
        helpbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:50];
        
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Brush Script Std" size:40] forKey:NSFontAttributeName];
    }
    
    bgimage.frame=CGRectMake(0, 0, width, height);

    if(height==568){
        [scrollview setScrollEnabled:FALSE];
        bgimage.image=[UIImage imageNamed:@"bg.png"];
    }else{
        //iphone 6 and plus design
        
        [scrollview setScrollEnabled:FALSE];
        bgimage.image=[UIImage imageNamed:@"bg375.png"];
        //height
        CGFloat widths=width/2;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){

        logoimage.frame=CGRectMake(widths-90, 210, 173, 55);
        createRodeobtn.frame=CGRectMake(widths-140, 270, 280, 50);
        lookupRodeobtn.frame=CGRectMake(widths-140, 330, 280, 50);
        gettingstartedbtn.frame=CGRectMake(widths-140, 390, 280, 50);
        aboutbtn.frame=CGRectMake(widths-140, 450, 280, 50);
        settingsbtn.frame=CGRectMake(widths-140, 510, 280, 50);
        helpbtn.frame=CGRectMake(widths-140, 570, 280, 50);
        //font
        createRodeobtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:30];
        lookupRodeobtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:30];
        gettingstartedbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:30];
        settingsbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:30];
        aboutbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:30];
        helpbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:30];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    appDelegate.isLandscapeOK=NO;
    return UIInterfaceOrientationMaskPortrait;
}

-(IBAction)createRodeo{
    CreateRodeoViewController *createrodeo;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        createrodeo=[[CreateRodeoViewController alloc] initWithNibName:@"CreateRodeoViewController" bundle:nil];
    else
        createrodeo=[[CreateRodeoViewController alloc] initWithNibName:@"CreateRodeoViewController_iPad" bundle:nil];
    [self.navigationController pushViewController:createrodeo animated:YES];
}

-(IBAction)lookupRodeo{
    RodeoListViewController *rodeolist=[[RodeoListViewController alloc] initWithNibName:@"RodeoListViewController" bundle:nil];
    [self.navigationController pushViewController:rodeolist animated:YES];
}

-(IBAction)settingsOption{
    SettingsViewController *svc=[[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    [self.navigationController pushViewController:svc animated:YES];
}

-(IBAction)gettingStartedOption{
    GettingStartedViewController *gettingstarted;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        gettingstarted=[[GettingStartedViewController alloc] initWithNibName:@"GettingStartedViewController" bundle:nil];
    else
        gettingstarted=[[GettingStartedViewController alloc] initWithNibName:@"GettingStarted_ipad" bundle:nil];
    [self.navigationController pushViewController:gettingstarted animated:YES];
}

-(IBAction)aboutOption{
    AboutViewController *aboutvc;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        aboutvc=[[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
    else
        aboutvc=[[AboutViewController alloc] initWithNibName:@"AboutRodeo_ipad" bundle:nil];
    [self.navigationController pushViewController:aboutvc animated:YES];
}

-(IBAction)helpOption{
    HelpViewController *helpvc;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        helpvc=[[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    else
        helpvc=[[HelpViewController alloc] initWithNibName:@"HelpRodeo_ipad" bundle:nil];
    [self.navigationController pushViewController:helpvc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
