//
//  EventsLookUpViewController.m
//  MyRodeo
//
//  Created by mansoor shaikh on 12/05/14.
//  Copyright (c) 2014 ClientsSolution. All rights reserved.
//

#import "EventsLookUpViewController.h"
#import "EventVO.h"
#import "EventDetailsViewController.h"
#import "AppDelegate.h"
#import "RodeoListViewController.h"
@interface EventsLookUpViewController ()

@end

@implementation EventsLookUpViewController
@synthesize tblview_,activityIndicator_,eventsArray_,currentTextField_,contestantTextField_,placesTextField_,rodeoid_,selectedRodeo,database,appDelegate,editBarButton,alertView,EventNamesArray,selectedEvent,eventType,contestantsselected,placesselected,timedEventNamesArray,scoredEventsNamesArray,bgimage;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)editView{
    if([editBarButton.title isEqualToString:@"Edit"])
        editBarButton.title=@"Done";
    else if([editBarButton.title isEqualToString:@"Done"])
        editBarButton.title=@"Edit";
    [tblview_ reloadData];
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


-(void)readEventsList{
    char *dbChars ;
    eventsArray_ =[[NSMutableArray alloc] init];
    NSString* destPath = [self getDestPath];
		NSString *sqlStatement = [NSString stringWithFormat:@"select * from events where rodeoid=%@",rodeoid_];
        
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, [sqlStatement UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                EventVO *event=[[EventVO alloc] init];
                dbChars = (char *)sqlite3_column_text(compiledStatement, 0);
                if(dbChars!=nil)
                    event.eventid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
                
                dbChars = (char *)sqlite3_column_text(compiledStatement, 1);
                if(dbChars!=nil)
                    event.rodeoid=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                
                dbChars = (char *)sqlite3_column_text(compiledStatement, 2);
                if(dbChars!=nil)
                    event.eventname=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 2)];
                
                dbChars = (char *)sqlite3_column_text(compiledStatement, 3);
                if(dbChars!=nil)
                    event.contestants=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 3)];
                
                dbChars = (char *)sqlite3_column_text(compiledStatement, 4);
                if(dbChars!=nil)
                    event.places=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 4)];
                
                dbChars = (char *)sqlite3_column_text(compiledStatement, 5);
                if(dbChars!=nil)
                    event.currentround=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 5)];
                
                dbChars = (char *)sqlite3_column_text(compiledStatement, 6);
                if(dbChars!=nil)
                    event.eventType=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6 )];
                
                [eventsArray_ addObject:event];
        }
    }
    [tblview_ reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
        [self readEventsList];
    [activityIndicator_ stopAnimating];
}

- (void) threadStartAnimating:(id)data {
    [activityIndicator_ startAnimating];
}

-(void)popviewController{
    sqlite3_close(database);
    RodeoListViewController *rodeolist=[[RodeoListViewController alloc] initWithNibName:@"RodeoListViewController" bundle:nil];
    [self.navigationController pushViewController:rodeolist animated:YES];

}

-(UIView*)createDemoView{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,300,300)];
    
    UILabel *selectCategoryLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0,300, 50)];
    selectCategoryLabel.textColor=[UIColor blackColor];
    selectCategoryLabel.text=@"Choose Event";
    [selectCategoryLabel setFont:[UIFont boldSystemFontOfSize:20]];
    selectCategoryLabel.textAlignment=UITextAlignmentCenter;
    [demoView addSubview:selectCategoryLabel];

    
    UIScrollView *categoryScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, 300,250)];
    categoryScrollView.contentSize=CGSizeMake(300, ([EventNamesArray count]-[eventsArray_ count]+3)*40);
    int yValue=0;
    for (int count=0; count<[EventNamesArray count]; count++) {
        int found=0;
        for (int innercount=0; innercount<[eventsArray_ count]; innercount++) {
            EventVO *evo=[eventsArray_ objectAtIndex:innercount];
            if([evo.eventname isEqualToString:[EventNamesArray objectAtIndex:count]]){
                found=1;
                break;
            }
        }
        if(found==0){
        UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(0, yValue, 300, 38)];
        btn.tag=count;
        [btn addTarget:self action:@selector(eventSelected:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:[EventNamesArray objectAtIndex:count] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor blackColor]];
        [categoryScrollView addSubview:btn];
        yValue=yValue+40;
        }
    }
    [demoView addSubview:categoryScrollView];
    return demoView;
}

-(void)eventSelected:(UIButton*)btn{
    selectedEvent=[EventNamesArray objectAtIndex:btn.tag];
    if([selectedEvent isEqualToString:@"Other"]){
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Title" message:@"Please enter Event Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Timed Event",@"Scored Event", nil];
        av.alertViewStyle = UIAlertViewStylePlainTextInput;
        [av textFieldAtIndex:0].delegate = self;
        [av show];
    }else if([selectedEvent isEqualToString:@"Cancel"]){
        
    }else{
        if([timedEventNamesArray containsObject:selectedEvent]){
            eventType=@"timed";
        }else if([scoredEventsNamesArray containsObject:selectedEvent]){
            eventType=@"scored";
        }
        [self contestantsPlacesDialogue];
    }
    [alertView close];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Timed Event"]){
        eventType=@"timed";
        selectedEvent=[alertView textFieldAtIndex:0].text;
        [self contestantsPlacesDialogue];
    }else if([title isEqualToString:@"Scored Event"]){
        eventType=@"scored";
        selectedEvent=[alertView textFieldAtIndex:0].text;
        [self contestantsPlacesDialogue];
    }else if([title isEqualToString:@"OK"]){
        contestantsselected=[alertView textFieldAtIndex:0].text;
        placesselected=[alertView textFieldAtIndex:1].text;
        [self addEventToDatabase];
    }
}

-(void)contestantsPlacesDialogue{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                    message:@"Please enter No of Contestants and Places"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK",nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [[alert textFieldAtIndex:0] setPlaceholder:@"No of Contestants"];
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    [[alert textFieldAtIndex:1] setPlaceholder:@"No of Places"];
    [[alert textFieldAtIndex:1] setKeyboardType:UIKeyboardTypeNumberPad];
    [alert show];
}

-(void)addEventToDatabase{
    sqlite3_stmt *statement;
    NSLog(@"[self getDestPath] = %@",[self getDestPath]);
    if (sqlite3_open([[self getDestPath] UTF8String], &database) == SQLITE_OK)
    {
        NSString *insertSQL;
        insertSQL = [NSString stringWithFormat:
                     @"insert into events (rodeoid,eventname,contestants,places,currentround,eventType) VALUES (%@,\"%@\",\"%@\",\"%@\",1,\"%@\")",rodeoid_,selectedEvent,contestantsselected,placesselected,eventType];
        
        NSLog(@"insertSQL = %@",insertSQL);
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"record inserted");
        }else{
            NSLog(@"record insertion failed");
            NSLog(@"Error %s while preparing statement", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
    }
    [self readEventsList];

}

-(void)addEvent{
    alertView = [[CustomIOS7AlertView alloc] init];
    
    // Add some custom content to the alert view
    [alertView setContainerView:[self createDemoView]];
    
    // Modify the parameters
    
    [alertView setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView_, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView_ tag]);
        [alertView_ close];
    }];
    
    [alertView setUseMotionEffects:true];
    
    // And launch the dialog
    [alertView show];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    EventNamesArray=[[NSMutableArray alloc] initWithObjects:@"Bareback",@"Barrel Racing",@"Break Away Roping",@"Bull Riding",@"Calf Roping",@"Goat Tying",@"Ribbon Roping",@"Saddle Bronc",@"Steer Wrestling",@"Team Roping",@"Pole Bending",@"Other",@"Cancel", nil];
    timedEventNamesArray=[[NSMutableArray alloc] initWithObjects:@"Team Roping",@"Calf Roping",@"Barrel Racing",@"Ribbon Roping",@"Steer Wrestling",@"Break Away Roping",@"Goat Tying",@"Pole Bending", nil];
    scoredEventsNamesArray=[[NSMutableArray alloc] initWithObjects:@"Bull Riding",@"Saddle Bronc",@"Bareback", nil];

    selectedEvent=[[NSString alloc] init];
    eventType=[[NSString alloc] init];
    contestantsselected=[[NSString alloc] init];
    placesselected=[[NSString alloc] init];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    bgimage=[[UIImageView alloc]init];
    bgimage.frame=CGRectMake(0, 0, width, height-20);
    bgimage.image=[UIImage imageNamed:@"innerbg.png"];
    [self.view addSubview:bgimage];
    tblview_.frame=CGRectMake(0, 0, width, height);
    tblview_.backgroundColor=[UIColor clearColor];
    tblview_.separatorColor=[UIColor grayColor];
    tblview_.dataSource = self;
    tblview_.delegate = self;
    [self.view addSubview:tblview_];
    [self.view bringSubviewToFront:tblview_];

    database=[self getNewDb];
    appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view from its nib.
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
    
    editBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Event" style:UIBarButtonItemStylePlain target:self action:@selector(addEvent)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [editBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:18], UITextAttributeFont,nil] forState:UIControlStateNormal];
    else
        [editBarButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:30], UITextAttributeFont,nil] forState:UIControlStateNormal];
    editBarButton.tintColor=[UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = editBarButton;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar.png"]];
    self.navigationController.navigationBar.translucent = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:24] forKey:NSFontAttributeName];
    }else{
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:40] forKey:NSFontAttributeName];
    }
    self.navigationItem.title=@"Events";
    [activityIndicator_ stopAnimating];
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
        return [eventsArray_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    EventVO *event=[[EventVO alloc] init];
    event=[eventsArray_ objectAtIndex:indexPath.row];
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    cell.backgroundColor=[UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITextField *eventnameTextField;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        eventnameTextField=[[UITextField alloc] initWithFrame:CGRectMake(5, 5, 180, 30)];
        eventnameTextField.font = [UIFont fontWithName:@"Segoe Print" size:20];
    }
    else{
        eventnameTextField=[[UITextField alloc] initWithFrame:CGRectMake(50, 5, 300, 60)];
        eventnameTextField.font = [UIFont fontWithName:@"Segoe Print" size:30];
    }
    eventnameTextField.text=event.eventname;
    UITextField *contestantsTextField;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        contestantsTextField=[[UITextField alloc] initWithFrame:CGRectMake(195, 5, 30, 30)];
        contestantsTextField.font = [UIFont fontWithName:@"Segoe Print" size:20];
    }
    else{
        contestantsTextField=[[UITextField alloc] initWithFrame:CGRectMake(425, 5, 60, 60)];
        contestantsTextField.font = [UIFont fontWithName:@"Segoe Print" size:30];
        contestantsTextField.returnKeyType = UIReturnKeyDone;
    }
    contestantsTextField.text=event.contestants;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        placesTextField_=[[UITextField alloc] initWithFrame:CGRectMake(255, 5, 30, 30)];
        placesTextField_.font = [UIFont fontWithName:@"Segoe Print" size:20];
    }
    else{
        placesTextField_=[[UITextField alloc] initWithFrame:CGRectMake(500, 5, 60, 60)];
        placesTextField_.returnKeyType = UIReturnKeyDone;
        placesTextField_.font = [UIFont fontWithName:@"Segoe Print" size:30];
    }
    
    placesTextField_.text=event.places;
    eventnameTextField.enabled=NO;
    contestantsTextField.enabled=NO;
    placesTextField_.enabled=NO;
    [cell.contentView addSubview:eventnameTextField];
    [cell.contentView addSubview:contestantsTextField];
    [cell.contentView addSubview:placesTextField_];
    [cell setEditing:YES animated:YES];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return 40;
    else
        return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EventVO *event=[eventsArray_ objectAtIndex:indexPath.row];
    EventDetailsViewController *eventdetails;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        eventdetails=[[EventDetailsViewController alloc] initWithNibName:@"EventDetailsViewController" bundle:nil];
    else
        eventdetails=[[EventDetailsViewController alloc] initWithNibName:@"EventDetailsViewController_iPad" bundle:nil];
    
    eventdetails.eventidSelected=event.eventid;
    eventdetails.eventVOSelected=event;
    eventdetails.selectedRodeo=[[Rodeo alloc] init];
    eventdetails.selectedRodeo=selectedRodeo;
    [self.navigationController pushViewController:eventdetails animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        
    }
}


@end
