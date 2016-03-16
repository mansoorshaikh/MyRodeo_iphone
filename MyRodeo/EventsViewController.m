//
//  EventsViewController.m
//  MyRodeo
//
//  Created by mansoor shaikh on 24/12/13.
//  Copyright (c) 2013 ClientsSolution. All rights reserved.
//

#define kOFFSET_FOR_KEYBOARD 80.0


#import "EventsViewController.h"
#import "EventVO.h"
#import "EventDetailsViewController.h"
#import "UIDevice-Hardware.h"
@interface EventsViewController ()
@property(nonatomic,readwrite) int movementDistance; // tweak as needed
@end

@implementation EventsViewController
@synthesize tblview,bgimage,activityIndicator,eventsArray,eventnamesArray,appDelegate,database,rodeoid,editBarButton;
@synthesize pickerview,toolbar,currentTextField,index,numberToolbar;
@synthesize tag,imgview,forRodeo,movementDistance,selectedEvent,otherSelected,customEvent;
@synthesize usedEventsPickerArray,eventSelectedPickerArray,timedEventNamesArray,scoredEventsNamesArray;
@synthesize contestantTextField,placesTextField,eventsPickerArray,viewUp,EVENTNAMELBL,contLbl,placesLbl;

- (void) animateTextView:(BOOL) up
{
    
    const float movementDuration = 0.3f; // tweak as needed
    int movement= movement = (up ? -movementDistance : movementDistance);
    NSLog(@"%d",movement);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];

            self.view.frame = CGRectOffset(self.view.frame, 0, movement);
            [UIView commitAnimations];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)doneButtonPressed{
    [self animateTextView:NO];
    viewUp=NO;
    pickerview.hidden=YES;
 
    toolbar.hidden=YES;
    [contestantTextField resignFirstResponder];
    [placesTextField resignFirstResponder];
    //selectedEvent.eventname=currentTextField.text;
    if(selectedEvent!=nil && ![selectedEvent.eventname isEqualToString:@"Other"]){
        selectedEvent.eventname=currentTextField.text;
        selectedEvent.contestants=contestantTextField.text;
        selectedEvent.places=placesTextField.text;
        selectedEvent.serverdownload=[NSString stringWithFormat:@"%d",currentTextField.tag-100];
        if([selectedEvent.eventType isEqualToString:@""] || selectedEvent.eventType==nil){
        if([timedEventNamesArray containsObject:selectedEvent.eventname]){
            selectedEvent.eventType=@"timed";
        }else if([scoredEventsNamesArray containsObject:selectedEvent.eventname]){
            selectedEvent.eventType=@"scored";
        }
        }
        [eventSelectedPickerArray replaceObjectAtIndex:currentTextField.tag-100 withObject:selectedEvent];
    }
    [self fillUsedEventsPickerArray];
    UIButton *btn=(UIButton*)[self.view viewWithTag:tag+300];
    btn.hidden=NO;
}
-(void)pickerValue{
    pickerview.hidden=YES;
    toolbar.hidden=YES;

    [contestantTextField resignFirstResponder];
    [placesTextField resignFirstResponder];
    //selectedEvent.eventname=currentTextField.text;
    if(selectedEvent!=nil && ![selectedEvent.eventname isEqualToString:@"Other"]){
        selectedEvent.eventname=currentTextField.text;
        selectedEvent.contestants=contestantTextField.text;
        selectedEvent.places=placesTextField.text;
        selectedEvent.serverdownload=[NSString stringWithFormat:@"%d",currentTextField.tag-100];
        if([selectedEvent.eventType isEqualToString:@""] || selectedEvent.eventType==nil){
            if([timedEventNamesArray containsObject:selectedEvent.eventname]){
                selectedEvent.eventType=@"timed";
            }else if([scoredEventsNamesArray containsObject:selectedEvent.eventname]){
                selectedEvent.eventType=@"scored";
            }
        }
        [eventSelectedPickerArray replaceObjectAtIndex:currentTextField.tag-100 withObject:selectedEvent];
    }
    [self fillUsedEventsPickerArray];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
	if([title isEqualToString:@"OK"]){
        if(![[alertView textFieldAtIndex:0].text isEqualToString:@""]){
            currentTextField.text=[alertView textFieldAtIndex:0].text;
            selectedEvent.eventname=[alertView textFieldAtIndex:0].text;
            selectedEvent.contestants=contestantTextField.text;
            selectedEvent.places=placesTextField.text;
            selectedEvent.serverdownload=[NSString stringWithFormat:@"%d",currentTextField.tag-100];
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                              message:@"Choose the Event Type."
                                                             delegate:self
                                                    cancelButtonTitle:@"Timed Event"
                                                    otherButtonTitles:@"Scored Event",nil];
            [message show];
        }else{
            currentTextField.text=[NSString stringWithFormat:@"Event %d",currentTextField.tag-99];
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                              message:@"Choose some proper event name."
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
        }
        pickerview.hidden=YES;
        toolbar.hidden=YES;

    }else if([title isEqualToString:@"Timed Event"]){
        selectedEvent.eventType=@"timed";
    }else if([title isEqualToString:@"Scored Event"]){
        selectedEvent.eventType=@"scored";
    }
    
    if(customEvent==YES){
        [appDelegate.eventsList addObject:selectedEvent];
        selectedEvent=[[EventVO alloc] init];
        customEvent=NO;
    }
 }

-(void)popviewController{
    [self.navigationController popViewControllerAnimated:YES];
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

-(void)readEventsList{
        char *dbChars ;
        eventsArray =[[NSMutableArray alloc] init];
    	NSString *sqlStatement = [NSString stringWithFormat:@"select * from events where rodeoid=%@",rodeoid];
        
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
                
                dbChars = (char *)sqlite3_column_text(compiledStatement, 6);
                if(dbChars!=nil)
                    event.eventType=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 6)];
                
                [eventsArray addObject:event];
        }
    }
    if(appDelegate.isfromLookup)
    {
        for (int i=0; i<[eventsArray count]; i++) {
            EventVO *event=[eventsArray objectAtIndex:i];
            if([eventsPickerArray containsObject:event.eventname]){
                [eventsPickerArray removeObject:event.eventname];
            }
        }
        [pickerview reloadAllComponents];
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

-(void)editView{
    if([editBarButton.title isEqualToString:@"Edit"])
        editBarButton.title=@"Done";
    else if([editBarButton.title isEqualToString:@"Done"])
        editBarButton.title=@"Edit";
    [tblview reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [activityIndicator stopAnimating];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"innerbg.png"]];
    otherSelected=NO;
    viewUp=NO;
    
    database=[self getNewDb];
    appDelegate=[[UIApplication sharedApplication] delegate];
    pickerview.transform = CGAffineTransformMakeScale(1.0f, 0.75f);
    timedEventNamesArray=[[NSMutableArray alloc] initWithObjects:@"Team Roping",@"Calf Roping",@"Barrel Racing",@"Ribbon Roping",@"Steer Wrestling",@"Break Away Roping",@"Goat Tying",@"Pole Bending", nil];
    
    scoredEventsNamesArray=[[NSMutableArray alloc] initWithObjects:@"Bull Riding",@"Saddle Bronc",@"Bareback", nil];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    imgview=[[UIImageView alloc]init];
    imgview.frame=CGRectMake(0, 0, width, height-20);
    imgview.image=[UIImage imageNamed:@"innerbg.png"];
    [self.view addSubview:imgview];
    
    tblview.frame=CGRectMake(0,0, width, height);
    tblview.backgroundColor=[UIColor clearColor];
    tblview.separatorColor=[UIColor whiteColor];
    tblview.dataSource = self;
    tblview.delegate = self;
    [self.view addSubview:tblview];
    [self.view bringSubviewToFront:tblview];
    CGFloat heightss = [UIScreen mainScreen].bounds.size.height;
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        
    
    if(heightss>=480 && heightss<568){
        EVENTNAMELBL=[[UILabel alloc]initWithFrame:CGRectMake(10,10, 100,30)];
        contLbl=[[UILabel alloc]initWithFrame:CGRectMake(width/2-50,10, 100,30)];
        placesLbl=[[UILabel alloc]initWithFrame:CGRectMake(width/2+50,10, 100,30)];

    }else if(heightss>=568 && heightss<600){
        EVENTNAMELBL=[[UILabel alloc]initWithFrame:CGRectMake(20,10, 100,30)];
        contLbl=[[UILabel alloc]initWithFrame:CGRectMake(width/2-20,10, 100,30)];
        placesLbl=[[UILabel alloc]initWithFrame:CGRectMake(width/2+70,10, 100,30)];

    }else{
        EVENTNAMELBL=[[UILabel alloc]initWithFrame:CGRectMake(30,10, 100,30)];
        contLbl=[[UILabel alloc]initWithFrame:CGRectMake(width/2-50,10, 100,30)];
        placesLbl=[[UILabel alloc]initWithFrame:CGRectMake(width/2+50,10, 100,30)];

    }
        EVENTNAMELBL.font=[UIFont boldSystemFontOfSize:15.0];
        contLbl.font=[UIFont boldSystemFontOfSize:15.0];
        placesLbl.font=[UIFont boldSystemFontOfSize:15.0];


    }else{
        EVENTNAMELBL=[[UILabel alloc]initWithFrame:CGRectMake(60,10, 150,30)];
        contLbl=[[UILabel alloc]initWithFrame:CGRectMake(width/2-20,10, 150,30)];
        placesLbl=[[UILabel alloc]initWithFrame:CGRectMake(width/2+130,10, 150,30)];
        EVENTNAMELBL.font=[UIFont boldSystemFontOfSize:25.0];
        contLbl.font=[UIFont boldSystemFontOfSize:25.0];
        placesLbl.font=[UIFont boldSystemFontOfSize:25.0];


    }
    EVENTNAMELBL.text=@"Event Name";
    EVENTNAMELBL.textColor=[UIColor redColor];
    [self.view addSubview:EVENTNAMELBL];
    [self.view bringSubviewToFront:EVENTNAMELBL];
    
  
    contLbl.text=@"Contestants";
    contLbl.textColor=[UIColor redColor];
    [self.view addSubview:contLbl];
    [self.view bringSubviewToFront:contLbl];

      placesLbl.text=@"Places";
    placesLbl.textColor=[UIColor redColor];
    [self.view addSubview:placesLbl];
    [self.view bringSubviewToFront:placesLbl];

    pickerview.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellbg.png"]];

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
    [editBarButton setTitle:@"Edit"];
    [editBarButton setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = editBarButton;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar.png"]];
    self.navigationController.navigationBar.translucent = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:24] forKey:NSFontAttributeName];
    }else{
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Segoe Print" size:40] forKey:NSFontAttributeName];
    }
    self.navigationItem.title=@"Events";
    
    pickerview.hidden=YES;
    toolbar.hidden=YES;
    
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    index=-1;
    
    eventnamesArray=[[NSMutableArray alloc] init];
    for (int i=1; i<9; i++) {
        EventVO *evo=[[EventVO alloc] init];
        evo.eventname=[NSString stringWithFormat:@"Event %d",i];
        [eventnamesArray addObject:evo];
    }
    
    NSMutableArray *eventsPickerArray_=[[NSMutableArray alloc] initWithObjects:@"Bareback",@"Barrel Racing",@"Break Away Roping",@"Bull Riding",@"Calf Roping",@"Goat Tying",@"Ribbon Roping",@"Saddle Bronc",@"Steer Wrestling",@"Team Roping",@"Pole Bending",@"Other", nil];
    usedEventsPickerArray= [[NSMutableArray alloc] init];
    eventSelectedPickerArray=[[NSMutableArray alloc] init];
    
    eventsPickerArray=[[NSMutableArray alloc] init];
    for (int i=0; i<[eventsPickerArray_ count]; i++) {
        EventVO *evo=[[EventVO alloc] init];
        [eventSelectedPickerArray addObject:evo];
        evo=[[EventVO alloc] init];
        evo.eventname=[eventsPickerArray_ objectAtIndex:i];
        [eventsPickerArray addObject:evo];
    }
    
    for (int i=0; i<[appDelegate.eventsList count]; i++) {
        EventVO *event=[appDelegate.eventsList objectAtIndex:i];
        if([event.serverdownload intValue]==i){
            [eventSelectedPickerArray replaceObjectAtIndex:i withObject:event];
        }
    }
    
    [self fillUsedEventsPickerArray];
   pickerview.showsSelectionIndicator = YES;
    [pickerview reloadAllComponents];
}

-(void)fillUsedEventsPickerArray{
    usedEventsPickerArray= [[NSMutableArray alloc] init];
    ((EventVO*)[eventsPickerArray objectAtIndex:[eventsPickerArray count]-1]).eventname=@"Other";
    for (int i=0; i<[eventsPickerArray count]; i++) {
        EventVO *evo=[eventsPickerArray objectAtIndex:i];
        if([[self checkIfObjectisSelected:evo.eventname] isEqualToString:@"no"]){
            [usedEventsPickerArray addObject:evo];
        }
    }
    //[pickerview reloadAllComponents];
}

-(NSString*)checkIfObjectisSelected:(NSString*)str{
    for (int count=0; count<[eventSelectedPickerArray count]; count++) {
        EventVO *evo=[eventSelectedPickerArray objectAtIndex:count];
        if([str isEqualToString:evo.eventname]){
            return @"yes";
            break;
        }
    }
    return @"no";
}


-(void)viewWillAppear:(BOOL)animated{
    appDelegate.isLandscapeOK=NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    appDelegate.isLandscapeOK=NO;
    return UIInterfaceOrientationMaskPortrait;
}

-(void)cancelNumberPad{
    pickerview.hidden=YES;
    toolbar.hidden=YES;
    [self animateTextView:NO];
     viewUp=NO;
   [contestantTextField resignFirstResponder];
    [placesTextField resignFirstResponder];
    if([contestantTextField.text isEqualToString:@""]){
        contestantTextField.text=@"8";
    }else if([placesTextField.text isEqualToString:@""]){
        placesTextField.text=@"8";
    }
}

-(void)doneWithNumberPad{
    [contestantTextField resignFirstResponder];
    [placesTextField resignFirstResponder];

    pickerview.hidden=YES;
    toolbar.hidden=YES;
    [self animateTextView:NO];
    viewUp=NO;
       if([contestantTextField.text isEqualToString:@""]){
        contestantTextField.text=@"8";
    }else if([placesTextField.text isEqualToString:@""]){
        placesTextField.text=@"3";
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [self addDefaultEvents];
    [self readEventsList];
}

- (void) threadStartAnimating:(id)data {
    [activityIndicator startAnimating];
}

-(void)addDefaultEvents{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;

    tblview.contentSize=CGSizeMake(screenWidth, [eventsArray count]*40+500);
    [tblview reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addEventToRodeo:(UIButton*)btn{
    tag=btn.tag;
    currentTextField=(UITextField*)[self.view viewWithTag:tag-300];
    contestantTextField=(UITextField*)[self.view viewWithTag:tag-200];
    placesTextField=(UITextField*)[self.view viewWithTag:tag-100];
    selectedEvent.eventname=currentTextField.text;
    
    [self pickerValue];

    if(selectedEvent==nil)
    selectedEvent=[[EventVO alloc] init];

    int eventnameFound=0;
    for (int i=0; i<[appDelegate.eventsList count]; i++) {
        EventVO *evo_temp=[appDelegate.eventsList objectAtIndex:i];
        if([evo_temp.eventname isEqualToString:currentTextField.text])
        {
            eventnameFound=1;
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                              message:@"This event name already exists, please choose some other name!!!"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
            break;
        }
    }
    
    if([scoredEventsNamesArray containsObject:currentTextField.text] || [timedEventNamesArray containsObject:currentTextField.text]){
        selectedEvent.eventname=currentTextField.text;
        selectedEvent.contestants=contestantTextField.text;
        selectedEvent.places=placesTextField.text;
        selectedEvent.serverdownload=[NSString stringWithFormat:@"%d",currentTextField.tag-100];
            if([timedEventNamesArray containsObject:selectedEvent.eventname]){
                selectedEvent.eventType=@"timed";
            }else if([scoredEventsNamesArray containsObject:selectedEvent.eventname]){
                selectedEvent.eventType=@"scored";
            }
        
        [eventSelectedPickerArray replaceObjectAtIndex:currentTextField.tag-100 withObject:selectedEvent];
    }else if(otherSelected==YES){
        otherSelected=NO;
    }else{
        customEvent=YES;
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                          message:@"Choose the Event Type."
                                                         delegate:self
                                                cancelButtonTitle:@"Timed Event"
                                                otherButtonTitles:@"Scored Event",nil];
        [message show];
    }
    
    if(eventnameFound==0){
        currentTextField.backgroundColor=[UIColor clearColor];
        currentTextField.enabled=false;
        currentTextField.textColor=[UIColor blackColor];
        currentTextField.font = [UIFont fontWithName:@"Segoe Print" size:20];
        
        contestantTextField.backgroundColor=[UIColor clearColor];
        contestantTextField.enabled=false;
        contestantTextField.textColor=[UIColor redColor];
        contestantTextField.font = [UIFont fontWithName:@"Segoe Print" size:20];
        if([contestantTextField.text isEqualToString:@""]){
            contestantTextField.text=@"8";
        }
        
        placesTextField.enabled=false;
        placesTextField.font = [UIFont fontWithName:@"Segoe Print" size:20];
        placesTextField.backgroundColor=[UIColor clearColor];
        placesTextField.textColor=[UIColor redColor];
        if([placesTextField.text isEqualToString:@""]){
            placesTextField.text=@"3";
        }
        
        selectedEvent.eventname=currentTextField.text;
        selectedEvent.places=placesTextField.text;
        selectedEvent.contestants=contestantTextField.text;
        selectedEvent.serverdownload=[NSString stringWithFormat:@"%d",(currentTextField.tag-100)];
        if(customEvent==NO){
            [appDelegate.eventsList addObject:selectedEvent];
            selectedEvent=[[EventVO alloc] init];
        }
        UIButton *addbtn=(UIButton *)[self.view viewWithTag:btn.tag];
        addbtn.hidden=YES;
        UILabel *plusLbl=(UILabel *)[self.view viewWithTag:btn.tag];
        plusLbl.hidden=YES;

    }
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
        tag=textField.tag;
        int movementCount=0;
        if(contestantTextField!=nil && [contestantTextField.text isEqualToString:@""]){
            contestantTextField.text=@"8";
        }
        if(placesTextField!=nil && [placesTextField.text isEqualToString:@""]){
            placesTextField.text=@"3";
        }
        if(textField.tag>=100 && textField.tag<199){
            movementCount=textField.tag-100;
            currentTextField=textField;
            placesTextField=(UITextField*)[self.view viewWithTag:tag+100];
            contestantTextField=(UITextField*)[self.view viewWithTag:tag+200];
            pickerview.hidden=NO;
            toolbar.hidden=NO;
            selectedEvent=[[EventVO alloc] init];
            [self.view addSubview:pickerview];
            [self.view bringSubviewToFront:pickerview];
            [self.view addSubview:toolbar];
            [self.view bringSubviewToFront:toolbar];
            pickerview.delegate = self;

        }else if(textField.tag>=200 && textField.tag<299){
            movementCount=textField.tag-200;
            contestantTextField=textField;
            placesTextField=(UITextField*)[self.view viewWithTag:tag+100];
            currentTextField=(UITextField*)[self.view viewWithTag:tag-100];
            contestantTextField.inputAccessoryView = numberToolbar;
            contestantTextField.text=@"";
            pickerview.hidden=YES;
            toolbar.hidden=YES;
        }else if(textField.tag>=300 && textField.tag<399){
            movementCount=textField.tag-300;
            placesTextField=textField;
            contestantTextField=(UITextField*)[self.view viewWithTag:tag-100];
            currentTextField=(UITextField*)[self.view viewWithTag:tag-200];
            placesTextField.inputAccessoryView = numberToolbar;
            placesTextField.text=@"";
            pickerview.hidden=YES;
            toolbar.hidden=YES;
        }
   // uint selectedRow = [pickerview selectedRowInComponent:0];
   self.currentTextField.inputView = pickerview;
    
        movementDistance=(movementCount/4)*50;
        if  (viewUp==NO)
        {
            [self animateTextView:YES];
            viewUp=YES;
        }else{
            //[self animateTextView:NO];
            [self animateTextView:YES];
            viewUp=NO;
        }
        if(textField.tag>=100 && textField.tag<199)
        return NO;
        return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField==contestantTextField || textField==placesTextField){
        if([contestantTextField.text isEqualToString:@""]){
            contestantTextField.text=@"8";
        }if([placesTextField.text isEqualToString:@""]){
            contestantTextField.text=@"3";
        }
    }
        [self animateTextView:NO];
        viewUp=NO;
        [textField resignFirstResponder];
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
}

#pragma tableview delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(appDelegate.isfromLookup)
        return [eventsArray count];
    else
        return [eventnamesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    EventVO *event=[[EventVO alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    event=[eventnamesArray objectAtIndex:indexPath.row];
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
    if(appDelegate.isfromLookup)
        eventnameTextField.text=event.eventname;
    else
        eventnameTextField.text=event.eventname;
    eventnameTextField.tag=100+indexPath.row;
    eventnameTextField.textAlignment=NSTextAlignmentCenter;
    eventnameTextField.textColor=[UIColor blackColor];
    
    if(appDelegate.isfromLookup==NO)
    eventnameTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellcontentsbg.png"]];
    eventnameTextField.delegate=self;
    
    UITextField *contestantsTextField;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        contestantsTextField=[[UITextField alloc] initWithFrame:CGRectMake(195, 5, 30, 30)];
        contestantsTextField.font = [UIFont fontWithName:@"Segoe Print" size:20];
        contestantsTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellcontentsbg_short.png"]];

    }
    else{
        contestantsTextField=[[UITextField alloc] initWithFrame:CGRectMake(425, 5, 60, 60)];
        contestantsTextField.font = [UIFont fontWithName:@"Segoe Print" size:30];
        contestantsTextField.returnKeyType = UIReturnKeyDone;
        contestantsTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_shorimg.png"]];

    }
    if(appDelegate.isfromLookup)
    contestantsTextField.text=event.contestants;
    else
    contestantsTextField.text=[defaults objectForKey:@"noofcontestants"];
    contestantsTextField.keyboardType=UIKeyboardTypePhonePad;
    contestantsTextField.tag=200+indexPath.row;
    contestantsTextField.textColor=[UIColor redColor];
    if(appDelegate.isfromLookup==NO)
    contestantsTextField.textAlignment = NSTextAlignmentCenter;

    contestantsTextField.delegate=self;
    placesTextField.delegate=self;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        placesTextField=[[UITextField alloc] initWithFrame:CGRectMake(235, 5, 30, 30)];
        placesTextField.font = [UIFont fontWithName:@"Segoe Print" size:20];
        placesTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellcontentsbg_short.png"]];

    }
    else{
        placesTextField=[[UITextField alloc] initWithFrame:CGRectMake(500, 5, 60, 60)];
        placesTextField.returnKeyType = UIReturnKeyDone;
        placesTextField.font = [UIFont fontWithName:@"Segoe Print" size:30];
        placesTextField.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_shorimg.png"]];

    }
    if(appDelegate.isfromLookup)
        placesTextField.text=event.places;
    else
        placesTextField.text=[defaults objectForKey:@"noofplacespaid"];
    placesTextField.keyboardType=UIKeyboardTypePhonePad;
    placesTextField.tag=300+indexPath.row;
    placesTextField.textAlignment = NSTextAlignmentCenter;
    placesTextField.textColor=[UIColor redColor];
    if(appDelegate.isfromLookup==NO)
    placesTextField.delegate=self;
    
    [cell.contentView addSubview:placesTextField];
 
    UIButton *addbtn;
    UILabel *plusLbl;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        addbtn=[[UIButton alloc] initWithFrame:CGRectMake(270, 5, 30, 30)];
        plusLbl=[[UILabel alloc] initWithFrame:CGRectMake(270, 5, 30, 30)];
        plusLbl.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cellcontentsbg_short.png"]];
    //addbtn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellcontentsbg_short.png"]];
        addbtn.backgroundColor=[UIColor clearColor];
        [plusLbl setFont:[UIFont boldSystemFontOfSize: 24]];
    }else{
        addbtn=[[UIButton alloc] initWithFrame:CGRectMake(580, 5, 60, 60)];
        plusLbl=[[UILabel alloc] initWithFrame:CGRectMake(580, 5, 60, 60)];
        plusLbl.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_shorimg.png"]];
        [plusLbl setFont:[UIFont boldSystemFontOfSize: 30]];

    //addbtn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cell_shorimg.png"]];
        addbtn.backgroundColor=[UIColor clearColor];
    }
    plusLbl.text=@"+";
    plusLbl.textAlignment = UITextAlignmentCenter;
    plusLbl.textColor=[UIColor darkGrayColor];
    plusLbl.tag=400+indexPath.row;
    addbtn.tag=400+indexPath.row;
    
    [addbtn addTarget:self
               action:@selector(addEventToRodeo:)
     forControlEvents:UIControlEventTouchUpInside];
    
   // addbtn.titleLabel.font = [UIFont fontWithName:@"Segoe Print" size:24];
   // [addbtn setTitle:@"+" forState:UIControlStateNormal];
    //[addbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
   
    for (int i=0; i<[appDelegate.eventsList count]; i++) {
        EventVO *event=[appDelegate.eventsList objectAtIndex:i];
        if([event.serverdownload intValue]==indexPath.row){
            placesTextField.text=event.places;
            contestantsTextField.text=event.contestants;
            eventnameTextField.text=event.eventname;
            addbtn.hidden=YES;
            plusLbl.hidden=YES;
        }
    }
    
    if(appDelegate.isfromLookup==NO){
        [cell.contentView addSubview:plusLbl];
        [cell.contentView bringSubviewToFront:addbtn];
        [cell.contentView addSubview:addbtn];
    }
    
    [cell.contentView addSubview:eventnameTextField];
    [cell.contentView addSubview:contestantsTextField];
    
    if([editBarButton.title isEqualToString:@"Done"]){
        placesTextField.enabled=TRUE;
        contestantsTextField.enabled=TRUE;
        eventnameTextField.enabled=TRUE;
    }else if([editBarButton.title isEqualToString:@"Edit"]){
        placesTextField.enabled=FALSE;
        contestantsTextField.enabled=FALSE;
        eventnameTextField.enabled=FALSE;
    }
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCellEditingStyle result = UITableViewCellEditingStyleNone;
    
    if ([tableView isEqual:self.tblview]){
        result = UITableViewCellEditingStyleDelete;
    }
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    return 40;
    else
        return 70;
}

//picker view delegate methods
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    EventVO *evo=[usedEventsPickerArray objectAtIndex:row];
    selectedEvent=[[EventVO alloc] init];
   
    if([evo.eventname isEqualToString:@"Other"]){
        otherSelected=YES;
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"My Rodeo"
                                                          message:@"Enter event name below."
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:@"Cancel",nil];
        message.alertViewStyle = UIAlertViewStylePlainTextInput;
        [message show];
    }else{
        currentTextField.text=@"";
        currentTextField.text=evo.eventname;
        selectedEvent=evo;
    }
}



-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    EventVO *evo=[usedEventsPickerArray objectAtIndex:row];
    row = [pickerView selectedRowInComponent:0];
    EventVO *evos = [usedEventsPickerArray objectAtIndex:row];
    currentTextField.text=evos.eventname;
    return evo.eventname;
}

-(CGFloat) pickerView:(UIPickerView *) pickerView widthForComponent:(NSInteger)component{
    return 340;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;

    if(height==480){
        return 45.0;
    }else if(height==568){
            return 57;
    }else if(height==667){
        return 95.0;
    }else{
        return 137.0;
    }
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [usedEventsPickerArray count];
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation{
    
}


@end
