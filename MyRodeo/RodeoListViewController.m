//
//  RodeoListViewController.m
//  MyRodeo
//
//  Created by mansoor shaikh on 25/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#import "RodeoListViewController.h"
#import "SearchRodeoViewController.h"
#import "EventsLookUpViewController.h"
#import "AppDelegate.h"
#import "HomeViewController.h"
@interface RodeoListViewController ()

@end

@implementation RodeoListViewController
@synthesize imgview,tblview,rodeosArray,appDelegate,database,selectedRodeoId,selectedRodeo,rodeolist,activityIndicator;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (sqlite3 *)getNewDb {
    sqlite3 *newDb = nil;
    if (sqlite3_open([[self getDestPath] UTF8String], &newDb) == SQLITE_OK) {
        sqlite3_busy_timeout(newDb, 1000);
    } else {
        sqlite3_close(newDb);
    }
    return newDb;
}

-(void)viewDidAppear:(BOOL)animated{
    [self readRodeoList];
}

-(void)showsyncList{
    SearchRodeoViewController *searchrodeo=[[SearchRodeoViewController alloc] initWithNibName:@"SearchRodeoViewController" bundle:nil];
    [self.navigationController pushViewController:searchrodeo animated:YES];
}

-(void)popviewController{
    sqlite3_close(database);
    HomeViewController *hvc;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    hvc=[[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    else
    hvc=[[HomeViewController alloc] initWithNibName:@"HomeViewController_iPad" bundle:nil];
    [self.navigationController pushViewController:hvc animated:YES];
}

-(void)readRodeoList{
    char *dbChars ;
    rodeosArray =[[NSMutableArray alloc] init];
    NSString* destPath = [self getDestPath];
    NSString *sqlStatement = [NSString stringWithFormat:@"select * from rodeodetails"];
        
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                Rodeo *rodeo=[[Rodeo alloc] init];
                dbChars = (char *)sqlite3_column_text(compiledStatement, 0);
                if(dbChars!=nil)
                    rodeo.rodeoid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                
                dbChars = (char *)sqlite3_column_text(compiledStatement, 1);
                if(dbChars!=nil)
                    rodeo.rodeoname=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                
                dbChars = (char *)sqlite3_column_text(compiledStatement, 2);
                if(dbChars!=nil)
                    rodeo.location=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                
                dbChars = (char *)sqlite3_column_text(compiledStatement, 3);
                if(dbChars!=nil)
                    rodeo.rodeostartdate=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                
                dbChars = (char *)sqlite3_column_text(compiledStatement, 4);
                if(dbChars!=nil)
                    rodeo.numberofrounds=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                
                dbChars = (char *)sqlite3_column_text(compiledStatement, 5);
                if(dbChars!=nil)
                    rodeo.isstarted=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
                    rodeo.serverRodeo=@"no";
                
                [rodeosArray addObject:rodeo];
            }
        }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"rodeolist.plist"]; //3
    rodeolist = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSMutableArray *allKeys=(NSMutableArray*)[rodeolist allKeys];
    NSMutableArray *allValues=(NSMutableArray*)[rodeolist allValues];
    for (int i=0; i<[rodeolist count]; i++) {
        Rodeo *tempRodeo=[[Rodeo alloc] init];
        tempRodeo.rodeoid=[allValues objectAtIndex:i];
        tempRodeo.rodeoname=[allKeys objectAtIndex:i];
        tempRodeo.serverRodeo=@"yes";
        [rodeosArray addObject:tempRodeo];
    }
    
    [tblview reloadData];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [activityIndicator stopAnimating];
    database=[self getNewDb];
    self.navigationItem.title=@"Rodeos";
    appDelegate=[[UIApplication sharedApplication] delegate];
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
    }
    self.navigationItem.title=@"Rodeos";

    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStylePlain target:self action:@selector(showsyncList)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [anotherButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:18], UITextAttributeFont,nil] forState:UIControlStateNormal];
    else
        [anotherButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:30], UITextAttributeFont,nil] forState:UIControlStateNormal];
    anotherButton.tintColor=[UIColor whiteColor];
//    self.navigationItem.rightBarButtonItem = anotherButton;
        imgview=[[UIImageView alloc]init];
        imgview.frame=CGRectMake(0, 0, width, height);
        imgview.image=[UIImage imageNamed:@"innerbg.png"];
        [self.view addSubview:imgview];
    
    //[tblview removeFromSuperview];
    tblview.frame=CGRectMake(0, 0, width+100, height);
    tblview.separatorColor=[UIColor grayColor];
    [self.view addSubview:tblview];
    [self.view bringSubviewToFront:tblview];

    //[tblview reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.isLandscapeOK=NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    appDelegate.isLandscapeOK=NO;
    return UIInterfaceOrientationMaskPortrait;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma tableview delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [rodeosArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellbg.png"]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellbg_selected.png"]];
    Rodeo *tempRodeo=[rodeosArray objectAtIndex:indexPath.row];
    cell.textLabel.text=tempRodeo.rodeoname;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    cell.textLabel.font = [UIFont fontWithName:@"Segoe Print" size:24];
    else
    cell.textLabel.font = [UIFont fontWithName:@"Segoe Print" size:40];
    cell.textLabel.textColor=[UIColor blackColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return 40;
    else
        return 70;
}

-(void)updateRodeoStatus{
    
}

 - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Start Rodeo"]){
        sqlite3_stmt *statement;
        NSLog(@"[self getDestPath] = %@",[self getDestPath]);
        
        if (sqlite3_open([[self getDestPath] UTF8String], &database) == SQLITE_OK)
        {
            NSString *insertSQL;
            insertSQL = [NSString stringWithFormat:
                         @"update rodeodetails set isstarted = 'yes' where rodeoid = %d",selectedRodeoId];
            
            NSLog(@"insertSQL = %@",insertSQL);
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(database, insert_stmt,
                               -1, &statement, NULL);

            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"rodeo status updated to started");
                [self readRodeoList];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"My Rodeo" message:@"Rodeo started successfully, Please click on it again to view the details.." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];

            }
    }
    }else if([title isEqualToString:@"No"]){
        
    }
}

- (void) threadStartAnimating:(id)data {
    [activityIndicator startAnimating];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [self.view addSubview: activityIndicator];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Rodeo *tempRodeo=[rodeosArray objectAtIndex:indexPath.row];
    EventsLookUpViewController *evc;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        evc=[[EventsLookUpViewController alloc] initWithNibName:@"EventsLookUpViewController" bundle:nil];
    else
        evc=[[EventsLookUpViewController alloc] initWithNibName:@"EventsLookUpViewController_ipad" bundle:nil];
        evc.rodeoid_=tempRodeo.rodeoid;
    
    evc.selectedRodeo=[[Rodeo alloc] init];
    evc.selectedRodeo=tempRodeo;

    
    [self.navigationController pushViewController:evc animated:YES];
}
            
@end
