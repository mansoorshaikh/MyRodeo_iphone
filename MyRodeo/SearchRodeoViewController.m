//
//  SearchRodeoViewController.m
//  MyRodeo
//
//  Created by mansoor shaikh on 26/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#import "SearchRodeoViewController.h"
#import "Rodeo.h"
#import "EventVO.h"
#import "ContestantVO.h"
@interface SearchRodeoViewController ()

@end

@implementation SearchRodeoViewController
@synthesize tblview,rodeosArray,searchrodeosArray,search,searchbar,appDelegate,imgview,activityIndicator,selectedRodeoToSync,database;
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


- (NSUInteger)supportedInterfaceOrientations
{
    appDelegate.isLandscapeOK=NO;
    return UIInterfaceOrientationMaskPortrait;
}

-(void)popviewController{
    sqlite3_close(database);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    database=[self getNewDb];
    appDelegate=[[UIApplication sharedApplication] delegate];
    [activityIndicator stopAnimating];
    
    [self getRodeoList];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if(height>=568){
        imgview.image=[UIImage imageNamed:@"innerbg.png"];
    }else{
        imgview.image=[UIImage imageNamed:@"innerbg_.png"];
    }
    
    searchrodeosArray=[[NSMutableArray alloc] init];
    
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
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:24] forKey:NSFontAttributeName];
    else
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:40] forKey:NSFontAttributeName];
    self.navigationItem.title=@"Sync Rodeo";
}

-(void)getRodeoList{
    [NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
    NSString *post =[NSString stringWithFormat:@""];
    NSString *urlString = [[NSString alloc]initWithFormat:@"http://www.mobiwebcode.com/rodeo/getrodeolist.php?%@",post];
    rodeosArray=[[NSMutableArray alloc] init];
    NSLog(@"register url %@",urlString);
    
    NSData *mydata = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSString *content = [[NSString alloc]  initWithBytes:[mydata bytes]
                                                  length:[mydata length] encoding: NSUTF8StringEncoding];
    if(![content isEqualToString:@""]){
        NSMutableArray *rodeoDetails=[[NSMutableArray alloc] initWithArray:[content componentsSeparatedByString:@"+#"]];
        int count=0;
        Rodeo *rodeo=[[Rodeo alloc] init];
        for (int i=0; i<[rodeoDetails count]-1; i++) {
            if(count==0){
                rodeo.rodeoid=[rodeoDetails objectAtIndex:i];
                count++;
            }else if(count==1){
                rodeo.rodeoname=[rodeoDetails objectAtIndex:i];
                count++;
            }else if(count==2){
                rodeo.location=[rodeoDetails objectAtIndex:i];
                count++;
            }else if(count==3){
                rodeo.rodeostartdate=[rodeoDetails objectAtIndex:i];
                count++;
            }else if(count==4){
                rodeo.numberofrounds=[rodeoDetails objectAtIndex:i];
                rodeo.serverRodeo=@"yes";
                [rodeosArray addObject:rodeo];
                rodeo=[[Rodeo alloc] init];
                count=0;
            }
        }
    }
    [activityIndicator stopAnimating];
}

- (void) threadStartAnimating:(id)data {
    [activityIndicator startAnimating];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [self.view addSubview: activityIndicator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    appDelegate.isLandscapeOK=NO;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchrodeosArray=[[NSMutableArray alloc] init];
    if([searchText isEqualToString:@""] || searchText==nil){
        [tblview reloadData];
        search=NO;
        return;
    }
    search=YES;
    for(Rodeo *rodeo in rodeosArray)
    {
        NSRange r = [[rodeo.rodeoname lowercaseString] rangeOfString:[searchText lowercaseString]];
        if(r.location != NSNotFound)
        {
            if(r.location== 0)//that is we are checking only the start of the names.
            {
                [searchrodeosArray addObject:rodeo];
            }
        }
    }
    [tblview reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [tblview reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    search=NO;
    [tblview reloadData];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	if([title isEqualToString:@"Yes"]){
        [self syncSelectedRodeo];
    }
}

-(void)syncSelectedRodeo{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"rodeolist.plist"]; //3
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    [data setObject:selectedRodeoToSync.rodeoid forKey:selectedRodeoToSync.rodeoname];
    [data writeToFile:path atomically:YES];
}

-(void)syncRodeo{
    [NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
    NSString *post =[NSString stringWithFormat:@"rodeoid=%@",selectedRodeoToSync.rodeoid];
    NSString *urlString = [[NSString alloc]initWithFormat:@"http://www.mobiwebcode.com/rodeo/geteventslist.php?%@",post];
    rodeosArray=[[NSMutableArray alloc] init];
    NSLog(@"register url %@",urlString);
    
    NSData *mydata = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSString *content = [[NSString alloc]  initWithBytes:[mydata bytes]
                                                  length:[mydata length] encoding: NSUTF8StringEncoding];
    NSMutableArray *eventDetails,*eventsArray;
    if(![content isEqualToString:@""] || content!=nil){
        eventDetails=[[NSMutableArray alloc] initWithArray:[content componentsSeparatedByString:@"+#"]];
        eventsArray=[[NSMutableArray alloc] init];
        int count=0;
        EventVO *evo=[[EventVO alloc] init];
        for (int i=0; i<[eventDetails count]; i++) {
            if(count==0){
                evo.eventid=[eventDetails objectAtIndex:i];
                count++;
            }else if(count==1){
                evo.rodeoid=[eventDetails objectAtIndex:i];
                count++;
            }else if(count==2){
                evo.eventname=[eventDetails objectAtIndex:i];
                count++;
            }else if(count==3){
                evo.contestants=[eventDetails objectAtIndex:i];
                count++;
            }else if(count==4){
                evo.places=[eventDetails objectAtIndex:i];
                count++;
            }else if(count==5){
                evo.currentround=[eventDetails objectAtIndex:i];
                count++;
            }else if(count==6){
                evo.eventType=[eventDetails objectAtIndex:i];
                [eventsArray addObject:evo];
                evo=[[EventVO alloc] init];
                count=0;
            }
        }
                
        sqlite3_stmt *statement;
        NSLog(@"[self getDestPath] = %@",[self getDestPath]);
        
        if (sqlite3_open([[self getDestPath] UTF8String], &database) == SQLITE_OK)
        {
            NSString *insertSQL;
            insertSQL = [NSString stringWithFormat:
                         @"insert into rodeodetails (rodeoname,location,rodeostartdate,numberofrounds,isstarted,serverrodeo) VALUES (\"%@\",\"%@\",\"%@\",\"%@\",\"yes\",\"yes\")",selectedRodeoToSync.rodeoname,selectedRodeoToSync.location,selectedRodeoToSync.rodeostartdate,selectedRodeoToSync.numberofrounds];
            
            NSLog(@"insertSQL = %@",insertSQL);
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(database, insert_stmt,
                               -1, &statement, NULL);
            NSNumber *menuID;
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"record inserted");
                selectedRodeoToSync.rodeoid=[NSString stringWithFormat:@"%lld",sqlite3_last_insert_rowid(database)];
            }
        }
        
        for (int i=0; i<[eventsArray count]; i++) {
            EventVO *evo=[eventsArray objectAtIndex:i];
            
            post =[NSString stringWithFormat:@"eventid=%@",evo.eventid];
            urlString = [[NSString alloc]initWithFormat:@"http://www.mobiwebcode.com/rodeo/getcontestantslist.php?%@",post];
            NSData *mydata = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            
            NSString *content = [[NSString alloc]  initWithBytes:[mydata bytes]
                                                          length:[mydata length] encoding: NSUTF8StringEncoding];
            NSMutableArray *contestantsListArray=[[NSMutableArray alloc] init];
            if(![content isEqualToString:@""] || content!=nil){
                NSMutableArray *contestantDetailsArray=[[NSMutableArray alloc] initWithArray:[content componentsSeparatedByString:@"+#"]];

                int count=0;
                ContestantVO *cvo=[[ContestantVO alloc] init];
                for (int i=0; i<[contestantDetailsArray count]; i++) {
                    if(count==0){
                        cvo.contestantid=[contestantDetailsArray objectAtIndex:i];
                        count++;
                    }else if(count==1){
                        cvo.eventid=[contestantDetailsArray objectAtIndex:i];
                        count++;
                    }else if(count==2){
                        cvo.contestantname=[contestantDetailsArray objectAtIndex:i];
                        count++;
                    }else if(count==3){
                        cvo.score=[contestantDetailsArray objectAtIndex:i];
                        count++;
                    }else if(count==4){
                        cvo.time=[contestantDetailsArray objectAtIndex:i];
                        count++;
                    }else if(count==5){
                        cvo.round=[contestantDetailsArray objectAtIndex:i];
                        [contestantsListArray addObject:cvo];
                        cvo=[[ContestantVO alloc] init];
                        count=0;
                    }
                }
            }

                NSString *insertSQL;
                insertSQL = [NSString stringWithFormat:
                             @"insert into events (rodeoid,eventname,contestants,places,currentround,eventType) VALUES (%@,\"%@\",\"%@\",\"%@\",0,\"%@\")",selectedRodeoToSync.rodeoid,evo.eventname,evo.contestants,evo.places,evo.eventType];
                
                NSLog(@"insertSQL = %@",insertSQL);
                const char *insert_stmt = [insertSQL UTF8String];
                sqlite3_prepare_v2(database, insert_stmt,
                                   -1, &statement, NULL);
                if (sqlite3_step(statement) == SQLITE_DONE)
                {
                    NSLog(@"record inserted");
                    evo.eventid= [NSString stringWithFormat:@"%lld",sqlite3_last_insert_rowid(database)];
                }
            
            
            for (int i=0; i<[contestantsListArray count]; i++) {
                ContestantVO *cvo=[[ContestantVO alloc] init];
                cvo=[contestantsListArray objectAtIndex:i];
                    NSString *insertSQL;
                    insertSQL = [NSString stringWithFormat:
                                 @"insert into contestants (eventid,eventgroup,contestantname,score,time,round) values (\"%@\",\"%d\",\"%@\",\"%@\",\"%@\",\"%@\")",evo.eventid,i,cvo.contestantname,cvo.score,cvo.time,cvo.round];
                    
                    NSLog(@"insertSQL = %@",insertSQL);
                    const char *insert_stmt = [insertSQL UTF8String];
                    sqlite3_prepare_v2(database, insert_stmt,
                                       -1, &statement, NULL);
                    NSNumber *menuID;
                    if (sqlite3_step(statement) == SQLITE_DONE)
                    {
                        NSLog(@"record inserted");
                    }
            }
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                        message:@"Rodeo Sync Successful" delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                        message:@"No Internet Connection, please try again Later" delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    [activityIndicator stopAnimating];
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

#pragma tableview delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(search==NO)
    return [rodeosArray count];
    else
    return [searchrodeosArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    cell.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellbg.png"]];
    Rodeo *rodeo=[[Rodeo alloc] init];
    if(search==NO){
        rodeo=[rodeosArray objectAtIndex:indexPath.row];
        cell.textLabel.text=rodeo.rodeoname;
    }
    else{
        rodeo=[searchrodeosArray objectAtIndex:indexPath.row];
        cell.textLabel.text=rodeo.rodeoname;
    }
    cell.textLabel.textColor=[UIColor blackColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        cell.textLabel.font = [UIFont fontWithName:@"Segoe Print" size:24];
    else
        cell.textLabel.font = [UIFont fontWithName:@"Segoe Print" size:40];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedRodeoToSync=[[Rodeo alloc] init];
    selectedRodeoToSync=[rodeosArray objectAtIndex:indexPath.row];
    UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"My Radio"];
	[alert setMessage:@"Do You want to Sync this Rodeo to Application"];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert show];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return 40;
    else
        return 70;
}


@end
